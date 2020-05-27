`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/04/14 10:40:29
// Design Name: 
// Module Name: step1_sr
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

module step2_dff(
input                clk,rst,
input        [3:0]   din,
output  reg  [3:0]   dout);
always@(posedge clk or posedge rst)
begin
    if(rst)
        dout <= 4'b0;
    else
        dout <= din;
end
endmodule
