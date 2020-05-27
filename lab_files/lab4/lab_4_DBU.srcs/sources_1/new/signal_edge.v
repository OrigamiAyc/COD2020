`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/06 01:30:06
// Design Name: 
// Module Name: signal_edge
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
