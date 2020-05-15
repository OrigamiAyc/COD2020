`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/14 15:39:35
// Design Name: 
// Module Name: SegDis
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


module SegDis
	#(parameter WIDTH = 32)
	(
		input clk,rst,
		input [WIDTH-1:0] data,
		output reg [7:0] an,
		output [7:0] seg
	);

	wire [2:0] scan_cnt;

	reg [WIDTH-1:0] show_data;

	counter clk_1KHz (
		.clk(clk),
		.rst(rst),
		.scan_cnt(scan_cnt)
	);

	initial
	begin
		an = 8'b0;
		show_data = 32'b0;
	end

	always @(posedge clk) begin
		case (scan_cnt)
			3'h0: an <= 8'b1111_1110;
			3'h1: an <= 8'b1111_1101;
			3'h2: an <= 8'b1111_1011;
			3'h3: an <= 8'b1111_0111;
			3'h4: an <= 8'b1110_1111;
			3'h5: an <= 8'b1101_1111;
			3'h6: an <= 8'b1011_1111;
			3'h7: an <= 8'b0111_1111;
			default: an <= 'dz;
		endcase
	end

	always @(posedge clk) begin
		case (scan_cnt)
			3'h0: show_data <= data[3:0];
			3'h1: show_data <= data[7:4];
			3'h2: show_data <= data[11:8];
			3'h3: show_data <= data[15:12];
			3'h4: show_data <= data[19:16];
			3'h5: show_data <= data[23:20];
			3'h6: show_data <= data[27:24];
			3'h7: show_data <= data[31:28];
			default: show_data <= 'dz;
		endcase
	end

	dist_seg_dis_decode decode (
		.a(show_data),
		.spo(seg)
	);
endmodule
