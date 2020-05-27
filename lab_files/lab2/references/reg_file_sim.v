`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/12 10:13:11
// Design Name: 
// Module Name: reg_file_sim
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


module reg_file_sim;
reg clk,en,we;
reg [4:0] ra0,ra1,wa;
reg [31:0] wd;
wire [31:0] rd0,rd1;
register_file #(32) regfile(clk,en,ra0,rd0,ra1,rd1,wa,we,wd);
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
    en = 1;
    wa = 0;
    we = 1;
    wd = 1;
    #(PERIOD*5)
    en = 1;
    wa = 1;
    we = 1;
    wd = 2;
     #(PERIOD*5)
     en = 1;
     wa = 2;
     we = 1;
     wd = 3;
      #(PERIOD*5)
      en = 1;
      wa = 1;
      we = 1;
      wd = 2;
      ra0 = 0;
      ra1 = 1;
      #(PERIOD*10) 
      $stop;
      end
endmodule
