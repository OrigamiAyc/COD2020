`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/28 04:14:04
// Design Name: 
// Module Name: SW
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


module SW
	(
		input clk, rst,
		input button_real,
		input [15:0] SW_real,
		output button,
		output [15:0] SW_out
	);

	wire button_clr, button_edge;

	jitter_clr clr_button (
		.clk(clk),
		.button(button_real),
		.button_clean(button_clr)
	);

	signal_edge edge_button (
		.clk(clk),
		.button(button_clr),
		.button_edge(button_edge)
	);

	assign button = button_edge;
	assign SW_out = SW_real;
endmodule
