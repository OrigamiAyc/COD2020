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
		input [31:0] Data_Bus_Receive,
		input [1:0] Status_Bus_Receive,
		output launch,
		output Device_Choose,					// 0 for SWITCH, 1 for LED
		output catch,
		output [31:0] Data_Bus_Send
	);

	localparam [5:0] R_TYPE = 6'b000000;
	localparam [5:0] LW = 6'b100011;
	localparam [5:0] SW = 6'b101011;
	localparam [5:0] BEQ = 6'b000100;
	localparam [5:0] BNE = 6'b000101;
	localparam [5:0] J_TYPE = 6'b000010;
	localparam [5:0] ADDI = 6'b001000;
	localparam LED = 1'b1;
	localparam SWITCH = 1'b0;

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
	wire [WIDTH-1:0] real_mem_out;				// choose from mem result and I/O result, MEM stage
	wire real_memwrite;							// if MemWrite_EM (is SW) and not to I/O, than it's real, MEM stage
	wire IO_Stall;								// if need to stall in case of waiting I/O, MEM stage

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
		.in_1(ALU_result),
		.in_2(real_mem_out),
		.out(write_data)
	);

	assign npc = PC + 32'd4;
	// always @(posedge clk) begin			// pre-load
	// 	NPC = PC + 32'd4;
	// end

	// inst of a reg_pile, ID
	reg_file register_file (
		.clk(clk),
		.ra0(ins_reg_1),
		.ra1(ins_reg_2),
		.wa(ins_reg_write),
		.rd0(read_data_1),
		.rd1(read_data_2),
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
			6'b000101: begin			// bne
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
			2'b01: begin				// BEQ & BNE
				alu_ctrl = 3'b110;
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

	assign PCSrc = (ins_ctrl == BNE) ? (~ALU_Zero & Branch) : (ALU_Zero & Branch);
	assign beq_result = npc + {extend_addr[29:0], 2'b00};
	
	// MEM
	assign real_memwrite = MemWrite & ~ALU_result[15];	// if ALU_result[15] or Imme[15] is 1, then go to I/O
	assign real_mem_out = ALU_result[15] ? Data_Bus_Receive : Mem_Out;
	assign launch = ALU_result[15];
	assign Device_Choose = MemWrite ? LED : SWITCH;
	// CAUTION: this stall should be done on ALL FOUR stage-registers and PC
	assign IO_Stall = (launch & ~(Status_Bus_Receive == 2'b10)) & (ins_ctrl == LW);
	assign catch = launch & (Status_Bus_Receive == 2'b10);
	assign Data_Bus_Send = read_data_2;

	wire [8:0] read_mem_addr;
	assign read_mem_addr = ALU_result[10:2];
	dist_data_ram memory (
		.a(read_mem_addr),
		.d(read_data_2),
		.clk(clk),
		.we(real_memwrite),
		.spo(Mem_Out)
	);

	// change PC
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			PC = 32'b0;
		end
		else if (~IO_Stall) begin
			PC = fin_npc;
		end
		else begin
			PC = PC;
		end
	end

endmodule
