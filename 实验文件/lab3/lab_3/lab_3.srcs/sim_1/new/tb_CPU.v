`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/13 09:41:12
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


module tb_CPU;
    reg clk, rst;

    single_cycle_CPU cpu (
        .clk(clk),
        .rst(rst)
    );

    initial
    begin
        clk = 1;
        rst = 1;
        # 10 rst = 0;
    end

    always
    # 5 clk = ~clk;
endmodule
