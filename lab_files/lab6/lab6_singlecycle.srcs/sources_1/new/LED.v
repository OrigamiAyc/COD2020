`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/28 04:14:04
// Design Name: 
// Module Name: LED
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


module LED
    (
        input clk,
        input [15:0] LED_data,
        output reg [15:0] LED_out
    );

    always @(posedge clk) begin
        if (LED_data == 'dz) begin
            LED_out <= 16'b0;
        end
        else begin
            LED_out <= LED_data;
        end
    end
endmodule
