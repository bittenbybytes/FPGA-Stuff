module mojo_top(
		input clk,
		input rst_n,
		input cclk,
		output [7:0] led,
		output spi_miso,
		input spi_ss,
		input spi_mosi,
		input spi_sck,
		output [3:0] spi_channel,
		input avr_tx,
		output avr_rx,
		input avr_rx_busy,
		// VGA output
		output vga_h_sync,
		output vga_v_sync,
		output [7:0] vga_r,
		output [7:0] vga_g,
		output [7:0] vga_b,
		// my spi module
		output myssel,
		output mysclk,
		output mymosi
	);
	
	wire rst = ~rst_n;
	
	assign spi_miso = 1'bz;
	assign avr_rx = 1'bz;
	assign spi_channel = 4'bzzzz;
	
	reg [31:0] cnt;
	
	assign led = cnt[31:31-8];
	
	always @ (posedge clk)
	begin
	if(rst)
		cnt <= 32'b0;
		else
		cnt <= cnt - 1;
	end
	
	vga_module vga_module (
   .clk(clk),
   .rst_n(rst_n),
	 .red(vga_r),
	 .green(vga_g),
	 .blue(vga_b),
	 .h_sync(vga_h_sync),
	 .v_sync(vga_v_sync)
	 );
	
	wire mymiso = 1'b0;
	
	spi_master myspi_master (
    .clk(clk),
    .rst_n(rst_n),
		.ssel(myssel),
		.sclk(mysclk),
		.mosi(mymosi),
		.miso(mymiso)
		);
	
endmodule