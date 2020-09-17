`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/06 07:16:11
// Design Name: 
// Module Name: tb_CPU
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


module tb_CPU();
    reg clk, rst;

    pipeline_CPU cpu (
        .clk(clk),
        .rst(rst)
    );

    initial
    begin
        clk = 1;
        rst = 1;
        # 10 rst = 0;
        # 490 $finish;
    end

    always
    # 5 clk = ~clk;
endmodule
