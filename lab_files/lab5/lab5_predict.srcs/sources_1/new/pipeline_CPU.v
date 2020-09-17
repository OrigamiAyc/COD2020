`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/28 13:11:06
// Design Name: 
// Module Name: pipeline_CPU
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


module pipeline_CPU
	#(parameter WIDTH = 32)
	(
		input clk, rst
	);

	localparam [5:0] R_TYPE = 6'b000000;
	localparam [5:0] LW = 6'b100011;
	localparam [5:0] SW = 6'b101011;
	localparam [5:0] BEQ = 6'b000100;
	localparam [5:0] BNE = 6'b000101;
	localparam [5:0] J_TYPE = 6'b000010;
	localparam [5:0] ADDI = 6'b001000;

	localparam [2:0] TAKEN_DEEP = 3'b000;
	localparam [2:0] TAKEN_SHALLOW = 3'b001;
	localparam [2:0] NOT_SHALLOW = 3'b010;
	localparam [2:0] NOT_DEEP = 3'b011;
	localparam [2:0] UNDEFINED = 3'b100;

	reg [WIDTH-1:0] NPC, IR;					// IF/ID inter-stages register
	reg IF_TAKEN;								// IF/ID inter-stages register
	reg [WIDTH-1:0] A, B, IMM, RS, RT, RD;		// ID/EX inter-stages register
	// WAE for WB_address_from_EX_stage
	reg [WIDTH-1:0] ALUOut, WMD;				// EX/MEM inter-stages register
	reg [4:0] WAE;								// EX/MEM inter-stages register
	// MDR for mem_data_reg, ADR for ALUout_data_reg, WAM for WB_address_from_MEM_stage
	reg [WIDTH-1:0] MDR, ADR;					// MEM/WB inter-stages register
	reg [4:0] WAM;								// MEM/WB inter-stages register

	reg [WIDTH-1:0] br_pred_buf [0:7];			// branch prediction buffer, FIFO algorithm
	reg [2:0] FSM_call;							// to call which FSM
	reg [1:0] curr_FSM_cnt_BEQ, next_FSM_cnt_BEQ;		// copy new NPC of beq to which buffer
	reg [1:0] curr_FSM_cnt_BNE, next_FSM_cnt_BNE;		// copy new NPC of beq to which buffer
	reg [2:0] clr_sig;							// when the buffer is updated, the FSM state of that block should also be UNDEFINED
	reg [WIDTH-1:0] PC;

	wire [WIDTH-1:0] npc;						// PC+4, IF stage
	wire [WIDTH-1:0] ir;						// output of Instruction Mem, IF stage
	wire [WIDTH-1:0] real_npc;					// after branch prediction, IF stage
	wire [WIDTH-1:0] extend_addr;				// Sign extended addr (for beq), IF stage
	wire [WIDTH-1:0] pc_predict;				// BEQ addr, IF stage
	wire if_taken_0, if_taken_1, if_taken_2, if_taken_3;	// for BEQ FSM out, IF stage
	wire if_taken_4, if_taken_5, if_taken_6, if_taken_7;	// for BNE FSM out, IF stage
	wire [WIDTH-1:0] jump_addr;					// JUMP addr, ID stage
	wire [WIDTH-1:0] not_jump, PC_final;		// Branch complete, ID stage
	wire [9:0] haz;								// IR for Hazard Detection Unit, ID stage
	wire [5:0] op;								// IR for Control Unit, ID stage
	wire [WIDTH-1:0] a, b;						// register file read ports, ID stage
	wire [WIDTH-1:0] extend_imme;				// Sign extended imme, ID stage
	wire [WIDTH-1:0] shift_left, pc_beq;		// BEQ addr, IF stage
	wire [15:0] beq_forward;					// containing op, rs, rt infro, used in Forwarding Unit, ID stage
	wire [WIDTH-1:0] addr_imme;					// the same as 'extend_imme', EX stage
	wire [4:0] rs, rt, rd;						// ID fragments, EX stage
	wire [5:0] func;							// for ALU Control Unit, EX stage
	wire [WIDTH-1:0] alu_a, alu_b, alu_result;	// ALU input/output, EX stage
	wire ALU_Zero, cf, of, sf;					// for unused ports of ALU, EX stage
	wire [WIDTH-1:0] final_b;
	wire [4:0] rw_addr;							// chosen register write addr, EX stage
	wire [WIDTH-1:0] mem_out;					// MEM_IP out, MEM_stage
	wire [WIDTH-1:0] reg_data;					// WB stage
	wire [4:0] reg_addr;						// WB stage

	// Control Signals, definations & inter-stages
	reg [1:0] pred_curr_state, pred_next_state;	// for pridiction unit FSM, IF stage
	reg if_taken;								// if branch is taken, FSM, IF stage
	reg choose_0, choose_1, choose_2, choose_3;	// choose which FSM, will change condition
	reg clear_0, clear_1, clear_2, clear_3;		// clear which FSM, since it's been kicked out
	reg choose_4, choose_5, choose_6, choose_7;	// choose which FSM, will change condition
	reg clear_4, clear_5, clear_6, clear_7;		// clear which FSM, since it's been kicked out
	reg [1:0] ALUOp, ForwardA, ForwardB, ALU_MUX;
	reg [2:0] ALU_Ctrl, ForwardReg;
	reg PCwe;									// the Boss PC Write control, IF stage
	reg RegDst, AluSrc, MemRead, MemWrite, MemtoReg, RegWrite;
	reg Branch, Jump;
	reg FDWrite, ControlFlush, IFFlush;
	reg [1:0] ALUOp_DE;
	reg AluSrc_DE, RegDst_DE, MemRead_DE, MemWrite_DE, MemtoReg_DE, RegWrite_DE;
	reg MemRead_EM, MemWrite_EM, MemtoReg_EM, RegWrite_EM;
	reg MemtoReg_MW, RegWrite_MW;

	// Control Signals, in use, assigned from stage_regs
	wire Zero, PCSrc, PCSrc_predict_fail;

	assign op = IR[31:26];
	assign haz = IR[25:16];
	assign extend_imme = {((IR[15]) ? 16'hffff : 16'h0000), IR[15:0]};
	assign beq_forward = IR[31:16];
	assign rs = RS;
	assign rt = RT;
	assign rd = RD;
	assign addr_imme = IMM;
	assign reg_addr = WAM;

	// IF
	always @(posedge clk) begin
		if (rst) begin
			PC <= 0;
		end
		else if (PCwe) begin
			PC <= PC_final;
		end
		else
			PC <= PC;
	end

	assign npc = PC + 4;
	assign PCSrc_predict_fail = PCSrc ^ IF_TAKEN;

	mux MUX_BEQ (
		.m(PCSrc_predict_fail),
		.in_0(real_npc),
		.in_1(PCSrc_predict_fail ? (IF_TAKEN ? NPC : pc_beq) : real_npc),
		.out(not_jump)
	);

	mux MUX_JUMP (
		.m(Jump),
		.in_0(not_jump),
		.in_1(jump_addr),
		.out(PC_final)
	);

	dist_inst_rom instruction (
		.a(PC[9:2]),
		.spo(ir)
	);

	assign extend_addr = {((ir[15]) ? 16'hffff : 16'h0000), ir[15:0]};
	assign pc_predict = (extend_addr << 2) + npc;

	mux MUX_PREDICTION (
		.m(if_taken),
		.in_0(npc),
		.in_1(pc_predict),
		.out(real_npc)
	);

	always @(*) begin
		if (ir[31:26] == BEQ || npc == br_pred_buf[0]) begin
			FSM_call = 3'd0;
		end
		else if (ir[31:26] == BEQ || npc == br_pred_buf[1]) begin
			FSM_call = 3'd1;
		end
		else if (ir[31:26] == BEQ || npc == br_pred_buf[2]) begin
			FSM_call = 3'd2;
		end
		else if (ir[31:26] == BEQ || npc == br_pred_buf[3]) begin
			FSM_call = 3'd3;
		end
		else if (ir[31:26] == BNE || npc == br_pred_buf[4]) begin
			FSM_call = 3'd4;
		end
		else if (ir[31:26] == BNE || npc == br_pred_buf[5]) begin
			FSM_call = 3'd5;
		end
		else if (ir[31:26] == BNE || npc == br_pred_buf[6]) begin
			FSM_call = 3'd6;
		end
		else if (ir[31:26] == BNE || npc == br_pred_buf[7]) begin
			FSM_call = 3'd7;
		end
		else begin
			FSM_call = 'dz;
		end
	end

	always @(*) begin
		if_taken = 0;
		case (FSM_call)
			3'd0: begin
				if_taken = if_taken_0;
			end
			3'd1: begin
				if_taken = if_taken_1;
			end
			3'd2: begin
				if_taken = if_taken_2;
			end
			3'd3: begin
				if_taken = if_taken_3;
			end
			3'd4: begin
				if_taken = if_taken_4;
			end
			3'd5: begin
				if_taken = if_taken_5;
			end
			3'd6: begin
				if_taken = if_taken_6;
			end
			3'd7: begin
				if_taken = if_taken_7;
			end
			default: if_taken = 0;
		endcase
	end

	Prediction_BEQ prediction_0 (
		.clk(clk),
		.rst(rst),
		.PCSrc(PCSrc),
		.write_en(choose_0),
		.clear(clear_0),
		.if_taken(if_taken_0)
	);

	Prediction_BEQ prediction_1 (
		.clk(clk),
		.rst(rst),
		.PCSrc(PCSrc),
		.write_en(choose_1),
		.clear(clear_1),
		.if_taken(if_taken_1)
	);

	Prediction_BEQ prediction_2 (
		.clk(clk),
		.rst(rst),
		.PCSrc(PCSrc),
		.write_en(choose_2),
		.clear(clear_2),
		.if_taken(if_taken_2)
	);

	Prediction_BEQ prediction_3 (
		.clk(clk),
		.rst(rst),
		.PCSrc(PCSrc),
		.write_en(choose_3),
		.clear(clear_3),
		.if_taken(if_taken_3)
	);

	Prediction_BNE prediction_4 (
		.clk(clk),
		.rst(rst),
		.PCSrc(PCSrc),
		.write_en(choose_4),
		.clear(clear_4),
		.if_taken(if_taken_4)
	);

	Prediction_BNE prediction_5 (
		.clk(clk),
		.rst(rst),
		.PCSrc(PCSrc),
		.write_en(choose_5),
		.clear(clear_5),
		.if_taken(if_taken_5)
	);

	Prediction_BNE prediction_6 (
		.clk(clk),
		.rst(rst),
		.PCSrc(PCSrc),
		.write_en(choose_6),
		.clear(clear_6),
		.if_taken(if_taken_6)
	);

	Prediction_BNE prediction_7 (
		.clk(clk),
		.rst(rst),
		.PCSrc(PCSrc),
		.write_en(choose_7),
		.clear(clear_7),
		.if_taken(if_taken_7)
	);

	// IF/ID inter-stages registers
	always @(posedge clk) begin
		if (IFFlush || rst) begin
			NPC <= 0;
			IR <= 0;
			IF_TAKEN <= 0;
		end
		else begin
			if (FDWrite) begin
				NPC <= npc;
				IR <= ir;
				IF_TAKEN <= if_taken;
			end
			else begin
				NPC <= NPC;
				IR <= IR;
				IF_TAKEN <= IF_TAKEN;
			end
		end
	end

	// ID
	reg_file registers (
		.clk(clk),
		.forward(ForwardReg),
		.ex(alu_result),
		.mem(mem_out),
		.ra0(IR[25:21]),
		.ra1(IR[20:16]),
		.rd0(a),
		.rd1(b),
		.wa(reg_addr),
		.wd(reg_data),
		.we(RegWrite_MW)
	);

	// for BEQ, BNE and Jump
	assign Zero = (a == b) ? 1'b1 : 1'b0;
	assign shift_left = extend_imme << 2;
	assign pc_beq = shift_left + NPC;
	assign jump_addr = {NPC[31:28], IR[25:0], 2'b00};

	// Prediction Unit
	// Record NPC for easier
	initial begin
		br_pred_buf[0] = 'dz;
		br_pred_buf[1] = 'dz;
		br_pred_buf[2] = 'dz;
		br_pred_buf[3] = 'dz;
		br_pred_buf[4] = 'dz;
		br_pred_buf[5] = 'dz;
		br_pred_buf[6] = 'dz;
		br_pred_buf[7] = 'dz;
		curr_FSM_cnt_BEQ = 2'd0;
		next_FSM_cnt_BEQ = 2'd0;
		curr_FSM_cnt_BNE = 2'd0;
		next_FSM_cnt_BNE = 2'd0;
	end

	always @(*) begin
		{choose_0, choose_1, choose_2, choose_3, choose_4, choose_5, choose_6, choose_7} = 0;
		if (op == BEQ) begin
			if (NPC != br_pred_buf[0] && NPC != br_pred_buf[1] &&
				NPC != br_pred_buf[2] && NPC != br_pred_buf[3])
			// new beq's PC+4 
			begin
				br_pred_buf[curr_FSM_cnt_BEQ] = NPC;
				next_FSM_cnt_BEQ = curr_FSM_cnt_BEQ + 1;
				clr_sig = curr_FSM_cnt_BEQ;
			end
			else if (NPC == br_pred_buf[0]) begin
				next_FSM_cnt_BEQ = next_FSM_cnt_BEQ;
				clr_sig = 'dz;
				choose_0 = 1;
			end
			else if (NPC == br_pred_buf[1]) begin
				next_FSM_cnt_BEQ = next_FSM_cnt_BEQ;
				clr_sig = 'dz;
				choose_1 = 1;
			end
			else if (NPC == br_pred_buf[2]) begin
				next_FSM_cnt_BEQ = next_FSM_cnt_BEQ;
				clr_sig = 'dz;
				choose_2 = 1;
			end
			else if (NPC == br_pred_buf[3]) begin
				next_FSM_cnt_BEQ = next_FSM_cnt_BEQ;
				clr_sig = 'dz;
				choose_3 = 1;
			end
		end
		else if (op == BNE) begin
			if (NPC != br_pred_buf[4] && NPC != br_pred_buf[5] &&
				NPC != br_pred_buf[6] && NPC != br_pred_buf[7])
			// new beq's PC+4 
			begin
				br_pred_buf[curr_FSM_cnt_BNE + 4] = NPC;
				next_FSM_cnt_BNE = curr_FSM_cnt_BNE + 1;
				clr_sig = curr_FSM_cnt_BNE + 4;
			end
			else if (NPC == br_pred_buf[4]) begin
				next_FSM_cnt_BNE = next_FSM_cnt_BNE;
				clr_sig = 'dz;
				choose_4 = 1;
			end
			else if (NPC == br_pred_buf[5]) begin
				next_FSM_cnt_BNE = next_FSM_cnt_BNE;
				clr_sig = 'dz;
				choose_5 = 1;
			end
			else if (NPC == br_pred_buf[6]) begin
				next_FSM_cnt_BNE = next_FSM_cnt_BNE;
				clr_sig = 'dz;
				choose_6 = 1;
			end
			else if (NPC == br_pred_buf[7]) begin
				next_FSM_cnt_BNE = next_FSM_cnt_BNE;
				clr_sig = 'dz;
				choose_7 = 1;
			end
		end
		else begin
			// not branch instruction, no need for prediction
			br_pred_buf[0] = br_pred_buf[0];
			br_pred_buf[1] = br_pred_buf[1];
			br_pred_buf[2] = br_pred_buf[2];
			br_pred_buf[3] = br_pred_buf[3];
			br_pred_buf[4] = br_pred_buf[4];
			br_pred_buf[5] = br_pred_buf[5];
			br_pred_buf[6] = br_pred_buf[6];
			br_pred_buf[7] = br_pred_buf[7];
			next_FSM_cnt_BEQ = next_FSM_cnt_BEQ;
			next_FSM_cnt_BNE = next_FSM_cnt_BNE;
			clr_sig = 'dz;
		end
	end

	always @(posedge clk) begin
		curr_FSM_cnt_BEQ <= next_FSM_cnt_BEQ;
		curr_FSM_cnt_BNE <= next_FSM_cnt_BNE;
	end

	always @(*) begin
		{clear_0, clear_1, clear_2, clear_3, clear_4, clear_5, clear_6, clear_7} = 0;
		case (clr_sig)
			3'd0: clear_0 = 1;
			3'd1: clear_1 = 1;
			3'd2: clear_2 = 1;
			3'd3: clear_3 = 1;
			default: {clear_0, clear_1, clear_2, clear_3, clear_4, clear_5, clear_6, clear_7} = 0;
		endcase
	end

	// Control Unit
	always @(posedge clk) begin
		if (rst) begin
			{RegDst, Jump, Branch, MemRead, MemtoReg, RegWrite, MemWrite, ALUOp, IFFlush, AluSrc, ForwardReg} = 0;
		end
	end

	always @(*) begin
		{RegDst, Jump, Branch, MemRead, MemtoReg, RegWrite, MemWrite, ALUOp, AluSrc} = 0;
		case (op)
			6'b000000: begin					// R-type
				RegDst = 1'b1;
				RegWrite = 1'b1;
				ALUOp = 2'b10;
			end
			6'b100011: begin					// lw
				AluSrc = 1'b1;
				MemtoReg = 1'b1;
				RegWrite = 1'b1;
				MemRead = 1'b1;
			end
			6'b101011: begin					// sw
				AluSrc = 1'b1;
				MemWrite = 1'b1;
			end
			6'b000100: begin					// beq
				Branch = 1'b1;
				ALUOp = 2'b01;
			end
			6'b000101: begin					// bne
				Branch = 1'b1;
				ALUOp = 2'b01;
			end
			6'b001000: begin					// addi
				AluSrc = 1'b1;
				RegWrite = 1'b1;
			end
			6'b000010: begin					// Jump
				Jump = 1'b1;
			end
			default: {RegDst, Jump, Branch, MemRead, MemtoReg, RegWrite, MemWrite, ALUOp, AluSrc} = 'dz;
		endcase
	end

	// Hazard Detection Unit
	// consider R-type, BEQ, BNE, SW at ID
	// Priority considered
	assign PCSrc = (op == BNE) ? (~Zero & Branch) : (Zero & Branch);
	always @(*) begin
		// no need to stall when BEQ is right after a non-mem-visiting instruction,
		// since forwarding from EX result to ID is done (might decrease clk rate)
		if (((op == BEQ) || (op == BEQ)) && 
			(MemRead_DE && ((rt == haz[4:0]) || (rt == haz[9:5])))) begin
			// LW + BEQ/BNE hazard, BEQ/BNE at ID, stall 1 cycle
			PCwe = 0;
			IFFlush = 0;
			FDWrite = 0;
			ControlFlush = 1;
		end
		// Jump success or branch prediction fail, clear PC and IF/ID inter-stages registers
		else if (Jump || PCSrc_predict_fail) begin
			PCwe = 1;
			IFFlush = 1;
			FDWrite = 0;						// low priority, 0 or 1 both are ok
			ControlFlush = 0;					// since BEQ/JUMP do not have latter stages, 0 or 1 both are ok
		end
		// R-type or SW need to be considered since they need rt as operation source
		else if (MemRead_DE && (((rt == haz[4:0]) && ((op == 6'b00000) || (op == 6'b101011))) || (rt == haz[9:5]))) begin
			PCwe = 0;
			IFFlush = 0;
			FDWrite = 0;
			ControlFlush = 1;
		end
		else begin
			PCwe = 1;
			IFFlush = 0;
			FDWrite = 1;
			ControlFlush = 0;
		end
	end

	// ID/EX inter-stages registers
	// in order to avoid possible data impact, I put all data to 'dz if this reg_pile is set clear
	always @(posedge clk) begin
		if (~IFFlush && ~ControlFlush) begin
			A <= a;
			B <= b;
			RS <= IR[25:21];
			RT <= IR[20:16];
			RD <= IR[15:11];
			RegDst_DE <= RegDst;
			ALUOp_DE <= ALUOp;
			MemRead_DE <= MemRead;
			MemtoReg_DE <= MemtoReg;
			MemWrite_DE <= MemWrite;
			RegWrite_DE <= RegWrite;
			AluSrc_DE <= AluSrc;
			IMM <= extend_imme;
		end
		else begin
			{A, B, RS, RT, RD, IMM} <= 'dz;
			{RegDst_DE, MemRead_DE, MemtoReg_DE, RegWrite_DE, MemWrite_DE, ALUOp_DE, AluSrc_DE} <= 0;
		end
	end

	// EX
	multi_mux MUX_ALU_A (
		.n(2'd2),
		.m(ForwardA),
		.in_0(A),
		.in_1(reg_data),
		.in_2(ALUOut),
		.out(alu_a)
	);

	// AMB Unit (AMB for ALU_MUX_B)
	// always @(*) begin
	// 	if (AluSrc_DE) begin
	// 		ALU_MUX = 2'd3;
	// 	end
	// 	else begin
	// 		ALU_MUX = ForwardB;
	// 	end
	// end

	// multi_mux MUX_ALU_B (
	// 	.n(2'd3),
	// 	.m(ALU_MUX),
	// 	.in_0(B),
	// 	.in_1(reg_data),
	// 	.in_2(ALUOut),
	// 	.in_3(addr_imme),
	// 	.out(alu_b)
	// );

	multi_mux MUX_FINAL_B (
		.n(2'd2),
		.m(ForwardB),
		.in_0(B),
		.in_1(reg_data),
		.in_2(ALUOut),
		.out(final_b)
	);

	assign addr_imme = IMM;
	assign func = IMM[5:0];

	mux MUX_ALU_B (
		.m(AluSrc_DE),
		.in_0(final_b),
		.in_1(IMM),
		.out(alu_b)
	);

	// ALU Control Unit
	always @(*) begin
		case (ALUOp_DE)
			2'b00: begin				// LW & SW
				ALU_Ctrl = 3'b010;
			end
			2'b01: begin				// BEQ
				ALU_Ctrl = 3'b110;
			end
			2'b10: begin				// R-type
				case (func)
					6'b100000: begin	// add
						ALU_Ctrl = 3'b010;
					end
					6'b100010: begin	// sub
						ALU_Ctrl = 3'b110;
					end
					6'b100100: begin	// and
						ALU_Ctrl = 3'b000;
					end
					6'b100101: begin	// or
						ALU_Ctrl = 3'b001;
					end
					6'b101010: begin	// slt
						ALU_Ctrl = 3'b111;
					end
					default: ALU_Ctrl = 'dz;
				endcase
			end
			default: ALU_Ctrl = 'dz;
		endcase
	end

	ALU alu (
		.y(alu_result),
		.zf(ALU_Zero),
		.cf(cf),
		.of(of),
		.sf(sf),
		.a(alu_a),
		.b(alu_b),
		.m(ALU_Ctrl)
	);

	mux MUX_REGDST (
		.m(RegDst_DE),
		.in_0(rt),
		.in_1(rd),
		.out(rw_addr)
	);

	// Forwarding Unit
	// NOT solved WB-start to MEM-start
	// solved WB-start or MEM-start to EX-start
	// For ForwardReg: MEM-start (EX result) or MEM-end (MEM result) to ID
	// 000 for non-forwarding, 001 from ALU to A, 010 from ALU to B,
	// 011 from MEM to A, 100 from MEM to B
	always @(*) begin
		// forward to EX-start
		if (RegWrite_EM && (|WAE) && (WAE == rs)) begin
			ForwardA = 2'b10;			
		end
		else if (RegWrite_MW && (|WAM) && (WAM == rs)) begin
			ForwardA = 2'b01;
		end
		else begin
			ForwardA = 2'b00;
		end
	end

	always @(*) begin
		// forward to EX-start
		if (RegWrite_EM && (|WAE) && (WAE == rt)) begin
			ForwardB = 2'b10;
		end
		else if (RegWrite_MW && (|WAM) && (WAM == rt)) begin
			ForwardB = 2'b01;
		end
		else begin
			ForwardB = 2'b00;
		end
	end

	always @(*) begin
		// current instruction in ID is a BEQ
		if (beq_forward[15:10] == 6'b000100) begin
			if (RegWrite_DE && (|rw_addr) && (rw_addr == beq_forward[9:5])) begin
				ForwardReg = 3'b001;
			end
			else if (RegWrite_DE && (|rw_addr) && (rw_addr == beq_forward[4:0])) begin
				ForwardReg = 3'b010;
			end
			else if (RegWrite_EM && (|WAE) && (WAE == beq_forward[9:5])) begin
				ForwardReg = 3'b011;
			end
			else if (RegWrite_EM && (|WAE) && (WAE == beq_forward[4:0])) begin
				ForwardReg = 3'b100;
			end
			else begin
				ForwardReg = 3'b000;
			end
		end
		else begin
			ForwardReg = 3'b000;
		end
	end

	// EX/MEM inter-stages registers
	always @(posedge clk) begin
		ALUOut <= alu_result;
		WMD <= final_b;
		WAE <= rw_addr;
		MemRead_EM <= MemRead_DE;
		MemWrite_EM <= MemWrite_DE;
		MemtoReg_EM <= MemtoReg_DE;
		RegWrite_EM <= RegWrite_DE;
	end

	// MEM
	dist_data_ram memory (
		.a(ALUOut[9:2]),
		.d(WMD),
		.clk(clk),
		.we(MemWrite_EM),
		.spo(mem_out)
	);

	// MEM/WB inter-stages registers
	always @(posedge clk) begin
		MDR <= mem_out;
		ADR <= ALUOut;
		WAM <= WAE;
		MemtoReg_MW <= MemtoReg_EM;
		RegWrite_MW <= RegWrite_EM;
	end

	// WB
	mux MUX_WB (
		.m(MemtoReg_MW),
		.in_0(ADR),
		.in_1(MDR),
		.out(reg_data)
	);
endmodule
