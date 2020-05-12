`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/06 06:12:06
// Design Name: 
// Module Name: board
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


module board(
	input clk, rst,
	input [7:0] din,		// data enqueue
	input en_in,			// enqueue enable, valid when '1'
	input en_out,			// dequeue enable, valid when '1'
	output [7:0] dout,		// data dequeue
	output [4:0] count		// data amount count, 5 bits since need to show 0~16
	);

	wire rst_clean, rst_edge, en_in_clean, en_in_edge, en_out_clean, en_out_edge;

	jitter_clr rst_clr (
		.clk(clk),
		.button(rst),
		.button_clean(rst_clean)
	);

	signal_edge rst_ed (
		.clk(clk),
		.button(rst_clean),
		.button_edge(rst_edge)
	);
	
	jitter_clr en_in_clr (
		.clk(clk),
		.button(en_in),
		.button_clean(en_in_clean)
	);

	signal_edge en_in_ed (
		.clk(clk),
		.button(en_in_clean),
		.button_edge(en_in_edge)
	);
	
	jitter_clr en_out_clr (
		.clk(clk),
		.button(en_out),
		.button_clean(en_out_clean)
	);

	signal_edge en_out_ed (
		.clk(clk),
		.button(en_out_clean),
		.button_edge(en_out_edge)
	);
	
	fifo queue (
		.clk(clk),
		.rst(rst_edge),
		.din(din),
		.dout(dout),
		.en_in(en_in_edge),
		.en_out(en_out_edge),
		.count(count)
	);
endmodule
