`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/06 15:04:40
// Design Name: 
// Module Name: tb_reg
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_reg;
	reg clk, we;
	reg [4:0] ra0, ra1, wa;
	reg [31:0] wd;
	wire [31:0] rd0, rd1;

	register_file regis (
		.clk(clk),
		.ra0(ra0),
		.rd0(rd0),
		.ra1(ra1),
		.rd1(rd1),
		.wa(wa),
		.we(we),
		.wd(wd)
	);

	localparam CLK_PERIOD = 1;
	always #(CLK_PERIOD/2) clk = ~clk;

	initial begin
		clk = 1;
	end

	initial begin
		we = 1;
		#CLK_PERIOD we = 0;
		#(CLK_PERIOD * 4) we = 1;
		#(CLK_PERIOD) we = 0;
		#(CLK_PERIOD * 3) we = 1;
		#CLK_PERIOD we = 0;
		#(CLK_PERIOD) $finish;
	end

	initial begin
		wa = 4'b0;
		#(CLK_PERIOD * 3) wa = 4'h1;
		#(CLK_PERIOD * 3) wa = 4'h2;
		#(CLK_PERIOD * 3) wa = 4'h3;
		#(CLK_PERIOD) wa = 4'h4;
		#(CLK_PERIOD) $finish;
	end

	initial begin
		ra0 = 4'b0;
		#(CLK_PERIOD * 2) ra0 = 4'b1;
		#(CLK_PERIOD * 2) ra0 = 4'b0;
		#(CLK_PERIOD * 4) ra0 = 4'b2;
		#(CLK_PERIOD * 3) ra0 = 4'b1;
		$finish;
	end

	initial begin
		ra1 = 4'b0;
		#(CLK_PERIOD * 2) ra1 = 4'b1;
		#(CLK_PERIOD * 2) ra1 = 4'b2;
		#(CLK_PERIOD * 4) ra1 = 4'b3;
		#(CLK_PERIOD * 3) ra1 = 4'b4;
		$finish;
	end

	initial begin
		wd = 32'h0;
		#(CLK_PERIOD * 2) wd = 32'd1;
		#(CLK_PERIOD * 3) wd = 32'd3;
		#(CLK_PERIOD * 3) wd = 32'd4;
		#(CLK_PERIOD * 3) $finish;
	end
endmodule
