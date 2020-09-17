`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/30 07:46:47
// Design Name: 
// Module Name: tb_top
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


module tb_top();
    reg clk, rst;
    reg button_real;
    reg [15:0] SW_real;

    top fake_computer (
        .clk(clk),
        .rst(rst),
        .button_real(button_real),
        .SW_real(SW_real)
    );

    initial
    begin
        clk = 1;
        rst = 1;
        # 2 rst = 0;
        # 998 $finish;
    end

    initial
    begin
        button_real = 0;
        # 20 button_real = 1;
        # 20 button_real = 0;
        # 40 button_real = 1;
        # 20 button_real = 0;
        # 10 button_real = 0;
        # 20 button_real = 0;
        # 870 $finish;
    end

    initial
    begin
        SW_real = 0;
        # 10 SW_real = 2'd1;
        # 50 SW_real = 2'd2;
        # 940 $finish;
    end

    always
    # 1 clk = ~clk;
endmodule
