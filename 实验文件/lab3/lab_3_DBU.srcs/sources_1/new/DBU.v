`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/14 09:03:09
// Design Name: 
// Module Name: DBU
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


module DBU
	# (parameter WIDTH = 32)
	(
		input clk, rst,
		input succ,				// control CPU running type
		input step,
		input [2:0] sel,		// overview the result or status of CPU, 0 for result
		// when examining CPU result
		input m_rf,				// 1 for MEM, 0 for RF (Reg_File)
		input inc,				// m_rf_addr ++
		input dec,				// m_rf_addr --
		output reg [15:0] led,
		output [7:0] an,		// anode, choose which SEG shines
		output [7:0] seg		// node
	);

	wire [11:0] status;
	wire [WIDTH-1:0] m_data;
	wire [WIDTH-1:0] rf_data;
	wire [WIDTH-1:0] selected_data;
	wire step_clean, step_edge;
	wire inc_clean, inc_edge;
	wire dec_clean, dec_edge;
	wire [WIDTH-1:0] display_data;

	reg run;
	reg [7:0] m_rf_addr;

	sin_CPU cpu (
		.clk(clk),
		.rst(rst),
		.run(run),
		.m_rf_addr(m_rf_addr),
		.sel(sel),
		.status(status),
		.m_data(m_data),
		.rf_data(rf_data),
		.selected_data(selected_data)
	);

	jitter_clr step_clr (
		.clk(clk),
		.button(step),
		.button_clean(step_clean)
	);

	signal_edge step_ed (
		.clk(clk),
		.button(step_clean),
		.button_edge(step_edge)
	);

	jitter_clr inc_clr (
		.clk(clk),
		.button(inc),
		.button_clean(inc_clean)
	);

	signal_edge inc_ed (
		.clk(clk),
		.button(inc_clean),
		.button_edge(inc_edge)
	);

	jitter_clr dec_clr (
		.clk(clk),
		.button(dec),
		.button_clean(dec_clean)
	);

	signal_edge dec_ed (
		.clk(clk),
		.button(dec_clean),
		.button_edge(dec_edge)
	);

	// run
	always @(posedge clk) begin
		if (succ) begin
			run = 1;
		end else begin
			if (step_edge) begin
				run = 1;
			end else begin
				run = 0;
			end
		end
	end

	assign display_data = m_rf ? m_data : rf_data;

	SegDis #(WIDTH) Seg_Dis (
		.clk(clk),
		.rst(rst),
		.data(display_data),
		.an(an),
		.seg(seg)
	);
	
	// led : m_rf_addr
	always @(posedge clk) begin
		led = 16'h0;
		if (~(|sel)) begin
			led = {8'b0, m_rf_addr};
		end
		else begin
			led = {4'b0, status};
		end
	end

	always @(posedge clk) begin
		if (inc_edge) begin
			m_rf_addr = m_rf_addr + 1;
		end
		else if (dec_edge) begin
			m_rf_addr = m_rf_addr - 1;
		end
		else begin
			m_rf_addr = m_rf_addr;
		end
	end
endmodule
