//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:51:47 08/24/2014 
// Design Name: 
// Module Name:    vga_module 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module vga_module(
    input clk,
    input rst_n,
    output [7:0] red,
    output [7:0] green,
    output [7:0] blue,
    output h_sync,
    output v_sync
    );
reg [10:0] CounterX;
reg [8:0] CounterY;

wire CounterXmaxed = (CounterX==767+768);
wire CounterYmaxed = (CounterY==511);

always @(posedge clk)
begin
if(CounterXmaxed || rst_n == 0)
  CounterX <= 0;
else
  CounterX <= CounterX + 1;
end

always @(posedge clk)
begin
if(rst_n == 0)
begin
	CounterY <= 0;
end
else if(CounterXmaxed)
begin
	CounterY <= CounterY + 1;
end
	else
	begin
		CounterY <= CounterY;
	end
end
	 
reg vga_HS, vga_VS;
always @(posedge clk)
begin
  vga_HS <= (16*2 < CounterX)  && (CounterX < 64*2);// 640x480:(CounterX[10:5]==0);   // active for 16 clocks
  vga_VS <= (10 < CounterY)  && (CounterY < 12);   // active for one line
end

assign h_sync = ~vga_HS;
assign v_sync = ~vga_VS;

// test pattern generator
//assign red = CounterY[3] | (CounterX==256);
//assign green = (CounterX[5] ^ CounterX[6]) | (CounterX==256);
//assign blue = CounterX[4] | (CounterX==256); 


reg [31 : 0] frame_count;

always @(posedge clk)
begin
if(rst_n == 0)
  frame_count <= 0;
else if(CounterYmaxed)
  frame_count <= frame_count + 1;
end

wire [15:0] bmp[7:0];

assign bmp[0][15:0] = 16'b0000000000000000;
assign bmp[1][15:0] = 16'b0100101000010000;
assign bmp[2][15:0] = 16'b0100101000010000;
assign bmp[3][15:0] = 16'b0111101011010000;
assign bmp[4][15:0] = 16'b0100100100100000;
assign bmp[5][15:0] = 16'b0100100100100000;
assign bmp[6][15:0] = 16'b0100100100100000;
assign bmp[7][15:0] = 16'b0000000000000000;

wire [47:0] charset[15:0];
assign charset[0] = {
6'b000000,
6'b011110,
6'b010010,
6'b010010,
6'b010010,
6'b011110,
6'b000000,
6'b000000
};

assign charset[1] = {
6'b000000,
6'b000100,
6'b001100,
6'b000100,
6'b000100,
6'b000100,
6'b000000,
6'b000000
};

assign charset[2] = {
6'b000000,
6'b001100,
6'b010010,
6'b000100,
6'b001000,
6'b011110,
6'b000000,
6'b000000
};

assign charset[3] = {
6'b000000,
6'b001100,
6'b010010,
6'b000100,
6'b010010,
6'b001100,
6'b000000,
6'b000000
};

assign charset[4] = {
6'b000000,
6'b000010,
6'b000110,
6'b001010,
6'b011110,
6'b000010,
6'b000000,
6'b000000
};

assign charset[5] = {
6'b000000,
6'b011110,
6'b010000,
6'b001100,
6'b010010,
6'b001100,
6'b000000,
6'b000000
};

assign charset[6] = {
6'b000000,
6'b001100,
6'b010000,
6'b011100,
6'b010010,
6'b001100,
6'b000000,
6'b000000
};

assign charset[7] = {
6'b000000,
6'b011110,
6'b010010,
6'b000100,
6'b001000,
6'b001000,
6'b000000,
6'b000000
};

assign charset[8] = {
6'b000000,
6'b001100,
6'b010010,
6'b001100,
6'b010010,
6'b001100,
6'b000000,
6'b000000
};

assign charset[9] = {
6'b000000,
6'b001100,
6'b010010,
6'b001110,
6'b000010,
6'b001100,
6'b000000,
6'b000000
};

assign charset[10] = {
6'b000000,
6'b001100,
6'b010010,
6'b011110,
6'b010010,
6'b010010,
6'b000000,
6'b000000
};

assign charset[11] = {
6'b000000,
6'b011100,
6'b010010,
6'b011100,
6'b010010,
6'b011100,
6'b000000,
6'b000000
};

assign charset[12] = {
6'b000000,
6'b001100,
6'b010010,
6'b010000,
6'b010010,
6'b001100,
6'b000000,
6'b000000
};

assign charset[13] = {
6'b000000,
6'b011100,
6'b010010,
6'b010010,
6'b010010,
6'b011100,
6'b000000,
6'b000000
};

assign charset[14] = {
6'b000000,
6'b011110,
6'b010000,
6'b011100,
6'b010000,
6'b011110,
6'b000000,
6'b000000
};

assign charset[15] = {
6'b000000,
6'b011110,
6'b010000,
6'b011100,
6'b010000,
6'b010000,
6'b000000,
6'b000000
};

//assign red = bmp[CounterY[2:0]][16-CounterX[4:1]];
//assign green = bmp[CounterY[2:0]][16-CounterX[4:1]];
//assign blue = bmp[CounterY[2:0]][16-CounterX[4:1]];

wire cg = (chargen_out);
wire blank = (CounterX < 144*2);
wire [7:0] en = {~blank, ~blank, ~blank, ~blank, ~blank, ~blank, ~blank, ~blank};
assign red[7:0] = {cg, cg, cg, cg, cg, cg, cg, cg};// & ({frame_count[8:5], 2'b0000}) & en;
assign green[7:0] = (CounterX[8:1] + frame_count[17:10])& en;
assign blue[7:0] = (CounterY[7:0] - frame_count[23:16])& en;

reg chargen_out;
reg [3:0] col_cnt, row_cnt;
reg [7:0] char_cntX, char_cntY;

wire visible = (CounterX >= 160*2) && ( CounterY >= 45);

always @(posedge clk)
begin
	if ((CounterY < 35) || rst_n == 0)
	begin
		col_cnt <= 0;
		char_cntX <= 0;
		row_cnt <= 0;
		char_cntY <= 0;
	end
	else
	begin
	//column logic
		if((CounterX < 144*2))
		begin
			col_cnt <= 0;
			char_cntX <= 0;
		end
		else if(CounterX[0])
		begin
			col_cnt <= col_cnt;
			char_cntX <= char_cntX;
		end		
		else if(col_cnt == 5)
		begin
			col_cnt <= 0;
			char_cntX <= char_cntX + 1;
		end
		else
		begin
			col_cnt <= col_cnt + 1;
			char_cntX <= char_cntX;
		end

	// row logic
		if(CounterXmaxed)
		begin
			if(row_cnt == 7)
			begin
				row_cnt <= 0;
				char_cntY <= char_cntY + 1;
			end
			else if(CounterY[0])
			begin
				row_cnt <= row_cnt;
				char_cntX <= char_cntX;
			end
			else
			begin
				row_cnt <= row_cnt + 1;
				char_cntY <= char_cntY;
			end
		end
		else
		begin
			row_cnt <= row_cnt;
			char_cntY <= char_cntY;
		end
	end
	chargen_out <= charset[char_cntX[3:0]][(5-col_cnt) + (7 - row_cnt) *6];
end

endmodule