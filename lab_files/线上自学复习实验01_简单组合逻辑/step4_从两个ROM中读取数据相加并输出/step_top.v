`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/04/03 19:36:30
// Design Name: 
// Module Name: top
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


module top(
input   [3:0] rom1_addr,rom2_addr,
output  [7:0] led);
wire    [7:0] rom1_data,rom2_data;  
dist_mem_gen_0 rom1(
.a   (rom1_addr), 
.spo (rom1_data));
dist_mem_gen_0 rom2(
    //to be added
));
assign led =  ; //to be added
endmodule
