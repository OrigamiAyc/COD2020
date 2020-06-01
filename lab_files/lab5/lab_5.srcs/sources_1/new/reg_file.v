`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/12 11:49:53
// Design Name: 
// Module Name: reg_file
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


// Containing inner-forwarding
module reg_file
	#(parameter WIDTH = 32)
	(
		input clk,
		input [2:0] forward,		// 000 for non-forwarding, 001 from ALU to A, 010 from ALU to B, 011 from MEM to A, 100 from MEM to B
		input [WIDTH-1:0] ex,		// input data from ALU-result
		input [WIDTH-1:0] mem,		// input data from mem-visit-result
		input [4:0] ra0,			// read port 0 addr
		output reg [WIDTH-1:0] rd0,	// read port 0 data
		input [4:0] ra1,			// read port 1 addr
		output reg [WIDTH-1:0] rd1,	// read port 1 data
		input [4:0] wa,				// write port addr
		input we,					// write enable, valid at '1'
		input [WIDTH-1:0] wd		// write port data
	);

	reg [WIDTH-1:0] reg_file [0:31];

	always @(*) begin
		case (forward)
			// not outside forwarding, consider inner-register forwarding (WB->ID)
			3'b000: begin
				if ((wa == ra0) && (|wa) && we) begin
					rd0 = wd;
					rd1 = reg_file[ra1];
				end
				else if ((wa == ra1) && (|wa) && we) begin
					rd0 = reg_file[ra0];
					rd1 = wd;
				end
				else begin
					rd0 = reg_file[ra0];
					rd1 = reg_file[ra1];
				end
			end
			// forward from EX, since a ALU result is needed
			3'b001: begin
				rd0 = ex;
				if ((wa == ra1) && (|wa) && we) begin
					rd1 = wd;
				end
				else begin
					rd1 = reg_file[ra1];
				end
			end
			3'b010: begin
				if ((wa == ra0) && (|wa) && we) begin
					rd0 = wd;
				end
				else begin
					rd0 = reg_file[ra0];
				end
				rd1 = ex;
			end
			3'b011: begin
				rd0 = mem;
				if ((wa == ra1) && (|wa) && we) begin
					rd1 = wd;
				end else begin
					rd1 = reg_file[ra1];
				end
			end
			3'b100: begin
				if ((wa == ra0) && (|wa) && we) begin
					rd0 = wd;
				end else begin
					rd0 = reg_file[ra0];
				end
				rd1 = mem;
			end
			default: begin
				rd0 = 'dz;
				rd1 = 'dz;
			end
		endcase
	end
	
	// control from outside
	// always @(*) begin
	// 	case (forwarding)
	// 		2'b00: begin
	// 			rd0 = reg_file[ra0];
	// 			rd1 = reg_file[ra1];
	// 		end
	// 		2'b01: begin
	// 			rd0 = wd;
	// 			rd1 = reg_file[ra1];
	// 		end
	// 		2'b10: begin
	// 			rd0 = reg_file[ra0];
	// 			rd1 = wd;
	// 		end
	// 		default: begin
	// 			rd0 = 'dz;
	// 			rd1 = 'dz;
	// 		end
	// 	endcase
	// end

	integer i;						// loop varible
	initial begin
		for (i = 0; i < 32; i = i + 1) begin
			reg_file [i] = 0;
		end
	end

	always @(posedge clk) begin
		if (we && wa != 4'b0) begin
			reg_file[wa] <= wd;
		end
	end
endmodule
