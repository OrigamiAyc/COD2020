`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/12 14:49:14
// Design Name: 
// Module Name: MUX
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


module mux(
	input m, // control signal
	input [3:0] in_1,in_2,
	output [3:0] out
);
	assign out=(m==0?in_1:in_2);

endmodule // mux
