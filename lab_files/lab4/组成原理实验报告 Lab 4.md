# 组成原理实验报告 Lab 4

<p align="right">PB18000227 艾语晨</p>

<!-- toc -->

- [多周期CPU](#多周期CPU)
	- [实验目标](#实验目标)
	- [实验内容](#实验内容)
		- [多周期CPU](#多周期CPU)
			- [multi_cycle_CPU.v](#Multi_CPU)
			- [MUX.v](#MUX)
			- [ALU.v](#ALU)
			- [reg_file.v](#reg_file)
			- [simulation](#仿真)
		- [DBU](#DBU)
		- 

<!-- tocstop -->

## 多周期CPU

### 实验目标

1. 理解计算机硬件的基本组成、结构和工作原理；
2. 掌握数字系统的设计和调试方法；
3. 熟练掌握数据通路和控制器的设计和描述方法。

### 实验内容

#### 多周期CPU

设计采用普林斯顿结构，数据通路如下图所示

![data_path](data_path_multi_CPU.jpeg?raw=true)

##### Multi_CPU

###### 源代码

```verilog
module multi_CPU
	#(parameter WIDTH = 32)
	(
		input clk, rst
	);

	reg [WIDTH-1:0] PC;
	reg [WIDTH-1:0] A, B;
	reg [5:0] INS_1;						// 31-26 (op)
	reg [4:0] INS_2, INS_3;					// 25-21, 20-16 (rs, rt)
	reg [15:0] INS_4;						// 15-0 (imme)
	reg [2:0] ALU_CTRL;
	reg [WIDTH-1:0] ALU_Out;
	reg [WIDTH-1:0] MEM_data_reg;

	wire [5:0] op;							// 31-26 (op)
	wire [4:0] rs, rt;						// 25-21, 20-16 (rs, rt)
	wire [15:0] imme;						// 15-0 (imme)
	wire [5:0] func;						// 5-0 (func)
	wire [WIDTH-1:0] mem_addr;
	wire [WIDTH-1:0] mem_data;
	wire [4:0] rd;
	wire [WIDTH-1:0] reg_w_data;
	wire [4:0] reg_addr;
	wire [WIDTH-1:0] a, b;
	wire [WIDTH-1:0] extend_addr, left_shift;
	wire [WIDTH-1:0] alu_a, alu_b, alu_out;
	wire alu_zero, cf, of, sf;
	wire [WIDTH-1:0] jump_shift;
	wire [WIDTH-1:0] pc_final;

	assign op = INS_1;
	assign rs = INS_2;
	assign rt = INS_3;
	assign imme = INS_4;
	assign func = imme[5:0];
	// assign a = A;
	// assign b = B;

	// control signal
	wire PCWriteControl, PCWrite, PCwe;
	wire IorD, MemtoReg, RegDst, ALUSrcA;	// ctrl sig for MUX
	wire [1:0] ALUSrcB, ALUOp, PCSource;
	wire [2:0] ALU_ctrl;
	wire MemRead, MemWrite;
	wire IRWrite, RegWrite;

	// IF
	mux MUX_mem_visit (
		.m(IorD),
		.in_0(PC),
		.in_1(ALU_Out),
		.out(mem_addr)
	);

	dist_Memory Memory (
		.a(mem_addr[10:2]),
		.d(B),
		.clk(clk),
		.we(MemWrite),
		.spo(mem_data)
	);

	// ID
	always @(posedge clk) begin
		if (IRWrite) begin
			INS_1 <= mem_data[31:26];
			INS_2 <= mem_data[25:21];
			INS_3 <= mem_data[20:16];
			INS_4 <= mem_data[15:0];
		end
	end

	assign rd = INS_4[15:11];

	mux MUX_reg_read_2 (
		.in_0(rt),
		.in_1(rd),
		.m(RegDst),
		.out(reg_addr)
	);

	reg_file registers (
		.clk(clk),
		.ra0(rs),
		.ra1(rt),
		.wa(reg_addr),
		.rd0(a),
		.rd1(b),
		.we(RegWrite),
		.wd(reg_w_data)
	);

	always @(posedge clk) begin
		A <= a;
		B <= b;
	end

	// sign extend
	assign extend_addr = {((imme[15]) ? 16'hffff : 16'h0000), imme};
	// left shift 2
	assign left_shift = extend_addr << 2;

	// EX
	multi_mux MUX_ALU_B (
		.n(2'd3),
		.m(ALUSrcB),
		.in_0(B),
		.in_1(32'd4),
		.in_2(extend_addr),
		.in_3(left_shift),
		.out(alu_b)
	);

	mux MUX_ALU_A (
		.m(ALUSrcA),
		.in_0(PC),
		.in_1(A),
		.out(alu_a)
	);

	assign PCwe = (PCWriteControl & alu_zero) | PCWrite;
	control_unit control_unit (
		.clk(clk),
		.rst(rst),
		.op(op),
		.PCWriteControl(PCWriteControl),
		.PCWrite(PCWrite),
		.IorD(IorD),
		.MemtoReg(MemtoReg),
		.RegDst(RegDst),
		.ALUSrcA(ALUSrcA),
		.ALUSrcB(ALUSrcB),
		.ALUOp(ALUOp),
		.PCSource(PCSource),
		.MemRead(MemRead),
		.MemWrite(MemWrite),
		.IRWrite(IRWrite),
		.RegWrite(RegWrite)
	);

	// ALU control
	assign ALU_ctrl = ALU_CTRL;
	always @(*) begin
		case (ALUOp)
			2'b00: begin				// LW & SW
				ALU_CTRL = 3'b010;
			end
			2'b01: begin				// BEQ
				ALU_CTRL = 3'b110;
			end
			2'b10: begin				// R-type
				case (func)
					6'b100000: begin	// add
						ALU_CTRL = 3'b010;
					end
					6'b100010: begin	// sub
						ALU_CTRL = 3'b110;
					end
					6'b100100: begin	// and
						ALU_CTRL = 3'b000;
					end
					6'b100101: begin	// or
						ALU_CTRL = 3'b001;
					end
					6'b101010: begin	// slt
						ALU_CTRL = 3'b111;
					end
					default: ALU_CTRL = 'dz;
				endcase
			end
			default: ALU_CTRL = 'dz;
		endcase
	end

	ALU alu (
		.y(alu_out),
		.zf(alu_zero),
		.cf(cf),
		.of(of),
		.sf(sf),
		.a(alu_a),
		.b(alu_b),
		.m(ALU_ctrl)
	);

	always @(posedge clk) begin
		ALU_Out <= alu_out;
	end

	// NPC
	assign jump_shift = {PC[31:28], rs, rt, imme, 2'b00};

	// MEM
	// PC final
	multi_mux MUX_PC (
		.n(2'd3),
		.m(PCSource),
		.in_0(alu_out),
		.in_1(ALU_Out),
		.in_2(jump_shift),
		.out(pc_final)
	);

	always @(posedge clk) begin
		if (rst) begin
			PC <= 32'b0;
		end else begin
			if (PCwe) begin
				PC <= pc_final;
			end
			else
				PC <= PC;			
		end
	end

	always @(posedge clk) begin
		MEM_data_reg <= mem_data;
	end

	// WB
	mux MUX_WB (
		.m(MemtoReg),
		.in_0(ALU_Out),
		.in_1(MEM_data_reg),
		.out(reg_w_data)
	);
endmodule
```

###### 设计思路

多周期CPU相比于单周期CPU，由于一条指令需要多个时钟周期完成，故需要增加寄存器来保存数据，不过由于从ID之后PC就不再改变了，所以不需要像流水线一样添加好多段间寄存器

##### MUX

###### 源代码