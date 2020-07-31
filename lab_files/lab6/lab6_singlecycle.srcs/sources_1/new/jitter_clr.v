`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/06 01:35:00
// Design Name: 
// Module Name: jitter_clr
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


module jitter_clr(
    input clk,
    input button,
    output button_clean
    );

    reg [3:0] cnt;

    always @(posedge clk) begin
        if (button == 1'b0) begin
            cnt <= 4'h0;
        end
        else if (cnt < 4'h8) begin
            cnt <= cnt + 1'b1;
        end
    end

    assign button_clean = cnt[3];
endmodule
