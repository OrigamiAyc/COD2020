# 组成原理实验报告lab3

<p align="right">PB18000227 艾语晨</p>

<!-- toc -->

- [单周期CPU](#单周期CPU)
	- [实验目标](#实验目标)
	- [实验内容](#实验内容)
		- [单周期CPU](#单周期CPU)
			- [single_cycle_CPU.v](#CPU主体)
			- [MUX.v](#MUX)
			- [ALU.v](#ALU)
			- [reg_file.v](#reg_file)
			- [simulation](#仿真)
		- [DBU](#DBU)
		- 

<!-- tocstop -->

## 单周期CPU

### 实验目标

1. 理解计算机硬件的基本组成、结构和工作原理；
2. 掌握数字系统的设计和调试方法；
3. 熟练掌握数据通路和控制器的设计和描述方法。

### 实验内容

#### 单周期CPU

CPU由主体设计文件和调用模块、IP核组成，下面每一部分会贴上源代码并附上对设计思路的解释

##### CPU主体

单周期CPU每条指令均用一个时钟周期，在此附上数据通路（对wire类型的命名）

![data_path_sig_CPU](/Users/lapland/GitHub/COD2020/实验文件/lab3/data_path_sig_CPU.png)

###### 源代码

```verilog
// suppose that there is a MAX_restrict of Instruction number: 256 (IP ROM volume)
// different blocks of structurs are defined separately
module sin_CPU
	#(parameter WIDTH = 32)
	(
		input clk, rst
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
		.in_2(Mem_Out),
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

	assign PCSrc = ALU_Zero & Branch;
	assign beq_result = npc + {extend_addr[29:0], 2'b00};
	
	// MEM
	wire [WIDTH-1:0] read_mem_addr;
	assign read_mem_addr = ALU_result / 4;
	dist_data_ram memory (
		.a(read_mem_addr),
		.d(read_data_2),
		.clk(clk),
		.we(MemWrite),
		.spo(Mem_Out)
	);

	// change PC
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			PC = 32'b0;
		end
		else begin
			PC = fin_npc;
		end
	end
endmodule
```

###### 关于源代码的一点解释

就是按照数据通路，四个阶段 (`IF,ID,EX,MEM`)，将`WB`放在寄存器堆实现，除PC外均为组合逻辑

##### MUX

###### 源代码

```verilog
module mux
#(parameter WIDTH = 32)
(
	input m, // control signal
	input [WIDTH-1:0] in_1,in_2,
	output [WIDTH-1:0] out
);
	assign out=(m == 1'b0 ? in_1 : in_2);

endmodule // mux
```

###### 一点注释

其实有一点不好的是在命名端口的时候，应该采用 0,1 (不过都写完了也就不再更改了)

##### ALU

```verilog
// on basis of the COD 5th edition, we use the following parameters
module ALU
    #(parameter WIDTH = 32) 	// data width
(
    output reg [WIDTH-1:0] y,   // calculation result
    output reg zf,              // zero sign
    output reg cf,              // jinwei sign
	output reg of,				// overflow
	output reg sf,				// for signed cal
	input [WIDTH-1:0] a,
	input [WIDTH-1:0] b,
	input [2:0] m				// type
);

	localparam ADD = 3'b010;
    localparam SUBTRACT = 3'b110;
    localparam AND = 3'b000;
    localparam OR = 3'b001;
    localparam XOR = 3'b100;
    localparam SLT = 3'b111;

    always @(*) begin
		{zf,of,cf,sf} = 4'b0000;
		case (m)
			ADD:  begin
				{cf, y} = a + b;
				of = (~a[WIDTH-1] & ~b[WIDTH-1] & y[WIDTH-1]) | (a[WIDTH-1] & b[WIDTH-1] & ~y[WIDTH-1]);
				zf = ~|y;
			end
			SUBTRACT: begin
				{cf, y} = a - b;
				of = (~a[WIDTH-1] & b[WIDTH-1] & y[WIDTH-1]) | (a[WIDTH-1] & ~b[WIDTH-1] & ~y[WIDTH-1]);
				zf = ~|y;
				sf = y[WIDTH-1];
			end
			AND: begin
				y = a & b;
				zf = ~|y;
				sf = y[WIDTH-1];
			end
			OR: begin
				y = a | b;
				zf = ~|y;
				sf = y[WIDTH-1];
			end
			XOR: begin
				y = a ^ b;
				zf = ~|y;
				sf = y[WIDTH-1];
			end
            SLT: begin
                y = (a < b) ? 32'b1 : 32'b0;
            end
			default: y = a;
		endcase
	end
endmodule
```

###### 对于代码的一点说明

将无符号和有符号都写在了一起，输出按需取对应的输出值即可

##### reg_file

###### 源代码

```verilog
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
		if (we && wa != 4'b0) begin
			reg_file[wa] = wd;
		end
	end
endmodule
```

###### 对于源码的一点说明

由于`$0`寄存器永远是0不变，故在写入寄存器的时候，若是`addr==0`，则不修改

##### 仿真

###### 仿真文件

```verilog
module tb_CPU;
    reg clk, rst;

    sin_CPU cpu (
        .clk(clk),
        .rst(rst)
    );

    initial
    begin
        clk = 1;
        rst = 1;
        # 10 rst = 0;
        # 290 $finish;
    end

    always
    # 5 clk = ~clk;
endmodule
```

###### 仿真结果![Screenshot 2020-05-22 at 12.13.13 PM](/Users/lapland/Library/Application Support/typora-user-images/Screenshot 2020-05-22 at 12.13.13 PM.png)

#### DBU

DBU相对于CPU，需要有一些改动的地方，如下：

- 为了读取数据，需要在`reg_file`和`mem`上增加额外的读端口
- CPU的输入输出端口需要更改，增加控制信号
- CPU内部增加对输出信息的处理和选择
- CPU增加逐步执行（使能信号）

如下：

```verilog
module reg_file
	#(parameter WIDTH = 32)
	(
		input clk,
		input [4:0] ra0,			// read port 0 addr
		output [WIDTH-1:0] rd0,		// read port 0 data
		input [4:0] ra1,			// read port 1 addr
		output [WIDTH-1:0] rd1,		// read port 1 data
		input [4:0] ra2,			// read port 2 addr
		output [WIDTH-1:0] rd2,		// read port 2 data
		input [4:0] wa,				// write port addr
		input we,					// write enable, valid at '1'
		input [WIDTH-1:0] wd		// write port data
	);

	reg [WIDTH-1:0] reg_file [0:31];

	assign rd0 = reg_file[ra0];
	assign rd1 = reg_file[ra1];
	assign rd2 = reg_file[ra2];

	integer i;						// loop varible
	initial begin
		for (i = 0; i < 32; i = i + 1) begin
			reg_file [i] = 0;
		end
	end

	always @(posedge clk) begin
		if (we && wa != 4'b0) begin
			reg_file[wa] = wd;
		end
	end
endmodule
```

> mem的IP核实现改为双端口

###### 改动之后的CPU

```verilog
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
	assign RegWrite = run ? regwrite : 0;
	assign ALUSrc = alusrc;
	assign MemRead = memread;
	assign MemWrite = run ? memwrite : 0;
	assign MemtoReg = memtoreg;
	assign Branch = branch;
	assign Jump = jump;
	assign ALUOp = aluop;
	assign status = {Jump, Branch, RegDst, RegWrite, MemtoReg, MemWrite, ALU_ctrl, ALUSrc, ALU_Zero};
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
		.in_1(ALU_result),
		.in_2(Mem_Out),
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

	assign PCSrc = ALU_Zero & Branch;
	assign beq_result = npc + {extend_addr[29:0], 2'b00};
	
	// MEM
	wire [WIDTH-1:0] read_mem_addr;
	assign read_mem_addr = ALU_result / 4;
	dist_data_ram memory (
		.a(read_mem_addr),
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
```

##### 顶层文件

主要包括了去抖动取边沿，和在板子上的输出

###### 源代码

```verilog
module DBU
	# (parameter WIDTH = 32)
	(
		input clk, rst,
		input succ,				// control CPU running type
		input step,
		input [2:0] sel,		// overview the result or status of CPU, 0 for result
		// when examining CPU result
		input m_rf,				// 1 for MEM, 0 for RF (Reg_File)
		input inc,				// m_rf_addr ++
		input dec,				// m_rf_addr --
		output reg [15:0] led,
		output [7:0] an,		// anode, choose which SEG shines
		output [7:0] seg		// node
	);

	wire [11:0] status;
	wire [WIDTH-1:0] m_data;
	wire [WIDTH-1:0] rf_data;
	wire [WIDTH-1:0] selected_data;
	wire step_clean, step_edge;
	wire inc_clean, inc_edge;
	wire dec_clean, dec_edge;
	wire [WIDTH-1:0] display_data;

	reg run;
	reg [7:0] m_rf_addr;

	sin_CPU cpu (
		.clk(clk),
		.rst(rst),
		.run(run),
		.m_rf_addr(m_rf_addr),
		.sel(sel),
		.status(status),
		.m_data(m_data),
		.rf_data(rf_data),
		.selected_data(selected_data)
	);

	jitter_clr step_clr (
		.clk(clk),
		.button(step),
		.button_clean(step_clean)
	);

	signal_edge step_ed (
		.clk(clk),
		.button(step_clean),
		.button_edge(step_edge)
	);

	jitter_clr inc_clr (
		.clk(clk),
		.button(inc),
		.button_clean(inc_clean)
	);

	signal_edge inc_ed (
		.clk(clk),
		.button(inc_clean),
		.button_edge(inc_edge)
	);

	jitter_clr dec_clr (
		.clk(clk),
		.button(dec),
		.button_clean(dec_clean)
	);

	signal_edge dec_ed (
		.clk(clk),
		.button(dec_clean),
		.button_edge(dec_edge)
	);

	// run
	always @(posedge clk) begin
		if (succ) begin
			run = 1;
		end else begin
			if (step_edge) begin
				run = 1;
			end else begin
				run = 0;
			end
		end
	end

	assign display_data = m_rf ? m_data : rf_data;

	SegDis #(WIDTH) Seg_Dis (
		.clk(clk),
		.rst(rst),
		.data(display_data),
		.an(an),
		.seg(seg)
	);
	
	// led : m_rf_addr
	initial
	begin
		led = 16'b0;
	end
	always @(posedge clk) begin
		led = 16'h0;
		if (sel == 3'b0) begin
			led = {8'b0, m_rf_addr};
		end
		else begin
			led = {4'b0, status};
		end
	end

	always @(posedge clk) begin
		if (rst) begin
			m_rf_addr = 0;
		end
		else begin
			if (inc_edge) begin
				m_rf_addr = m_rf_addr + 1;
			end
			else if (dec_edge) begin
				m_rf_addr = m_rf_addr - 1;
			end
			else begin
				m_rf_addr = m_rf_addr;
			end
		end
	end
endmodule

```

##### 去抖动

```verilog
module jitter_clr(
    input clk,
    input button,
    output button_clean
    );

    reg [3:0] cnt;

    always @(posedge clk) begin
        if (button == 1'b0) begin
            cnt <= 4'h0;
        end
        else if (cnt < 4'h8) begin
            cnt <= cnt + 1'b1;
        end
    end
endmodule
```

##### 取边沿

```verilog
module signal_edge(
    input clk,
    input button,
    output button_edge
    );

    reg button_r1, button_r2;

    always @(posedge clk) begin
        button_r1 <= button;
    end

    always @(posedge clk) begin
        button_r2 <= button_r1;
    end

    assign button_edge = button_r1 & ~button_r2;
endmodule
```

##### 分时复用

```verilog
module counter(
	input clk, rst,
	output reg [2:0] scan_cnt
	);

	reg [17:0] cnt;
	// reg [2:0] scan_cnt;

	wire pulse;

	always @(posedge clk) begin
		if (rst) begin
			cnt <= 18'h0;
		end
		else if (cnt == 18'd10000) begin
			cnt <= 18'b0;
		end
		else begin
			cnt <= cnt + 18'b1;
		end
	end

	assign pulse = (cnt == 18'd10000) ? 1'b1 : 1'b0;

	always @(posedge clk) begin
		if (rst) begin
			scan_cnt <= 3'b0;
		end
		else if (pulse) begin
			scan_cnt <= scan_cnt + 3'b1;
		end
	end
endmodule
```

##### 数码管

```verilog
module SegDis
	#(parameter WIDTH = 32)
	(
		input clk,rst,
		input [WIDTH-1:0] data,
		output reg [7:0] an,
		output [7:0] seg
	);

	wire [2:0] scan_cnt;

	reg [WIDTH-1:0] show_data;

	counter clk_1KHz (
		.clk(clk),
		.rst(rst),
		.scan_cnt(scan_cnt)
	);

	initial
	begin
		an = 8'b0;
		show_data = 32'b0;
	end

	always @(posedge clk) begin
		case (scan_cnt)
			3'h0: an <= 8'b1111_1110;
			3'h1: an <= 8'b1111_1101;
			3'h2: an <= 8'b1111_1011;
			3'h3: an <= 8'b1111_0111;
			3'h4: an <= 8'b1110_1111;
			3'h5: an <= 8'b1101_1111;
			3'h6: an <= 8'b1011_1111;
			3'h7: an <= 8'b0111_1111;
			default: an <= 'dz;
		endcase
	end

	always @(posedge clk) begin
		case (scan_cnt)
			3'h0: show_data <= data[3:0];
			3'h1: show_data <= data[7:4];
			3'h2: show_data <= data[11:8];
			3'h3: show_data <= data[15:12];
			3'h4: show_data <= data[19:16];
			3'h5: show_data <= data[23:20];
			3'h6: show_data <= data[27:24];
			3'h7: show_data <= data[31:28];
			default: show_data <= 'dz;
		endcase
	end

	dist_seg_dis_decode decode (
		.a(show_data),
		.spo(seg)
	);
endmodule
```

##### 仿真

###### 仿真文件

```verilog
module tb_DBU();
	localparam WIDTH = 32;
	localparam CWKTIME = 10;

	reg clk, rst, succ, step;
	reg [2:0] sel;
	reg m_rf, inc, dec;
	
	wire [15:0] led;
	wire [7:0] an;
	wire [7:0] seg;

	DBU #(WIDTH) dbu (
		.clk(clk),
		.rst(rst),
		.succ(succ),
		.step(step),
		.sel(sel),
		.m_rf(m_rf),
		.inc(inc),
		.dec(dec),
		.led(led),
		.an(an),
		.seg(seg)
	);

	initial begin
		clk = 1;
		// rst = 1;
		// # (CWKTIME) rst = 0;
	end

	always
	# (CWKTIME / 2) clk = ~clk;

	initial
	begin
			rst=1;sel=0;m_rf=0;inc=0;dec=0;succ=1;step=0;
		# (CWKTIME) rst=0;sel=0;m_rf=0;inc=0;dec=0;succ=1;step=0;
		# (CWKTIME) rst=0;sel=0;m_rf=0;inc=1;dec=0;succ=1;step=0;
		# (CWKTIME) rst=0;sel=0;m_rf=0;inc=0;dec=0;succ=1;step=0;
		# (CWKTIME) rst=0;sel=0;m_rf=0;inc=1;dec=0;succ=1;step=0;
		# (CWKTIME) rst=0;sel=0;m_rf=0;inc=0;dec=0;succ=1;step=0;
		# (CWKTIME) rst=0;sel=1;m_rf=0;inc=0;dec=0;succ=1;step=0;
		# (CWKTIME) rst=0;sel=2;m_rf=0;inc=0;dec=0;succ=1;step=0;
		# (CWKTIME) rst=0;sel=3;m_rf=0;inc=0;dec=0;succ=1;step=0;
		# (CWKTIME) rst=0;sel=4;m_rf=0;inc=0;dec=0;succ=1;step=0;
		# (CWKTIME) rst=0;sel=5;m_rf=0;inc=0;dec=0;succ=1;step=0;
		# (CWKTIME) rst=0;sel=5;m_rf=0;inc=0;dec=0;succ=1;step=0;
		# (CWKTIME) rst=0;sel=0;m_rf=1;inc=0;dec=0;succ=0;step=1;
		# (CWKTIME) rst=0;sel=0;m_rf=1;inc=0;dec=0;succ=0;step=0;
		# (CWKTIME) rst=0;sel=0;m_rf=0;inc=0;dec=0;succ=0;step=0;
		# (CWKTIME) rst=0;sel=0;m_rf=0;inc=0;dec=0;succ=0;step=0;
		# (CWKTIME) rst=0;sel=6;m_rf=0;inc=0;dec=0;succ=0;step=1;
		# (CWKTIME) rst=0;sel=6;m_rf=0;inc=0;dec=0;succ=0;step=0;
		# (CWKTIME) rst=0;sel=6;m_rf=0;inc=0;dec=0;succ=0;step=0;
		# (CWKTIME) rst=0;sel=6;m_rf=0;inc=0;dec=0;succ=0;step=0;
		# (CWKTIME) $finish;
	end
endmodule
```

###### 仿真结果

![Screenshot 2020-05-22 at 8.28.21 PM](/Users/lapland/Library/Application Support/typora-user-images/Screenshot 2020-05-22 at 8.28.21 PM.png)

### 思考题

修改之后的数据通路如下所示：（彩色部分）

![data_path_sig_CPU_think](data_path_sig_CPU_think.png)

#### 指令分析

这个指令`accm : rd <- M(rs) + rt`即为以下两个指令的组合：

```assembly
lw $t1, 0(rs)
add $(rd), $(t1), $(rt)
```



#### 设计思路

如图所示增加MUX，且MEM的Address端口地址向左偏移2位之后再读数据

**IF**、**ID**阶段和普通的**R-type**指令相同，在访问寄存器堆之后的`read_data_1`通过多路选择器用于访存，访存出来的数据送回到ALU做加法运算。

也就是说，这个指令的**MEM**段在**EX**段之前执行

