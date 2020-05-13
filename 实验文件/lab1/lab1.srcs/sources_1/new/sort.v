`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/04/25 05:39:26
// Design Name: 
// Module Name: sort
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


module sort
    #(parameter  N = 4) // data width
    (
        output reg [N-1:0] s0,s1,s2,s3, // s3 > s2 > ...
        output reg done,    // signal of done
        input [N-1:0] x0,x1,x2,x3,    // original input statistics
        input clk,rst   // clock, reset
    );

    localparam LOAD = 3'b000;
    localparam CX01A = 3'b001;
    localparam CX12A = 3'b010;
    localparam CX23A = 3'b011;
	localparam CX01B = 3'b100;
	localparam CX12B = 3'b101;
	localparam CX01C = 3'b110;
    localparam HLT = 3'b111;
	localparam MINUS = 3'b001;

	wire zf, cf, sf, of;
	wire [N-1:0] A, B, OUT;

    reg [N-1:0] a, b;
	reg [2:0] curr_state, next_state;

	assign A = a;
	assign B = b;

	ALU #(N) alu (
		.a(A),
		.b(B),
		.y(OUT),
		.zf(zf),
		.cf(cf),
		.of(of),
		.sf(sf),
		.m(MINUS)
	);

    always @(posedge clk) begin
        begin
            case (curr_state)
                LOAD: begin
					done = 0;
					next_state = CX01A;
					s0 = x0;
					s1 = x1;
					s2 = x2;
					s3 = x3;
				end
				CX01A: begin
					next_state = CX12A;
					a = s0;
					b = s1;
					if ((~of & sf & ~zf) | (of & ~sf & zf)) begin
						s0 = b;
						s1 = a;
					end
				end
				CX12A: begin
					next_state = CX23A;
					a = s1;
					b = s2;
					if ((~of & sf & ~zf) | (of & ~sf & zf)) begin
						s1 = b;
						s2 = a;
					end
				end
				CX23A: begin
					next_state = CX01B;
					a = s2;
					b = s3;
					if ((~of & sf & ~zf) | (of & ~sf & zf)) begin
						s2 = b;
						s3 = a;
					end
				end
				CX01B: begin
					next_state = CX12B;
					a = s0;
					b = s1;
					if ((~of & sf & ~zf) | (of & ~sf & zf)) begin
						s0 = b;
						s1 = a;
					end
				end
				CX12B: begin
					next_state = CX01C;
					a = s1;
					b = s2;
					if ((~of & sf & ~zf) | (of & ~sf & zf)) begin
						s1 = b;
						s2 = a;
					end
				end
				CX01C: begin
					next_state = HLT;
					a = s0;
					b = s1;
					if ((~of & sf & ~zf) | (of & ~sf & zf)) begin
						s0 = b;
						s1 = a;
					end
				end
				HLT: begin
					done = 1;
				end
                default: begin
					done = 0;
					next_state = HLT;
					s0 = x0;
					s1 = x1;
					s2 = x2;
					s3 = x3;
				end
            endcase
        end
    end

	always @(posedge clk) begin
		if (rst) begin
			next_state <= CX01A;
			curr_state <= LOAD;
		end
		else begin
			curr_state <= next_state;
		end
	end

endmodule
