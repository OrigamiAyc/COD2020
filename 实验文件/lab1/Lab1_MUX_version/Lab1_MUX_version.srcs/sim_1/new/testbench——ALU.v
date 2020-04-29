`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/04/29 11:02:20
// Design Name: 
// Module Name: testbench
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



module testbench();
    reg [3:0] a, b;
    reg [2:0] m;
    wire [3:0] y;
    wire zf, cf, of, sf;
    
    parameter PERIOD = 10;
     
    ALU #(4) ALU(.a(a), .b(b), .m(m), .y(y), .cf(cf), .of(of), .zf(zf), .sf(sf));
    
    initial begin
        m = 0;      		//ADD
        a = 4'b0001;
        b = 4'b0010;
        
        #PERIOD m = 1;	//SUB

        a = 4'b0010;
        b = 4'b0001;

        #PERIOD m = 2;	//AND
        a = 4'b0001;
        b = 4'b0101;
        
        #PERIOD m = 3;	//OR
        a = 4'b0001;
        b = 4'b0101;
        
        #PERIOD m = 4;	//XOR
        a = 4'b0001;
        b = 4'b0101;
        
        #PERIOD m = 5;	//other
        a = 4'b0001;
        b = 4'b0101;
        
        #PERIOD;
        $finish;      
    end
endmodule
