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

module step4_cnt(
input           clk,rst,
input   [6:0]   cnt_step,
output  [7:0]   led);
reg [32:0]  cnt;
always@(posedge clk or posedge rst)
begin
    if(rst)
        cnt <= 33'h1_5555_FFFF;
    else
        cnt <= cnt + cnt_step +1'b1;
end
assign  led = cnt[32:25];
endmodule
