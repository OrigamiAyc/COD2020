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
input       [7:0] sw,
output reg  [2:0] led,
output            error);
    assign error = ~(|sw);
always@(*)
begin
    if(sw[7])       led = 3'b111;
    else if(sw[6])  led = 3'b110;
    else if(sw[5])  led = 3'b101;
    else if(sw[4])  led = 3'b100;
    else if(sw[3])  led = 3'b011;
    else if(sw[2])  led = 3'b010;
    else if(sw[1])  led = 3'b001;
    else if(sw[0])  led = 3'b000;
    else            led = 3'b000;
end
endmodule
