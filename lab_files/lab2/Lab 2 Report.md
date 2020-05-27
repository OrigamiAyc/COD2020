# Lab 2 Report

<p align="center">寄存器堆与队列</p>

<p align="right">PB18000227 艾语晨</p>

### 实验要求

#### 实验目标

1. 掌握寄存器堆（Register File）和存储器（Memory）的功能、时序及其应用；
2. 熟练掌握数据通路和控制器的设计和描述方法

### 实验内容

#### 寄存器堆

##### 源代码

```verilog
module register_file
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

	always @(posedge clk) begin
		if (we) begin
			reg_file[wa] = wd;
		end
	end
endmodule
```

###### 代码解释

包含两个异步读端口和一个同步写端口：

- 读通过`assign`赋值语句实现，由于读不会改变存储数据（无害操作），故无需使能信号
- 写通过 **clk** 控制的`always`语句实现

###### 需要注意的

命名寄存器组时，后面不同寄存器的`[a:b]`是小序号在前面

##### 仿真

###### 仿真文件

```verilog
module tb_reg;
	reg clk, we;
	reg [4:0] ra0, ra1, wa;
	reg [31:0] wd;
	wire [31:0] rd0, rd1;

	register_file regis (
		.clk(clk),
		.ra0(ra0),
		.rd0(rd0),
		.ra1(ra1),
		.rd1(rd1),
		.wa(wa),
		.we(we),
		.wd(wd)
	);

	localparam CLK_PERIOD = 10;
	always #(CLK_PERIOD/2) clk = ~clk;

	initial begin
		clk = 1;
	end

	initial begin
		we = 1;
		#CLK_PERIOD we = 0;
		#(CLK_PERIOD) we = 1;
		#(CLK_PERIOD) we = 0;
		#(CLK_PERIOD) we = 1;
		#(CLK_PERIOD) we = 0;
		#(CLK_PERIOD * 3) we = 1;
		#CLK_PERIOD we = 0;
		#(CLK_PERIOD * 2) $finish;
	end

	initial begin
		wa = 4'b0;
		#(CLK_PERIOD * 2) wa = 4'h1;
		#(CLK_PERIOD * 2) wa = 4'h2;
		#(CLK_PERIOD * 4) wa = 4'h3;
		#(CLK_PERIOD * 2) wa = 4'h4;
		#(CLK_PERIOD) $finish;
	end

	initial begin
		ra0 = 4'b0;
		#(CLK_PERIOD * 2) ra0 = 4'b1;
		#(CLK_PERIOD * 2) ra0 = 4'b0;
		#(CLK_PERIOD * 4) ra0 = 4'h2;
		#(CLK_PERIOD * 3) ra0 = 4'b1;
		$finish;
	end

	initial begin
		ra1 = 4'b0;
		#(CLK_PERIOD * 2) ra1 = 4'b1;
		#(CLK_PERIOD * 2) ra1 = 4'h2;
		#(CLK_PERIOD * 4) ra1 = 4'h3;
		#(CLK_PERIOD * 3) ra1 = 4'h4;
		$finish;
	end

	initial begin
		wd = 32'h0;
		#(CLK_PERIOD * 2) wd = 32'd1;
		#(CLK_PERIOD * 3) wd = 32'd3;
		#(CLK_PERIOD * 3) wd = 32'd4;
		#(CLK_PERIOD * 3) $finish;
	end
endmodule
```



###### 仿真结果

![lab2_reg](/Users/lapland/Downloads/lab2_reg.PNG)

#### 存储器

##### 补全代码

```verilog
module  ram_16x8			//16x8位单端口RAM
(
    input  clk, 			//时钟（上升沿有效）
    input en, we,			//使能，写使能
    input [3:0]  addr,		//地址
    input [7:0]  din,		//输入数据
    output [7:0]  dout		//输出数据
);
    reg [3:0] addr_reg;
    reg [7:0] mem[0:15];

	//初始化RAM的内容
    initial
    $readmemh(“初始化数据文件名”, mem); 

    assign dout = mem[addr_reg];

    always@(posedge clk) begin
      if(en) begin
        addr_reg <= addr;
        if(we)
          mem[addr] <= din;
      end
    end
endmodule
```

##### 仿真

###### 仿真文件

```verilog
module tb_mem;
reg [3:0] addr;
reg [7:0] d_in;
wire [7:0] d_out;
reg clk,we;
dist_mem_gen_0 distmem(.a(addr),.d(d_in),.clk(clk),.we(we),.spo(d_out));
parameter PERIOD = 10,CYCLE = 20;
 initial
      begin
          clk = 0;
          repeat (10*CYCLE)
              #(PERIOD/2) clk = ~clk;
          $finish;
      end
 initial 
     begin
         we = 1;
         addr = 7;
         d_in = 5;
         #(PERIOD*5)
         we = 1;
         addr = 6;
         d_in = 3;
         #(PERIOD*5)
         we = 1;
         addr = 5;
         d_in = 1;
         #(PERIOD*5)
         we = 0;
         addr = 8;
         #(PERIOD*5)
         we = 0;
         addr = 7;
         #(PERIOD*5)
         we = 0;
         addr = 6;
         #(PERIOD*5)
         we = 0;
         addr = 5;
         #(PERIOD*5)
         we = 0;
         addr = 4;
         #(PERIOD*5)
         we = 0;
         addr = 3;
         #(PERIOD*5)
         we = 0;
         addr = 2;
         #(PERIOD*5)
         we = 0;
         addr = 1;
         #(PERIOD*5)
         we = 0;
         addr = 0;
         #(PERIOD*5)
         $stop;
     end
endmodule
```

###### 仿真结果

![lab2_mem](/Users/lapland/Downloads/lab2_mem.PNG)

#### 排序电路

##### 源代码

```verilog
// reg [7:0] queue [0:4]
// 32 numbers, each 8 bits long
module fifo( // already no shake waves
	input clk,rst,
	input [7:0] din,		// data enqueue
	input en_in,			// enqueue enable, valid when '1'
	input en_out,			// dequeue enable, valid when '1'
	output [7:0] dout,		// data dequeue
	output [4:0] count	// data amount count, 5 bits since need to show 0~16
	);

	parameter EMPTY = 2'b00;
	parameter NORMAL = 2'b01;// neither empty nor full
	parameter FULL = 2'b10;

	reg [4:0] cnt;
	reg [3:0] head, tail, addr;
	reg [2:0] curr_state, next_state;
	// reg eni, eno;

	wire [3:0] ADDR;
	wire en;

	assign ADDR = addr;
	assign count = cnt;
	// assign en = eni + eno;
    // assign dout = en_out ? douta : 'dz;

	blk_mem_gen_0 ram_read (
		.addra(ADDR),
		.clka(clk),
		.dina(din),
		.douta(dout),
		// .ena(en),
		.ena(1),
		.wea(en_in)
	);

	initial begin
		head = 4'b0;
		tail = 4'b0;
		cnt = 5'b0;
		// eni = 1'b0;
		// eno = 1'b0;
	end

	always @(posedge clk or posedge rst) begin
		if (rst) begin // empty the queue
			cnt = 5'b0;
			head = 4'b0;
			tail = 4'b0;
			// eni = 1'b0;
			// eno = 1'b0;
			curr_state <= EMPTY;
		end
		else begin
			curr_state <= next_state;
		end
	end

	always @(posedge clk) begin
		if (en_in | en_out) begin
			if (en_in) begin
				case (curr_state)
					EMPTY: begin
						next_state <= NORMAL;
						cnt = cnt + 5'b1;
						addr = tail;
						tail <= tail + 4'b1;
						head = head;
						// eni = 1'b1;
						// eno = 1'b0;
					end
					NORMAL: begin
						if (cnt == 5'b01111) begin
							next_state <= FULL;
							cnt = cnt + 5'b1;
							addr = tail;
							tail <= tail + 4'b1;
							head = head;
							// eni = 1'b1;
							// eno = 1'b0;
						end else begin
							next_state <= NORMAL;
							cnt = cnt + 5'b1;
							addr = tail;
							tail <= tail + 4'b1;
							head = head;
							// eni = 1'b1;
							// eno = 1'b0;
						end
					end
					FULL: begin // cannot enqueue, remain FULL status
						next_state <= FULL;
						cnt = cnt;
						tail = tail;
						addr = tail;
						head = head;
						// eni = 1'b0;
						// eno = 1'b0;
					end
					default: begin
						next_state <= next_state;
						cnt = cnt;
						tail = tail;
						addr = addr;
						head = head;
						// eni = 1'b0;
						// eno = 1'b0;
					end
				endcase
			end
			else if (en_out) begin
				case (curr_state)
					EMPTY: begin // cannot dequeue, remain EMPTY status
						next_state <= EMPTY;
						cnt = cnt;
						tail = tail;
						head = head;
						addr = head;
						// eni = 1'b0;
						// eno = 1'b0;
					end
					NORMAL: begin
						if (cnt == 5'b00001) begin
							next_state <= EMPTY;
							cnt = cnt - 5'b1;
							tail = tail;
							addr = head;
							head <= head + 4'b1;
							// eni = 1'b0;
							// eno = 1'b1;
						end else begin
							next_state <= NORMAL;
							cnt = cnt - 5'b1;
							tail = tail;
							addr = head;
							head <= head + 4'b1;
							// eni = 1'b0;
							// eno = 1'b1;
						end
					end
					FULL: begin
						next_state <= NORMAL;
						cnt = cnt - 5'b1;
						tail = tail;
						addr = head;
						head <= head + 4'b1;
						// eni = 1'b0;
						// eno = 1'b1;
					end
					default: begin
						next_state <= next_state;
						cnt = cnt;
						tail = tail;
						head = head;
						addr = addr;
						// eni = 1'b0;
						// eno = 1'b0;
					end
				endcase
			end
		end
		else begin
			next_state <= next_state;
			cnt = cnt;
			tail = tail;
			head = head;
			addr = addr;
			// eni = 1'b0;
			// eno = 1'b0;
		end
	end
endmodule
```

###### 代码解释

存储器用IP核**block_mem**，队列用状态机来控制，三个状态分别对入队、出队操作

###### 需要注意的

总是能一直为*1*即可，入队需要写，用写使能；而出队不需要抹除数据，直接移动指针即可

##### 仿真

###### 仿真文件

```verilog
// `include "fifo.v"
// `default_nettype none

module tb_fifo;
	reg clk, rst, en_in, en_out;
	reg [7:0] din;
	wire [6:0] dout;
	wire [4:0] count;

	fifo queue
	(
		.rst (rst),
		.clk (clk),
		.en_in(en_in),
		.en_out(en_out),
		.din(din),
		.dout(dout),
		.count(count)
	);

	localparam CLK_PERIOD = 10;
	always #(CLK_PERIOD/2) clk = ~clk;

	// initial begin
	//	 dumpfile("tb_fifo.vcd");
	//	 dumpvars(0, tb_fifo);
	// end

	initial begin
		clk = 1;
	end

	initial begin
		rst = 1;
		# CLK_PERIOD rst = 0;
	end

	initial begin
		din = 8'h10;
		# (CLK_PERIOD * 3) din = 8'h01;
		# (CLK_PERIOD * 5) din = 8'hac;
		# (CLK_PERIOD * 2) din = 8'hb4;
		# (CLK_PERIOD * 2) $finish;
	end

	initial begin
		en_in = 0;
		# (CLK_PERIOD) en_in = 1;
		# (CLK_PERIOD) en_in = 0;
		# (CLK_PERIOD) en_in = 1;
		# (CLK_PERIOD) en_in = 0;
		# (CLK_PERIOD * 6) en_in = 1;
		# (CLK_PERIOD) en_in = 0;
		# (CLK_PERIOD) $finish;
	end

	initial begin
		en_out = 0;
		// # (CLK_PERIOD) en_out = 1;
		// # (CLK_PERIOD) en_out = 0;
		# (CLK_PERIOD * 6) en_out = 1;
		# (CLK_PERIOD) en_out = 0;
		# (CLK_PERIOD * 2) en_out = 1;
		# (CLK_PERIOD) en_out = 0;
		# (CLK_PERIOD * 2) $finish;
	end

endmodule
// `default_nettype wire
```

###### 仿真结果

![lab2_sort](/Users/lapland/Downloads/lab2_sort.PNG)

###### 对仿真结果的解释

由于存储器自身的原因，对存储器的读取延后了两个时钟周期输出

#### 顶层文件

用于在板子上使用时去抖动，由于仿真时无需模拟抖动，故单独添加顶层文件

##### 源代码

```verilog
module board(
	input clk, rst,
	input [7:0] din,		// data enqueue
	input en_in,			// enqueue enable, valid when '1'
	input en_out,			// dequeue enable, valid when '1'
	output [7:0] dout,		// data dequeue
	output [4:0] count		// data amount count, 5 bits since need to show 0~16
	);

	wire rst_clean, rst_edge, en_in_clean, en_in_edge, en_out_clean, en_out_edge;

	jitter_clr rst_clr (
		.clk(clk),
		.button(rst),
		.button_clean(rst_clean)
	);

	signal_edge rst_ed (
		.clk(clk),
		.button(rst_clean),
		.button_edge(rst_edge)
	);
	
	jitter_clr en_in_clr (
		.clk(clk),
		.button(en_in),
		.button_clean(en_in_clean)
	);

	signal_edge en_in_ed (
		.clk(clk),
		.button(en_in_clean),
		.button_edge(en_in_edge)
	);
	
	jitter_clr en_out_clr (
		.clk(clk),
		.button(en_out),
		.button_clean(en_out_clean)
	);

	signal_edge en_out_ed (
		.clk(clk),
		.button(en_out_clean),
		.button_edge(en_out_edge)
	);
	
	fifo queue (
		.clk(clk),
		.rst(rst_edge),
		.din(din),
		.dout(dout),
		.en_in(en_in_edge),
		.en_out(en_out_edge),
		.count(count)
	);
endmodule
```

##### 去抖动文件

用的是上学期模数实验的方法

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

##### 取边沿文件

用的也是上学期模数实验的方法

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

### 思考题

1. 如何利用寄存器堆和适当电路设计实现可变个数的数据排序电路？

> <font color=green>Answer :</font>

基本思路是归并排序算法，如果不考虑已经实现了对四个数的排序，那么只需要n个寄存器（n为数据总量）和一定数量的比较器（数量取决于并行程度）即可

如果考虑到四个数的排序，那么初始分解只需要分为4个数据一组，组内排序，然后像二叉树一样逐层向上整合

整合思路：只要从比较二个数列的第一个数，谁小就先取谁，取了后就在对应数列中删除这个数。然后再进行比较，如果有数列为空，那直接将另一个数列的数据依次取出即可