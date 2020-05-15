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
// different blocks of structurs are defined separately
module sin_CPU
	#(parameter WIDTH = 32)
	(
		input clk, rst,
		input run,
		input [7:0] m_rf_addr,
		input [2:0] sel,					// to select which to show
		output [11:0] status,
		output [WIDTH-1:0] m_data,
		output [WIDTH-1:0] rf_data,
		output reg [WIDTH-1:0] selected_data
	);

	reg [WIDTH-1:0] PC;					// program counter
	// reg [WIDTH-1:0] NPC;				// new PC
	reg [2:0] alu_ctrl;					// ALU_ctrl
	reg regdst, jump, branch, memread, memtoreg, memwrite, alusrc, regwrite;
	reg [1:0] aluop;

	// comments are on the circuit
	wire [7:0] pc_addr;
	wire [WIDTH-1:0] npc, fin_npc;
	wire [WIDTH-1:0] ins;
	wire [5:0] ins_ctrl;
	wire [4:0] ins_reg_1, ins_reg_2, ins_reg_3, ins_reg_write;
	wire [15:0] imme_addr;
	wire [WIDTH-1:0] read_data_1, read_data_2, write_data;
	wire [WIDTH-1:0] extend_addr;
	wire [WIDTH-1:0] jump_addr;
	wire RegDst, RegWrite, ALUSrc, MemRead, MemWrite, MemtoReg, Branch, PCSrc, Jump;
	wire [1:0] ALUOp;
	wire [WIDTH-1:0] ALU_a, ALU_b, ALU_result;
	wire ALU_Zero;
	wire [2:0] ALU_ctrl;
	wire cf, of, sf;
	wire [WIDTH-1:0] beq_result, not_jump;
	wire [WIDTH-1:0] Mem_Out;
	wire [4:0] DBU_rf_addr;				// from m_rf_addr, to visit reg_file

	assign pc_addr = PC[9:2];
	// assign npc = NPC;
	assign RegDst = regdst;
	assign RegWrite = regwrite;
	assign ALUSrc = alusrc;
	assign MemRead = memread;
	assign MemWrite = memwrite;
	assign MemtoReg = memtoreg;
	assign Branch = branch;
	assign Jump = jump;
	assign ALUOp = aluop;
	assign status = {jump, branch, regdst, regwrite, memtoreg, memwrite, alu_ctrl, alusrc, ALU_Zero};
	assign DBU_rf_addr = m_rf_addr[4:0];

	// inst of a program
	dist_inst_rom instruction(
		.a(pc_addr),
		.spo(ins)
	);

	// for the MUX at the entrance of reg_pile
	mux #(5) mux_reg (
		.m(RegDst),
		.in_1(ins_reg_2),
		.in_2(ins_reg_3),
		.out(ins_reg_write)
	);

	// for the MUX at the entrance of ALU
	mux #(32) mux_alu (
		.m(ALUSrc),
		.in_1(read_data_2),
		.in_2(extend_addr),
		.out(ALU_b)
	);

	mux #(32) mux_beq (
		.m(PCSrc),
		.in_1(npc),
		.in_2(beq_result),
		.out(not_jump)
	);

	mux #(32) mux_jump (
		.m(Jump),
		.in_1(not_jump),
		.in_2(jump_addr),
		.out(fin_npc)
	);

	mux #(32) mux_wb (
		.m(MemtoReg),
		.in_1(Mem_Out),
		.in_2(ALU_result),
		.out(write_data)
	);

	assign npc = PC + 32'd4;
	// always @(posedge clk) begin			// pre-load
	// 	NPC = PC + 32'd4;
	// end

	// inst of a reg_pile, IF
	reg_file register_file (
		.clk(clk),
		.ra0(ins_reg_1),
		.ra1(ins_reg_2),
		.ra2(DBU_rf_addr),
		.wa(ins_reg_write),
		.rd0(read_data_1),
		.rd1(read_data_2),
		.rd2(rf_data),
		.wd(write_data),
		.we(RegWrite)
	);

	// ID
	assign ins_ctrl = ins[WIDTH-1:26];
	assign ins_reg_1 = ins[25:21];
	assign ins_reg_2 = ins[20:16];
	assign ins_reg_3 = ins[15:11];
	assign imme_addr = ins[15:0];
	// sign extend
	assign extend_addr = {((imme_addr[15]) ? 16'hffff : 16'h0000), imme_addr};
	// jump addr
	assign jump_addr = {npc[31:28], ins[25:0], 2'b00};

	// control unit
	always @(*) begin
		{regdst, jump, branch, memread, memtoreg, alusrc, regwrite, memwrite, aluop} = 10'b0;
		case (ins[31:26])
			6'b000000: begin			// R-type
				regdst = 1'b1;
				regwrite = 1'b1;
				aluop = 2'b10;
			end
			6'b100011: begin			// lw
				alusrc = 1'b1;
				memtoreg = 1'b1;
				regwrite = 1'b1;
				memread = 1'b1;
			end
			6'b101011: begin			// sw
				alusrc = 1'b1;
				memwrite = 1'b1;
			end
			6'b000100: begin			// beq
				branch = 1'b1;
				aluop = 2'b01;
			end
			6'b001000: begin			// addi
				alusrc = 1'b1;
				regwrite = 1'b1;
			end
			6'b000010: begin			// jump
				jump = 1'b1;
			end
			default: {regdst, jump, branch, memread, memtoreg, alusrc, regwrite, memwrite, aluop} = 'dz;
		endcase
	end

	// ALU control
	assign ALU_ctrl = alu_ctrl;
	always @(*) begin
		case (ALUOp)
			2'b00: begin				// LW & SW
				alu_ctrl = 3'b010;
			end
			2'b01: begin				// BEQ
				alu_ctrl = 3'b010;
			end
			2'b10: begin				// R-type
				case (ins[5:0])
					6'b100000: begin	// add
						alu_ctrl = 3'b010;
					end
					6'b100010: begin	// sub
						alu_ctrl = 3'b110;
					end
					6'b100100: begin	// and
						alu_ctrl = 3'b000;
					end
					6'b100101: begin	// or
						alu_ctrl = 3'b001;
					end
					6'b101010: begin	// slt
						alu_ctrl = 3'b111;
					end
					default: alu_ctrl = 'dz;
				endcase
			end
			default: alu_ctrl = 'dz;
		endcase
	end

	// EX
	assign ALU_a = read_data_1;
	ALU alu (
		.y(ALU_result),
		.zf(ALU_Zero),
		.cf(cf),
		.of(of),
		.sf(sf),
		.a(ALU_a),
		.b(ALU_b),
		.m(ALU_ctrl)
	);

	assign PCSrc = ALU_Zero & Branch;
	assign beq_result = npc + {extend_addr[29:0], 2'b00};
	
	// MEM
	dist_data_ram memory (
		.a(ALU_result),
		.d(read_data_2),
		.dpra(m_rf_addr),
		.clk(clk),
		.we(MemWrite),
		.spo(Mem_Out),
		.dpo(m_data)
	);

	// change PC
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			PC = 32'b0;
		end
		else if (run) begin
			PC = fin_npc;
		end
		else begin
			PC = PC;
		end
	end

	// for DBU
	always @(*) begin
		case (sel)
			3'd1: selected_data = PC;
			3'd2: selected_data = npc;
			3'd3: selected_data = ins;
			3'd4: selected_data = read_data_1;
			3'd5: selected_data = read_data_2;
			3'd6: selected_data = ALU_result;
			3'd7: selected_data = Mem_Out;
			default: selected_data = 'dz;
		endcase
	end
endmodule
