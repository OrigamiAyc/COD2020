`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/12 11:49:53
// Design Name: 
// Module Name: reg_file
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


module reg_file
	#(parameter WIDTH = 32)
	(
		input clk,
		input [4:0] ra0,			// read port 0 addr
		output [WIDTH-1:0] rd0,		// read port 0 data
		input [4:0] ra1,			// read port 1 addr
		output [WIDTH-1:0] rd1,		// read port 1 data
		input [4:0] wa,				// write port addr
		input we,					// write enable, valid at '1'
		input [WIDTH-1:0] wd		// write port data
	);

	reg [WIDTH-1:0] reg_file [0:31];

	assign rd0 = reg_file[ra0];
	assign rd1 = reg_file[ra1];

	integer i;						// loop varible
	initial begin
		for (i = 0; i < 32; i = i + 1) begin
			reg_file [i] = 0;
		end
	end

	always @(posedge clk) begin
		if (we & wa != 4'b0) begin
			reg_file[wa] = wd;
		end
	end
endmodule
