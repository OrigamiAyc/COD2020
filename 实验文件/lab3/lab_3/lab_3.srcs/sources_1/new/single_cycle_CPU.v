`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/12 12:05:36
// Design Name: 
// Module Name: sin_CPU
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


// suppose that there is a MAX_restrict of Instruction number: 256 (IP ROM volume)
module sin_CPU(
	input clk, rst
	);

	reg [7:0] PC; // program counter
	reg [7:0] NPC; // new PC

	wire [7:0] pc_addr;
	wire [31:0] ins;

	assign pc_addr = PC;

	dist_inst_rom instruction(
		.a(pc_addr),
		.spo(ins)
	);

	always @(posedge clk) begin // pre-
		NPC = PC + 1;
	end
endmodule
