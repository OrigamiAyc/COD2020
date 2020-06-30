`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/22 03:20:16
// Design Name: 
// Module Name: multi_mux
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


module multi_mux
	#(parameter WIDTH = 32)
	(
		input [1:0] n,			// select depth, from 0~3
		input [1:0] m,			// control signal
		input [WIDTH-1:0] in_0, in_1, in_2, in_3,
		output reg [WIDTH-1:0] out
	);

	always @(*) begin
		case (m)
			2'b00: out = in_0;
			2'b01: out = in_1;
			2'b10: out = in_2;
			2'b11: out = (n == 2'd2) ? 'dz : in_3;
			default: out = 'dz;
		endcase
	end
endmodule
