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
	input clk, rst,
	input [5:0] op,
	output reg PCWriteControl, PCWrite,
	output reg IorD, MemtoReg, RegDst, ALUSrcA,	// ctrl sig for MUX
	output reg [1:0] ALUSrcB, ALUOp, PCSource,
	output reg MemRead, MemWrite,
	output reg IRWrite, RegWrite
	);

	parameter [3:0] INSTRUCTION_FETCH = 4'd0;
	parameter [3:0] INSTRUSTION_DECODE_REGISTER_FETCH = 4'd1;
	parameter [3:0] MEMORY_ADDRESS_COMPUTATION = 4'd2;
	parameter [3:0] MEMORY_ACCESS_READ = 4'd3;
	parameter [3:0] WRITE_BACK_STEP = 4'd4;
	parameter [3:0] MEMORY_ACCESS_WRITE = 4'd5;
	parameter [3:0] EXECUTION = 4'd6;
	parameter [3:0] R_TYPE_COMPLETION = 4'd7;
	parameter [3:0] BRANCH_COMPLETION = 4'd8;
	parameter [3:0] JUMP_COMPLETION = 4'd9;
	parameter [3:0] ADDI_WRITE_BACK = 4'd10;

	parameter [2:0] R_TYPE = 3'd0;
	parameter [2:0] LW = 3'd1;
	parameter [2:0] SW = 3'd2;
	parameter [2:0] BEQ = 3'd3;
	parameter [2:0] J_TYPE = 3'd4;
	parameter [2:0] ADDI = 3'd5;

	parameter [2:0] IF = 3'd0;
	parameter [2:0] ID = 3'd1;
	parameter [2:0] EX = 3'd2;
	parameter [2:0] MEM = 3'd3;
	parameter [2:0] WB = 3'd4;

	reg [3:0] curr_state, next_state;
	reg [2:0] ins_type;

	always @(*) begin
		case (op)
			6'b000000: ins_type = R_TYPE;
			6'b100011: ins_type = LW;
			6'b101011: ins_type = SW;
			6'b000100: ins_type = BEQ;
			6'b000010: ins_type = J_TYPE;
			6'b001000: ins_type = ADDI;
			default: ins_type = 'dz;
		endcase
	end

	// FSM
	always @(posedge clk) begin
		if (rst) begin
			curr_state <= INSTRUCTION_FETCH;
		end else begin
			curr_state <= next_state;
		end
	end

	always @(*) begin
		case (curr_state)
			INSTRUCTION_FETCH: next_state = INSTRUSTION_DECODE_REGISTER_FETCH;
			INSTRUSTION_DECODE_REGISTER_FETCH: begin
				case (ins_type)
					R_TYPE: next_state = EXECUTION;
					LW: next_state = MEMORY_ADDRESS_COMPUTATION;
					SW: next_state = MEMORY_ADDRESS_COMPUTATION;
					BEQ: next_state = BRANCH_COMPLETION;
					J_TYPE: next_state = JUMP_COMPLETION;
					ADDI: next_state = MEMORY_ADDRESS_COMPUTATION;
					default: next_state = 'dz;
				endcase
			end
			MEMORY_ADDRESS_COMPUTATION: begin
				if (ins_type == LW) begin
					next_state = MEMORY_ACCESS_READ;
				end
				else if (ins_type == SW) begin
					next_state = MEMORY_ACCESS_WRITE;
				end
				else begin										// addi
					next_state = ADDI_WRITE_BACK;
				end
			end
			MEMORY_ACCESS_READ: next_state = WRITE_BACK_STEP;
			WRITE_BACK_STEP: next_state = INSTRUCTION_FETCH;
			MEMORY_ACCESS_WRITE: next_state = INSTRUCTION_FETCH;
			EXECUTION: next_state = R_TYPE_COMPLETION;
			R_TYPE_COMPLETION: next_state = INSTRUCTION_FETCH;
			BRANCH_COMPLETION: next_state = INSTRUCTION_FETCH;
			JUMP_COMPLETION: next_state = INSTRUCTION_FETCH;
			ADDI_WRITE_BACK: next_state = INSTRUCTION_FETCH;
			default: next_state = 'dz;
		endcase
	end

	// ctrl sig
	always @(*) begin
		{PCWriteControl, PCWrite, IorD, MemRead, MemWrite, MemtoReg, IRWrite, PCSource, ALUOp, ALUSrcB, ALUSrcA, RegWrite, RegDst} = 16'b0;
		case (curr_state)
			INSTRUCTION_FETCH: begin
				MemRead = 1;
				IRWrite = 1;
				ALUSrcB = 2'b01;
				PCWrite = 1;
			end
			INSTRUSTION_DECODE_REGISTER_FETCH: begin
				ALUSrcB = 2'b11;
			end
			MEMORY_ADDRESS_COMPUTATION: begin
				ALUSrcA = 1;
				ALUSrcB = 2'b10;
			end
			MEMORY_ACCESS_READ: begin
				MemRead = 1;
				IorD = 1;
			end
			WRITE_BACK_STEP: begin
				RegWrite = 1;
				MemtoReg = 1;
			end
			MEMORY_ACCESS_WRITE: begin
				MemWrite = 1;
				IorD = 1;
			end
			EXECUTION: begin
				ALUSrcA = 1;
				ALUOp = 2'b10;
			end
			R_TYPE_COMPLETION: begin
				RegDst = 1;
				RegWrite = 1;
			end
			BRANCH_COMPLETION: begin
				ALUSrcA = 1;
				ALUOp = 2'b01;
				PCWriteControl = 1;
				PCSource = 2'b01;
			end
			JUMP_COMPLETION: begin
				PCWrite = 1;
				PCSource = 2'b10;
			end
			ADDI_WRITE_BACK: begin
				RegWrite = 1;
			end
			default: {PCWriteControl, PCWrite, IorD, MemRead, MemWrite, MemtoReg, IRWrite, PCSource, ALUOp, ALUSrcB, ALUSrcA, RegWrite, RegDst} = 'dz;
		endcase
	end
endmodule
