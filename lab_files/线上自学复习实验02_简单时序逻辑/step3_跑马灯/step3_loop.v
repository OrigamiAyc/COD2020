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

module step3_loop(
input               clk,rst,
output reg  [7:0]   led);
always@(posedge clk or posedge rst)
begin
    if(rst)
        led <= 8'b0000_0111;
    else
        led <= {led[6:0],led[7]};
end
endmodule
