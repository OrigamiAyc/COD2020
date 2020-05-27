`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/12 13:46:24
// Design Name: 
// Module Name: counter
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


module counter(
	input clk, rst,
	output reg [2:0] scan_cnt
	);

	reg [17:0] cnt;
	// reg [2:0] scan_cnt;

	wire pulse;

	always @(posedge clk) begin
		if (rst) begin
			cnt <= 18'h0;
		end
		else if (cnt == 18'd10000) begin
			cnt <= 18'b0;
		end
		else begin
			cnt <= cnt + 18'b1;
		end
	end

	assign pulse = (cnt == 18'd10000) ? 1'b1 : 1'b0;

	always @(posedge clk) begin
		if (rst) begin
			scan_cnt <= 3'b0;
		end
		else if (pulse) begin
			scan_cnt <= scan_cnt + 3'b1;
		end
	end
endmodule
