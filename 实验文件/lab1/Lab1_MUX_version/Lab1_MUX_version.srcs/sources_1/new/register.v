`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/04/28 15:18:37
// Design Name: 
// Module Name: register
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
