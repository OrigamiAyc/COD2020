`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/06 08:29:32
// Design Name: 
// Module Name: tb_queue
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

// `include "fifo.v"
// `default_nettype none

module tb_fifo;
	reg clk, rst, en_in, en_out;
	reg [7:0] din;
	wire [6:0] dout;
	wire [4:0] count;

	fifo queue
	(
		.rst (rst),
		.clk (clk),
		.en_in(en_in),
		.en_out(en_out),
		.din(din),
		.dout(dout),
		.count(count)
	);

	localparam CLK_PERIOD = 10;
	always #(CLK_PERIOD/2) clk = ~clk;

	// initial begin
	//	 dumpfile("tb_fifo.vcd");
	//	 dumpvars(0, tb_fifo);
	// end

	initial begin
		clk = 1;
	end

	initial begin
		rst = 1;
		# CLK_PERIOD rst = 0;
	end

	initial begin
		din = 8'h10;
		# (CLK_PERIOD * 3) din = 8'h01;
		# (CLK_PERIOD * 5) din = 8'hac;
		# (CLK_PERIOD * 2) din = 8'hb4;
		# (CLK_PERIOD * 2) $finish;
	end

	initial begin
		en_in = 0;
		# (CLK_PERIOD) en_in = 1;
		# (CLK_PERIOD) en_in = 0;
		# (CLK_PERIOD) en_in = 1;
		# (CLK_PERIOD) en_in = 0;
		# (CLK_PERIOD * 6) en_in = 1;
		# (CLK_PERIOD) en_in = 0;
		# (CLK_PERIOD) $finish;
	end

	initial begin
		en_out = 0;
		// # (CLK_PERIOD) en_out = 1;
		// # (CLK_PERIOD) en_out = 0;
		# (CLK_PERIOD * 6) en_out = 1;
		# (CLK_PERIOD) en_out = 0;
		# (CLK_PERIOD * 2) en_out = 1;
		# (CLK_PERIOD) en_out = 0;
		# (CLK_PERIOD * 2) $finish;
	end

endmodule
// `default_nettype wire
