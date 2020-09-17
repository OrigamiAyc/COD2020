`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/28 02:30:53
// Design Name: 
// Module Name: IO_Interface
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


module IO_Interface_SW
	(
		input clk, rst,
		// input [31:0] Instruction_Bus,	// from bus(CPU)
		input [15:0] Data_IO_In,		// from I/O devices
		input button,					// if pressed (1), read-data from SW is valid
		input launch,					// lasts for 1 cycle, if 1, means CPU is waking up I/O devices
		input catch,					// lasts for 1 cycle, if 1, means CPU is ending transmission
		output [31:0] Data_Bus_Out,		// to bus(CPU)
		output [1:0] Status_Bus			// to bus(CPU), D&B
	);

	reg [31:0] Ins_Reg;					// save ins from CPU
	reg [15:0] DBR;						// data buffer in Interface, FIFO
	// reg buffer_count_curr;				// count for items in buffer
	// reg buffer_count_next;				// count for items in buffer

	// wake up, saving instruction into Ins_Reg
	// always @(posedge clk) begin
	// 	if (rst || catch) begin
	// 		Ins_Reg <= 0;
	// 	end
	// 	else if (launch) begin
	// 		Ins_Reg <= Instruction_Bus;
	// 	end
	// 	else begin
	// 		Ins_Reg <= Ins_Reg;
	// 	end
	// end

	// start to prepare
	reg [1:0] curr_state, next_state;
	localparam IDLE = 2'b00;
	localparam DONE = 2'b10;
	localparam BUSY = 2'b01;

	initial begin
		next_state = IDLE;
	end

	always @(posedge clk) begin
		if (rst) begin
			curr_state <= IDLE;
		end
		else begin
			curr_state <= next_state;
		end
	end

	assign Status_Bus = curr_state;
	assign Data_Bus_Out = {((DBR[15]) ? 16'hffff : 16'h0000), DBR};

	always @(*) begin
		if (curr_state == IDLE && launch) begin
			next_state = BUSY;
		end
		else if (curr_state == BUSY && button) begin
			next_state = DONE;
		end
		else if (curr_state == DONE && catch) begin
			next_state = IDLE;
		end
		else begin
			next_state = next_state;
		end
	end

	always @(posedge button) begin
		if (rst) begin
			DBR <= 0;
		end
		if (curr_state == BUSY) begin
			DBR <= Data_IO_In;
		end
		else begin
			DBR <= DBR;
		end
	end
endmodule

module IO_Interface_LED
	(
		input clk, rst,
		input [31:0] Data_Bus_In,		// from bus(CPU)
		// input [31:0] Instruction_Bus,	// from bus(CPU)
		input launch,					// lasts for 1 cycle, if 1, means CPU is waking up I/O devices
		output [15:0] LED_return		// back to top file, assuming that there ARE LEDs
	);

	reg [15:0] Data_IO_Out;				// to I/O devices
	reg [31:0] Ins_Reg;					// save ins from CPU
	reg [15:0] DBR [0:1];				// data buffer in Interface, FIFO

	// wake up, saving instruction into Ins_Reg
	// always @(posedge clk) begin
	// 	if (launch) begin
	// 		Ins_Reg <= Instruction_Bus;
	// 	end
	// 	else begin
	// 		Ins_Reg <= Ins_Reg;
	// 	end
	// end

	// start to prepare
	always @(posedge clk) begin
		if (rst) begin
			Data_IO_Out <= 0;
		end
		else if (launch) begin
			Data_IO_Out <= Data_Bus_In[15:0];
		end 
		else begin
			Data_IO_Out <= Data_IO_Out;
		end
	end

	LED LED (
		.clk(clk),
		.LED_data(Data_IO_Out),
		.LED_out(LED_return)
	);
endmodule
