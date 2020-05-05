`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/05 15:35:26
// Design Name: 
// Module Name: fifo
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

// reg [7:0] queue [0:4]
// 32 numbers, each 8 bits long
module fifo(
    input clk,rst,
    input [7:0] din,        // data enqueue
    input en_in,            // enqueue enable, valid when '1'
    input en_out,           // dequeue enable, valid when '1'
    output [7:0] dout,      // data dequeue
    output [4:0] count,     // data amount count
    );
endmodule
