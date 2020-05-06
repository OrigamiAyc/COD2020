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

    );
	
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
endmodule
