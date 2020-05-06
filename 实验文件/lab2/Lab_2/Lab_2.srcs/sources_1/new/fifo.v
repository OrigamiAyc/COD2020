`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2020/05/05 15:35:26
// Design Name:
// Module Name: fifo
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

// reg [7:0] queue [0:4]
// 32 numbers, each 8 bits long
module fifo( // already no shake waves
	input clk,rst,
	input [7:0] din,		// data enqueue
	input en_in,			// enqueue enable, valid when '1'
	input en_out,			// dequeue enable, valid when '1'
	output [7:0] dout,		// data dequeue
	output [4:0] count	// data amount count, 5 bits since need to show 0~16
	);

	parameter EMPTY = 2'b00;
	parameter NORMAL = 2'b01;// neither empty nor full
	parameter FULL = 2'b10;

	reg [4:0] cnt;
	reg [3:0] head, tail, addr;
	reg [2:0] curr_state, next_state;
	// reg eni, eno;

	wire [3:0] ADDR;
	wire en;

	assign ADDR = addr;
	assign count = cnt;
	// assign en = eni + eno;

	blk_mem_gen_0 ram_read (
		.addra(ADDR),
		.clka(clk),
		.dina(din),
		.douta(dout),
		// .ena(en),
		.ena(1),
		.wea(en_in)
	);

	initial begin
		head = 4'b0;
		tail = 4'b0;
		cnt = 5'b0;
		// eni = 1'b0;
		// eno = 1'b0;
	end

	always @(posedge clk or posedge rst) begin
		if (rst) begin // empty the queue
			cnt = 5'b0;
			head = 4'b0;
			tail = 4'b0;
			// eni = 1'b0;
			// eno = 1'b0;
			curr_state <= EMPTY;
		end
		else begin
			curr_state <= next_state;
		end
	end

	always @(posedge clk) begin
		if (en_in | en_out) begin
			if (en_in) begin
				case (curr_state)
					EMPTY: begin
						next_state <= NORMAL;
						cnt = cnt + 5'b1;
						addr = tail;
						tail <= tail + 4'b1;
						head = head;
						// eni = 1'b1;
						// eno = 1'b0;
					end
					NORMAL: begin
						if (cnt == 5'b01111) begin
							next_state <= FULL;
							cnt = cnt + 5'b1;
							addr = tail;
							tail <= tail + 4'b1;
							head = head;
							// eni = 1'b1;
							// eno = 1'b0;
						end else begin
							next_state <= NORMAL;
							cnt = cnt + 5'b1;
							addr = tail;
							tail <= tail + 4'b1;
							head = head;
							// eni = 1'b1;
							// eno = 1'b0;
						end
					end
					FULL: begin // cannot enqueue, remain FULL status
						next_state <= FULL;
						cnt = cnt;
						tail = tail;
						addr = tail;
						head = head;
						// eni = 1'b0;
						// eno = 1'b0;
					end
					default: begin
						next_state <= next_state;
						cnt = cnt;
						tail = tail;
						addr = addr;
						head = head;
						// eni = 1'b0;
						// eno = 1'b0;
					end
				endcase
			end
			else if (en_out) begin
				case (curr_state)
					EMPTY: begin // cannot dequeue, remain EMPTY status
						next_state <= EMPTY;
						cnt = cnt;
						tail = tail;
						head = head;
						addr = head;
						// eni = 1'b0;
						// eno = 1'b0;
					end
					NORMAL: begin
						if (cnt == 5'b00001) begin
							next_state <= EMPTY;
							cnt = cnt - 5'b1;
							tail = tail;
							addr = head;
							head <= head + 4'b1;
							// eni = 1'b0;
							// eno = 1'b1;
						end else begin
							next_state <= NORMAL;
							cnt = cnt - 5'b1;
							tail = tail;
							addr = head;
							head <= head + 4'b1;
							// eni = 1'b0;
							// eno = 1'b1;
						end
					end
					FULL: begin
						next_state <= NORMAL;
						cnt = cnt - 5'b1;
						tail = tail;
						addr = head;
						head <= head + 4'b1;
						// eni = 1'b0;
						// eno = 1'b1;
					end
					default: begin
						next_state <= next_state;
						cnt = cnt;
						tail = tail;
						head = head;
						addr = addr;
						// eni = 1'b0;
						// eno = 1'b0;
					end
				endcase
			end
		end
		else begin
			next_state <= next_state;
			cnt = cnt;
			tail = tail;
			head = head;
			addr = addr;
			// eni = 1'b0;
			// eno = 1'b0;
		end
	end
endmodule
