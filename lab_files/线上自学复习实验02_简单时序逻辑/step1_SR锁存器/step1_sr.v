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

module step1_sr(
input   S,R,
output  Q,Q_n);
assign  Q   = ~(R | Q_n);
assign  Q_n = ~(S | Q);
endmodule
