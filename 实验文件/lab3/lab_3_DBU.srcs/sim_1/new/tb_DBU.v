`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/15 01:26:49
// Design Name: 
// Module Name: tb_DBU
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


module tb_DBU();
	localparam WIDTH = 32;
	localparam CWKTIME = 10;

	reg clk, rst, succ, step;
	reg [2:0] sel;
	reg m_rf, inc, dec;
	
	wire [15:0] led;
	wire [7:0] an;
	wire [7:0] seg;

	DBU #(WIDTH) dbu (
		.clk(clk),
		.rst(rst),
		.succ(succ),
		.step(step),
		.sel(sel),
		.m_rf(m_rf),
		.inc(inc),
		.dec(dec),
		.led(led),
		.an(an),
		.seg(seg)
	);

	initial begin
		clk = 1;
		// rst = 1;
		// # (CWKTIME) rst = 0;
	end

	always
	# (CWKTIME / 2) clk = ~clk;

	initial
	begin
			rst=1;sel=0;m_rf=0;inc=0;dec=0;succ=1;step=0;
		# (CWKTIME) rst=0;sel=0;m_rf=0;inc=0;dec=0;succ=1;step=0;
		# (CWKTIME) rst=0;sel=0;m_rf=0;inc=1;dec=0;succ=1;step=0;
		# (CWKTIME) rst=0;sel=0;m_rf=0;inc=0;dec=0;succ=1;step=0;
		# (CWKTIME) rst=0;sel=0;m_rf=0;inc=1;dec=0;succ=1;step=0;
		# (CWKTIME) rst=0;sel=0;m_rf=0;inc=0;dec=0;succ=1;step=0;
		# (CWKTIME) rst=0;sel=1;m_rf=0;inc=0;dec=0;succ=1;step=0;
		# (CWKTIME) rst=0;sel=2;m_rf=0;inc=0;dec=0;succ=1;step=0;
		# (CWKTIME) rst=0;sel=3;m_rf=0;inc=0;dec=0;succ=1;step=0;
		# (CWKTIME) rst=0;sel=4;m_rf=0;inc=0;dec=0;succ=1;step=0;
		# (CWKTIME) rst=0;sel=5;m_rf=0;inc=0;dec=0;succ=1;step=0;
		# (CWKTIME) rst=0;sel=5;m_rf=0;inc=0;dec=0;succ=1;step=0;
		# (CWKTIME) rst=0;sel=0;m_rf=1;inc=0;dec=0;succ=0;step=1;
		# (CWKTIME) rst=0;sel=0;m_rf=1;inc=0;dec=0;succ=0;step=0;
		# (CWKTIME) $finish;
	end
endmodule
