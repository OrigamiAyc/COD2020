`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/03/21 03:15:11
// Design Name: 
// Module Name: tb
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


module tb();

reg [2:0] a,b;
reg [1:0] fun;

alu alu(
    .a(a),
    .b(b),
    .fun(fun),
    .s(),
    .y()
    );
    
initial
begin
    repeat(20)
    begin
        a = $random % 8;
        b = $random % 8;
        fun = $random % 4;
        #20;
    end
    $stop;
end
endmodule
