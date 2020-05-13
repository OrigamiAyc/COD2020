`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/04/27 12:40:59
// Design Name: 
// Module Name: testbench_self
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
