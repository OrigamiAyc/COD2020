`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/04/28 15:21:15
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
        output [N-1:0] s0,s1,s2,s3, // s3 > s2 > ...
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

    wire [3:0]i0, i1, i2, i3; // registers input port
	wire zf, cf, sf, of; // ALU output port
    wire [3:0] a, b, out; // temp variables, for ALU in & out

    reg m0, m1, m2, m3, m4, m5; // 0~3 are for data input (to regs), 4 & 5 are for ALU input
    reg en0, en1, en2, en3; // for registers
	reg [2:0] curr_state, next_state;
 
    //data path 
    register R0( .in(i0), .en(en0), .rst(rst), .clk(clk), .out(s0) );
    register R1( .in(i1), .en(en1), .rst(rst), .clk(clk), .out(s1) );
    register R2( .in(i2), .en(en2), .rst(rst), .clk(clk), .out(s2) );
    register R3( .in(i3), .en(en3), .rst(rst), .clk(clk), .out(s3) );

	ALU #(N) alu( .a(a), .b(b), .y(out), .zf(zf), .cf(cf), .of(of), .sf(sf), .m(MINUS) );

    mux M0( .m(m0), .in_1(x0), .in_2(s1), .out(i0));
    mux M1( .m(m1), .in_1(x1), .in_2(a), .out(i1));
    mux M2( .m(m2), .in_1(x2), .in_2(b), .out(i2));
    mux M3( .m(m3), .in_1(x3), .in_2(s2), .out(i3));
    mux M4( .m(m4), .in_1(s0), .in_2(s2), .out(a));
    mux M5( .m(m5), .in_1(s1), .in_2(s3), .out(b));

    //control Unit 
    always@(posedge clk, posedge rst)
        if(rst)
            curr_state <= LOAD;
        else
            curr_state <= next_state;
    
    // FSM
    always@(*) begin
        if(rst)
            next_state = LOAD;
        else     
            case (curr_state)
                LOAD: next_state = CX01A;
                CX01A: next_state = CX12A;
                CX12A: next_state = CX23A;
                CX23A: next_state = CX01B;
                CX01B: next_state = CX12B;
                CX12B: next_state = CX01C;
                CX01C: next_state = HLT;
                HLT: next_state = HLT;
                default: next_state = HLT;
            endcase
    end

    always@(*)
    begin
        {m0,m1,m2,m3,m4,m5,en0,en1,en2,en3,done} = 11'h0;
        case (curr_state)
            LOAD: begin
                {m1,m2,m3,m4,m5,en0,en1,en2,en3} = 6'b00_0000_1111;
                done = 0;
            end
            CX01A, CX01B, CX01C: begin
                m0 = 1;
                m1 = 1;
                en0 = (~of & ~sf & ~zf) | (of & sf & ~zf);
                en1 = (~of & ~sf & ~zf) | (of & sf & ~zf);
            end 
            CX12A, CX12B: begin
                m1 = 1;
                m2 = 1;
                m4 = 1;
                en1 = ~((~of & ~sf & ~zf) | (of & sf & ~zf));
                en2 = ~((~of & ~sf & ~zf) | (of & sf & ~zf));
            end
            CX23A: begin
                m2 = 1;
                m3 = 1;
                m4 = 1;
                m5 = 1;
                en2 = (~of & ~sf & ~zf) | (of & sf & ~zf);
                en3 = (~of & ~sf & ~zf) | (of & sf & ~zf);
            end
            HLT: done = 1;
        endcase
    end

endmodule
