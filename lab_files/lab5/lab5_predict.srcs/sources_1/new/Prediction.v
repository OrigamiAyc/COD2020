`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/22 07:35:04
// Design Name: 
// Module Name: Prediction
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


module Prediction_BEQ
        #(parameter WIDTH = 32)
    (
        input clk, rst,
        input PCSrc,
        input write_en,
        input clear,
        output reg if_taken
    );

	localparam [5:0] R_TYPE = 6'b000000;
	localparam [5:0] LW = 6'b100011;
	localparam [5:0] SW = 6'b101011;
	localparam [5:0] BEQ = 6'b000100;
	localparam [5:0] BNE = 6'b000101;
	localparam [5:0] J_TYPE = 6'b000010;
	localparam [5:0] ADDI = 6'b001000;

	localparam [2:0] TAKEN_DEEP = 3'b000;
	localparam [2:0] TAKEN_SHALLOW = 3'b001;
	localparam [2:0] NOT_SHALLOW = 3'b010;
	localparam [2:0] NOT_DEEP = 3'b011;
	localparam [2:0] UNDEFINED = 3'b100;

	reg [1:0] pred_curr_state, pred_next_state;	// for pridiction unit FSM, IF stage

	always @(posedge clk) begin
		if (rst || clear) begin
			pred_curr_state <= UNDEFINED;
		end
		else if (write_en) begin
			pred_curr_state <= pred_next_state;
		end
		else begin
			pred_curr_state <= pred_curr_state;
		end
	end

	always @(*) begin
		case (pred_curr_state)
			UNDEFINED: pred_next_state = PCSrc ? TAKEN_SHALLOW : NOT_SHALLOW;
			TAKEN_DEEP: pred_next_state = PCSrc ? TAKEN_DEEP : TAKEN_SHALLOW;
			TAKEN_SHALLOW: pred_next_state = PCSrc ? TAKEN_DEEP : NOT_SHALLOW;
			NOT_SHALLOW: pred_next_state = PCSrc ? TAKEN_SHALLOW : NOT_DEEP;
			NOT_DEEP: pred_next_state = PCSrc ? NOT_SHALLOW : NOT_DEEP;
			default: pred_next_state = UNDEFINED;
		endcase
	end

	// This controls the change of if_taken, though this signal is being used in IF stage
	always @(*) begin
		if_taken = 0;
		case (pred_curr_state)
			UNDEFINED: if_taken = 1;
			TAKEN_DEEP: if_taken = 1;
			TAKEN_SHALLOW: if_taken = 1;
			NOT_SHALLOW: if_taken = 0;
			NOT_DEEP: if_taken = 0;
			default: if_taken = 0;
		endcase
	end
endmodule

module Prediction_BNE
        #(parameter WIDTH = 32)
    (
        input clk, rst,
        input PCSrc,
        input write_en,
        input clear,
        output reg if_taken
    );

	localparam [5:0] R_TYPE = 6'b000000;
	localparam [5:0] LW = 6'b100011;
	localparam [5:0] SW = 6'b101011;
	localparam [5:0] BEQ = 6'b000100;
	localparam [5:0] BNE = 6'b000101;
	localparam [5:0] J_TYPE = 6'b000010;
	localparam [5:0] ADDI = 6'b001000;

	localparam [2:0] TAKEN_DEEP = 3'b000;
	localparam [2:0] TAKEN_SHALLOW = 3'b001;
	localparam [2:0] NOT_SHALLOW = 3'b010;
	localparam [2:0] NOT_DEEP = 3'b011;
	localparam [2:0] UNDEFINED = 3'b100;

	reg [1:0] pred_curr_state, pred_next_state;	// for pridiction unit FSM, IF stage

	always @(posedge clk) begin
		if (rst || clear) begin
			pred_curr_state <= UNDEFINED;
		end
		else if (write_en) begin
			pred_curr_state <= pred_next_state;
		end
		else begin
			pred_curr_state <= pred_curr_state;
		end
	end


	always @(*) begin
		case (pred_curr_state)
			UNDEFINED: pred_next_state = PCSrc ? TAKEN_SHALLOW : NOT_SHALLOW;
			TAKEN_DEEP: pred_next_state = PCSrc ? TAKEN_DEEP : TAKEN_SHALLOW;
			TAKEN_SHALLOW: pred_next_state = PCSrc ? TAKEN_DEEP : NOT_SHALLOW;
			NOT_SHALLOW: pred_next_state = PCSrc ? TAKEN_SHALLOW : NOT_DEEP;
			NOT_DEEP: pred_next_state = PCSrc ? NOT_SHALLOW : NOT_DEEP;
			default: pred_next_state = UNDEFINED;
		endcase
	end

	// This controls the change of if_taken, though this signal is being used in IF stage
	always @(*) begin
		if_taken = 0;
		case (pred_curr_state)
			UNDEFINED: if_taken = 0;
			TAKEN_DEEP: if_taken = 1;
			TAKEN_SHALLOW: if_taken = 1;
			NOT_SHALLOW: if_taken = 0;
			NOT_DEEP: if_taken = 0;
			default: if_taken = 0;
		endcase
	end
endmodule
