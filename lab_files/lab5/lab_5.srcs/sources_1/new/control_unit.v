`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2020/05/23 09:30:05
// Design Name:
// Module Name: control_unit
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


module control_unit(
	input clk,
	input [5:0] op,
	output reg MemtoReg, RegDst,
	output reg [1:0] ALUOp,
	output reg MemRead, MemWrite,
	output reg IFFlush, RegWrite, AluSrc,
	output reg Jump, Branch
	);

	always @(*) begin
		{RegDst, Jump, Branch, MemRead, MemtoReg, RegWrite, MemWrite, ALUOp, IFFlush, AluSrc} = 11'b0;
		case (op)
			6'b000000: begin			// R-type
				RegDst = 1'b1;
				RegWrite = 1'b1;
				ALUOp = 2'b10;
			end
			6'b100011: begin			// lw
				AluSrc = 1'b1;
				MemtoReg = 1'b1;
				RegWrite = 1'b1;
				MemRead = 1'b1;
			end
			6'b101011: begin			// sw
				AluSrc = 1'b1;
				MemWrite = 1'b1;
			end
			6'b000100: begin			// beq
				Branch = 1'b1;
				ALUOp = 2'b01;
				IFFlush = 1'b1;
			end
			6'b001000: begin			// addi
				AluSrc = 1'b1;
				RegWrite = 1'b1;
			end
			6'b000010: begin			// Jump
				Jump = 1'b1;
				IFFlush = 1'b1;
			end
			default: {RegDst, Jump, Branch, MemRead, MemtoReg, RegWrite, MemWrite, ALUOp, IFFlush, AluSrc} = 'dz;
		endcase
	end

endmodule
