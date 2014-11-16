module spi_master(
input rst_n,
input clk,
output ssel,
output sclk,
output mosi,
input miso
);

localparam FRAME_LENGTH = 16; // length of a single transmission frame

wire [FRAME_LENGTH - 1 : 0] test_data = 16'h37FF;

reg [FRAME_LENGTH - 1 : 0] indata_d, indata_q;

reg ssel_d, ssel_q, sclk_d, sclk_q, mosi_d, mosi_q;

assign ssel = ~ssel_q;
assign sclk = sclk_q;
assign mosi = mosi_q;

localparam HALF_BIT = 25; // half bit duration in T_clk

localparam BACKOFF_DURATION = 4; // back off duration between transmissions (in half bits)

reg [7:0] cnt;
wire cnt_maxed = (cnt >= HALF_BIT);

// half bit duration counter
always @ (posedge clk)
begin
if (!rst_n || cnt_maxed)
	cnt = 0;
else
	cnt = cnt +1;
end

// half bit count
reg [7:0] half_bit_cnt;
always @ (posedge clk)
begin
if (!rst_n || (state_d == IDLE))
	half_bit_cnt = 0;
else
	if (cnt_maxed)
		half_bit_cnt = half_bit_cnt +1;
	else
		half_bit_cnt = half_bit_cnt;
end

localparam STATE_SIZE = 3;

localparam 	IDLE = 0, // module in idle
						HOLDOFF = 1, // holdoff time to allow data line to settle prior to sclk transition
						SUSTAIN = 2, // sustain data line level after sclk transition
						BACKOFF = 3; // back off duration between subsequent transmission

reg [STATE_SIZE-1:0] state_d, state_q;

wire txrq = 1; // transmission request
always @*
begin
// default assignments: keep value unless assigned differently (to prevent inferring latches)
state_d = state_q;
indata_d = indata_q;

ssel_d = ssel_q;
mosi_d = mosi_q;
sclk_d = sclk_q;

// state transitions
case(state_q)
	IDLE: 
	begin
	if(txrq)
		state_d = HOLDOFF; // start transmission
	end
	HOLDOFF:
	begin
	if(half_bit_cnt[0] == 1)
		state_d = SUSTAIN;
	end
	SUSTAIN:
	begin
	if(half_bit_cnt > ((FRAME_LENGTH - 1) * 2) + 1)
		state_d = BACKOFF;
	else if(half_bit_cnt[0] == 0)
		state_d = HOLDOFF;
	end
	BACKOFF:
	begin
	if(half_bit_cnt > ((FRAME_LENGTH - 1 + BACKOFF_DURATION) * 2) + 1)
		state_d = IDLE;
	end
endcase

// state behaviour
case(state_q)
	IDLE: 
	begin
		ssel_d = 0;
		mosi_d = 0;
		sclk_d = 0;
	end
	HOLDOFF:
	begin
		ssel_d = 1;
		mosi_d = test_data[(FRAME_LENGTH-1) - half_bit_cnt/2];
		sclk_d = 0;
	end
	SUSTAIN:
	begin
		ssel_d = 1;
		mosi_d = test_data[(FRAME_LENGTH-1) - half_bit_cnt/2];
		sclk_d = 1;
		indata_d[((FRAME_LENGTH-1) - half_bit_cnt)/2] = miso;
	end
	BACKOFF:
	begin
		ssel_d = 0;
		mosi_d = 0;
		sclk_d = 0;
	end
endcase
end

always @(posedge clk) begin
if (!rst_n) begin
	state_q <= IDLE;
end else begin
	state_q <= state_d;
end
	indata_q <= indata_d;
		ssel_q = ssel_d;
		mosi_q = mosi_d;
		sclk_q = sclk_d;
end

endmodule