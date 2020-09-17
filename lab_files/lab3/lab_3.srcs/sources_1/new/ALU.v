`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/12 11:49:53
// Design Name: 
// Module Name: ALU
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

// on basis of the COD 5th edition, we use the following parameters
module ALU
    #(parameter WIDTH = 32) 	// data width
(
    output reg [WIDTH-1:0] y,   // calculation result
    output reg zf,              // zero sign
    output reg cf,              // jinwei sign
	output reg of,				// yichu
	output reg sf,				// for signed cal
	input [WIDTH-1:0] a,
	input [WIDTH-1:0] b,
	input [2:0] m				// type
);

	localparam ADD = 3'b010;
    localparam SUBTRACT = 3'b110;
    localparam AND = 3'b000;
    localparam OR = 3'b001;
    localparam XOR = 3'b100;
    localparam SLT = 3'b111;

    always @(*) begin
		{zf,of,cf,sf} = 4'b0000;
		case (m)
			ADD:  begin
				{cf, y} = a + b;
				of = (~a[WIDTH-1] & ~b[WIDTH-1] & y[WIDTH-1]) | (a[WIDTH-1] & b[WIDTH-1] & ~y[WIDTH-1]);
				zf = ~|y;
			end
			SUBTRACT: begin
				{cf, y} = a - b;
				of = (~a[WIDTH-1] & b[WIDTH-1] & y[WIDTH-1]) | (a[WIDTH-1] & ~b[WIDTH-1] & ~y[WIDTH-1]);
				zf = ~|y;
				sf = y[WIDTH-1];
			end
			AND: begin
				y = a & b;
				zf = ~|y;
				sf = y[WIDTH-1];
			end
			OR: begin
				y = a | b;
				zf = ~|y;
				sf = y[WIDTH-1];
			end
			XOR: begin
				y = a ^ b;
				zf = ~|y;
				sf = y[WIDTH-1];
			end
            SLT: begin
                y = (a < b) ? 32'b1 : 32'b0;
            end
			default: y = a;
		endcase
	end
endmodule
