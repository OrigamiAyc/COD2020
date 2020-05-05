`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/05 15:17:21
// Design Name: 
// Module Name: RAM
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


module ram_16x8
    (
        input clk,
        input en, we,           // enable, write enable
        input [3:0] addr,       // address, used both by read and write
        input [7:0] din,        // input data
        input [7:0] dout        // output data
    );

    reg [3:0] addr_reg;
    reg [7:0] mem [0:3];

    // initialize the contents of the RAM
    initial
        $readmemh("initial_file",mem);

    assign dout = mem[addr_reg];

    always @(posedge clk) begin
        if (en) begin
            addr_reg <= addr;
            if (we) begin
                mem[addr] <= din;
            end
        end
    end
endmodule
