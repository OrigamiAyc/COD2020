# 计算机组成原理实验报告

<p align="center">Lab 1 运算器与排序</p>

<p align="right">by 艾语晨 PB18000227</p>

<!-- toc -->

#### Contents

- [实验原题](实验原题)
	- [实验目标](实验目标)
	- [实验内容](实验内容)
	- [实验步骤](实验步骤)
	- [实验检查](实验检查)
	- [思考题](思考题)
- [实验完成](实验完成)
	- [逻辑设计](逻辑设计)
		- [ALU模块](ALU 模块)
		- [总的排序电路](总的排序电路)
	- [核心代码](核心代码)

<!-- tocstop -->

### 实验原题

##### 实验目标

1. 掌握算术逻辑单元（ALU）的功能，加/减运算时溢出、进位/借位、零标志的形成及其应用；

2. 掌握数据通路和控制器的设计和描述方法。

##### 实验内容

1. ALU的设计

待设计的ALU模块的逻辑符号如图-1所示。该模块的功能是将两操作数（a，b）按照指定的操作方式（m）进行运算，产生运算结果（y）和相应的标志（f）。

<p align="center">图-1 ALU模块逻辑符号</p>

操作方式m的编码与ALU的功能对应关系如表-1所示。表中标志f细化为进位/借位标志（cf）、溢出标志（of）和零标志（zf）；“*”表示根据运算结果设置相应值；“x”表示无关项，可取任意值。例如，加法运算后设置进位标志（cf）、of和zf，减法运算后设置借位标志（cf）、of和zf。

表-1 ALU模块功能表

| m    | y      | cf   | of   | zf   |
| ---- | ------ | ---- | ---- | ---- |
| 000  | a + b  | *    | *    | *    |
| 001  | a - b  | *    | *    | *    |
| 010  | a & b  | x    | x    | *    |
| 011  | a \| b | x    | x    | *    |
| 100  | a ^ b  | x    | x    | *    |
| 其他 | x      | x    | x    | x    |

 

参数化的ALU模块端口声明如下：

```verilog
module alu

\#(parameter WIDTH = 32) 	//数据宽度

(output [WIDTH-1:0] y, 		//运算结果

output zf, 					//零标志

output cf, 					//进位/借位标志

output of, 					//溢出标志

input [WIDTH-1] a, b,		//两操作数

input m						//操作类型

);

……

endmodule
```

2. 排序电路的设计

利用前面设计的ALU模块，辅之以若干寄存器和数据选择器，以及适当的控制器，设计实现四个4位有符号数的排序电路，其逻辑符号如图-2所示。


<p align="center">图-2 排序电路逻辑符号</p>

该排序电路模块端口声明如下：

``` verilog
module sort

\#(parameter N = 4) 			//数据宽度

(output [N-1:0] s0, s1, s2, s3, 	//排序后的四个数据（递增）

output done, 				//排序结束标志

input [N-1] x0, x1, x2, x3,	//原始输入数据

input clk, rst				//时钟（上升沿有效）、复位（高电平有效）

);

……

endmodule
```

示例：三个无符号数排序电路的数据通路、控制器及其状态图如图-3和图-4所示。

<p align="center">图-3 三个无符号数排序电路的数据通路逻辑框图</p> 



<p align="center">图-4 三个无符号数排序电路的控制器及其状态图</p>

##### 实验步骤

1. 采用行为方式描述参数化的ALU模块，并进行功能仿真；

2. 设计排序电路的数据通路和控制器，采用结构化方式描述数据通路，两段式FSM描述控制器，并进行功能仿真；

3. 排序电路下载至FPGA中测试：4个输入数据x0 ~ x3顺序对应SW0 ~ SW15，排序后数据s0 ~ s3顺序对应LED0 ~ LED15，done对应三色LED的绿色灯，clk对应BTNC，rst对应BTNL。

##### 实验检查

1. 检查ALU的功能仿真；

2. 检查排序电路的功能仿真；

3. 检查排序电路下载到FPGA后的运行功能。

##### 思考题

1. 如果要求排序后的数据是递减顺序，电路如何调整？

2. 如果为了提高性能，使用两个ALU，电路如何调整？

### 实验完成

##### 逻辑设计

我采用的是 ALU-MUX-REG-FSM 的模式，利用多路选择器来控制数据交换的思路（就是老师PPT上的），这一部分放上数据通路图，源码在后面

###### ALU 模块

![Screenshot 2020-04-29 at 4.07.30 PM](/Users/lapland/Library/Application Support/typora-user-images/Screenshot 2020-04-29 at 4.07.30 PM.png)

###### 总的排序电路

![Screenshot 2020-04-29 at 4.08.32 PM](/Users/lapland/Library/Application Support/typora-user-images/Screenshot 2020-04-29 at 4.08.32 PM.png)

##### 核心代码

###### MUX

```verilog
module mux(
    input m, // control signal
    input [3:0] in_1,in_2,
    output [3:0] out
);
    assign out=(m==0?in_1:in_2);

endmodule // mux
```

###### REG

```verilog
module register(
    input [3:0] in,
    input en,
    input rst,
    input clk,
    output reg [3:0] out
);
    always@(posedge clk,posedge rst)
        if(rst==1)
        begin
            out<=4'b0;
        end
        else
        begin
            if(en==1)
                out<=in;
            else 
                out<=out ; 
        end
endmodule // register
```

###### ALU

```verilog
module ALU
    #(parameter WIDTH = 32) 	// data width
(
    output reg [WIDTH-1:0] y,   // calculation result
    output reg zf,              // zero sign
    output reg cf,              // jinwei sign
	output reg of,				// yichu
	output reg sf,				// for signed cal
	input [WIDTH-1:0] a,
	input [WIDTH-1:0] b,
	input [2:0] m				// type
);

	always @(*) begin
		{zf,of,cf,sf} = 4'b0000;
		case (m)
			3'b000:  begin
				{cf, y} = a + b;
				of = (~a[WIDTH-1] & ~b[WIDTH-1] & y[WIDTH-1]) | (a[WIDTH-1] & b[WIDTH-1] & ~y[WIDTH-1]);
				zf = ~|y;
			end
			3'b001: begin
				{cf, y} = a - b;
				of = (~a[WIDTH-1] & b[WIDTH-1] & y[WIDTH-1]) | (a[WIDTH-1] & ~b[WIDTH-1] & ~y[WIDTH-1]);
				zf = ~|y;
				sf = y[WIDTH-1];
			end
			3'b010: begin
				y = a & b;
				zf = ~|y;
				sf = y[WIDTH-1];
			end
			3'b011: begin
				y = a | b;
				zf = ~|y;
				sf = y[WIDTH-1];
			end
			3'b100: begin
				y = a ^ b;
				zf = ~|y;
				sf = y[WIDTH-1];
			end
			default: y = a;
		endcase
	end
endmodule
```

###### SORT

```verilog
module sort
    #(parameter  N = 4) // data width
    (
        output [N-1:0] s0,s1,s2,s3, // s3 > s2 > ...
        output reg done,    // signal of done
        input [N-1:0] x0,x1,x2,x3,    // original input statistics
        input clk,rst   // clock, reset
    );

    localparam LOAD = 3'b000;
    localparam CX01A = 3'b001;
    localparam CX12A = 3'b010;
    localparam CX23A = 3'b011;
	localparam CX01B = 3'b100;
	localparam CX12B = 3'b101;
	localparam CX01C = 3'b110;
    localparam HLT = 3'b111;
	localparam MINUS = 3'b001;

    wire [3:0]i0, i1, i2, i3; // registers input port
	wire zf, cf, sf, of; // ALU output port
    wire [3:0] a, b, out; // temp variables, for ALU in & out

    reg m0, m1, m2, m3, m4, m5; // 0~3 are for data input (to regs), 4 & 5 are for ALU input
    reg en0, en1, en2, en3; // for registers
	reg [2:0] curr_state, next_state;
 
    //data path 
    register R0( .in(i0), .en(en0), .rst(rst), .clk(clk), .out(s0) );
    register R1( .in(i1), .en(en1), .rst(rst), .clk(clk), .out(s1) );
    register R2( .in(i2), .en(en2), .rst(rst), .clk(clk), .out(s2) );
    register R3( .in(i3), .en(en3), .rst(rst), .clk(clk), .out(s3) );

	ALU #(N) alu( .a(a), .b(b), .y(out), .zf(zf), .cf(cf), .of(of), .sf(sf), .m(MINUS) );

    mux M0( .m(m0), .in_1(x0), .in_2(s1), .out(i0));
    mux M1( .m(m1), .in_1(x1), .in_2(a), .out(i1));
    mux M2( .m(m2), .in_1(x2), .in_2(b), .out(i2));
    mux M3( .m(m3), .in_1(x3), .in_2(s2), .out(i3));
    mux M4( .m(m4), .in_1(s0), .in_2(s2), .out(a));
    mux M5( .m(m5), .in_1(s1), .in_2(s3), .out(b));

    //control Unit 
    always@(posedge clk, posedge rst)
        if(rst)
            curr_state <= LOAD;
        else
            curr_state <= next_state;
    
    // FSM
    always@(*) begin
        if(rst)
            next_state = LOAD;
        else     
            case (curr_state)
                LOAD: next_state = CX01A;
                CX01A: next_state = CX12A;
                CX12A: next_state = CX23A;
                CX23A: next_state = CX01B;
                CX01B: next_state = CX12B;
                CX12B: next_state = CX01C;
                CX01C: next_state = HLT;
                HLT: next_state = HLT;
                default: next_state = HLT;
            endcase
    end

    always@(*)
    begin
        {m0,m1,m2,m3,m4,m5,en0,en1,en2,en3,done} = 11'h0;
        case (curr_state)
            LOAD: begin
                {m1,m2,m3,m4,m5,en0,en1,en2,en3} = 6'b00_0000_1111;
                done = 0;
            end
            CX01A, CX01B, CX01C: begin
                m0 = 1;
                m1 = 1;
                en0 = (~of & ~sf & ~zf) | (of & sf & ~zf);
                en1 = (~of & ~sf & ~zf) | (of & sf & ~zf);
            end 
            CX12A, CX12B: begin
                m1 = 1;
                m2 = 1;
                m4 = 1;
                en1 = ~((~of & ~sf & ~zf) | (of & sf & ~zf));
                en2 = ~((~of & ~sf & ~zf) | (of & sf & ~zf));
            end
            CX23A: begin
                m2 = 1;
                m3 = 1;
                m4 = 1;
                m5 = 1;
                en2 = (~of & ~sf & ~zf) | (of & sf & ~zf);
                en3 = (~of & ~sf & ~zf) | (of & sf & ~zf);
            end
            HLT: done = 1;
        endcase
    end

endmodule
```

###### SIMULATION

```verilog
module testbench_self;
    reg clk, rst;
    reg [3:0] x0, x1, x2, x3;
    wire [3:0] s0, s1, s2, s3;
    wire done;

    parameter N = 4;
    parameter CYCLE = 20;

    sort #(N) sort (
        .s0(s0),
        .s1(s1),
        .s2(s2),
        .s3(s3),
        .done(done),
        .x0(x0),
        .x1(x1),
        .x2(x2),
        .x3(x3),
        .clk(clk),
        .rst(rst)
    );

    initial begin
        clk = 0;
        repeat (2 * CYCLE)
            #5 clk = ~clk;
        $finish;
    end

    initial begin
        rst = 0;
        #3 rst = 1;
        #1 rst = 0;
    end

    initial begin
        x0 = 3;
        x1 = 1;
        x2 = 6;
        x3 = 2;
    end
endmodule
```

##### 仿真结果

![Screenshot 2020-04-29 at 4.29.56 PM](/Users/lapland/Library/Application Support/typora-user-images/Screenshot 2020-04-29 at 4.29.56 PM.png)

##### 结果分析

排序结果是1，2，3，6；可见排序正确

##### 实验总结

本实验用到了很多上学期模电的知识，但是用 MUX 来控制数据交换而不是在ALU输出端用组合逻辑电路，是后面设计 CPU 的一个重要的点。

在实验中踩过的坑依然是写成单独的summary，一并附在后面。

##### 意见 / 建议

对本次实验：无

建议实验早 2～3 星期开始

### 思考题

1. 如果要求排序后的数据是递减顺序，电路如何调整？

	> Answer :
	>
	> 在 sort 文件的最后一个 always 语句块里面，把使能信号赋值改为 `(~of & sf & ~zf) | (of & ~sf & ~zf)` 即可

2. 如果为了提高性能，使用两个ALU，电路如何调整？

	> Answer :
	>
	> 用 keynote 来演示

	![Screenshot 2020-04-29 at 5.33.47 PM](/Users/lapland/Library/Application Support/typora-user-images/Screenshot 2020-04-29 at 5.33.47 PM.png)

### Summary（踩过的坑）

1. 有几个误区：

我觉得实际上还是在用 C/C++ 这样的高层语言来思考 verilog

一个是<font color=red>多驱动问题</font>

就是说在一个always语句里面有多个并行执行体来对同一变量赋值

一个是反馈电路，就是在组合逻辑里面不能swap

比如这个就是不行的

```verilog
a = s0;
b = s1;
if ((~of & sf & ~zf) | (of & ~sf & zf)) begin
    s0 = b;
    s1 = a;
end
```

2. 注意是有符号数比较，所以不要照抄PPT！！！
3. 用 MUX 来实现交换
4. 我觉得吧，MUX0～4也可以用ALU的输出来控制，因为最终决定是否改变寄存器的值是使能信号，所以按照我那个电路图来看，使能为1恰好MUX也选择了交换通道

