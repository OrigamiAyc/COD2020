`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/12 12:52:14
// Design Name: 
// Module Name: tb_mem
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


module tb_mem;
reg [3:0] addr;
reg [7:0] d_in;
wire [7:0] d_out;
reg clk,we;
dist_mem_gen_0 distmem(.a(addr),.d(d_in),.clk(clk),.we(we),.spo(d_out));
parameter PERIOD = 10,CYCLE = 20;
 initial
      begin
          clk = 0;
          repeat (10*CYCLE)
              #(PERIOD/2) clk = ~clk;
          $finish;
      end
 initial 
    begin
    we = 1;
    addr = 7;
    d_in = 5;
    #(PERIOD*5)
    we = 1;
    addr = 6;
    d_in = 3;
    #(PERIOD*5)
    we = 1;
    addr = 5;
    d_in = 1;
    #(PERIOD*5)
    we = 0;
    addr = 8;
     #(PERIOD*5)
     we = 0;
     addr = 7;
     #(PERIOD*5)
          we = 0;
          addr = 6;
     #(PERIOD*5)
               we = 0;
               addr = 5;
     #(PERIOD*5)
                    we = 0;
                    addr = 4;
                    #(PERIOD*5)
                         we = 0;
                         addr = 3;
                         #(PERIOD*5)
                              we = 0;
                              addr = 2;
                              #(PERIOD*5)
                                   we = 0;
                                   addr = 1;
                                   #(PERIOD*5)
                                        we = 0;
                                        addr = 0;
                                        #(PERIOD*5)
                                             $stop;
     end
endmodule
