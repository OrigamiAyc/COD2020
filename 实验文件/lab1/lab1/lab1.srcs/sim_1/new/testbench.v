`timescale 1ns / 100ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/04/27 11:23:12
// Design Name: 
// Module Name: sort
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


module sort_tb;
    reg clk, rst;
    reg [3:0] x0, x1, x2;
    wire [3:0] s0, s1, s2;
    wire done;

parameter PERIOD = 10, 	//时钟周期长度
CYCLE = 20;		//时钟个数

    ALU #(4) ALU (clk, rst, x0, x1, x2, s0, s1, s2, done);

    initial
    begin
        clk = 0;
        repeat (2 * CYCLE)
        	#(PERIOD/2) clk = ~clk;
        $finish;
    end

    initial
    begin
    rst = 1;
    #PERIOD rst = 0;

    #(PERIOD*5) rst = 1;
    #PERIOD rst = 0;

    #(PERIOD*5) rst = 1;
    #PERIOD rst = 0;
    end

    initial
    begin
    x0 = 3;
    x1 = 5;
    x2 = 7;

    #(PERIOD*5);
    x0 = 10;
    x1 = 8;
    x2 = 15;

    #(PERIOD*5);
    x0 = 2;
    x1 = 3;
    x2 = 9;
end
endmodule
