`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/12 12:36:24
// Design Name: 
// Module Name: blk_sim
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


module blk_sim;
reg [3:0] addr;
reg clk,wea;
reg [7:0] dina;
wire [7:0] douta;
blk_mem_gen_test blkmem (
		.addra(addr),
		.clka(clk),
		.dina(dina),
		.douta(douta),
		.ena(1),
		.wea(wea)
	);
parameter PERIOD = 10,CYCLE = 20;
initial
          begin
              clk = 0;
              repeat (3*CYCLE)
                  #(PERIOD/2) clk = ~clk;
              $finish;
          end
 initial
    begin
    addr = 0;
    wea = 1;
    dina = 5;
    #(PERIOD*5)
    addr = 1;
        wea = 1;
        dina = 3;
        #(PERIOD*5)
addr = 2;
            wea = 1;
            dina = 1;
            #(PERIOD*5)
            addr = 3;
                wea = 1;
                dina = 10;
                #(PERIOD*5)
                addr = 0;
                    wea = 0;
                    #(PERIOD*5)
                     addr = 1;
                                       wea = 0;
                                       #(PERIOD*5)
                                        addr = 3;
                                                          wea = 0;
                                                          #(PERIOD*5)
                                                          $stop;
                                                          end
endmodule
