`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/30 07:01:18
// Design Name: 
// Module Name: top
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


module top
	(
		input clk, rst,
		input button_real,
		input [15:0] SW_real
	);

	wire button;								        // put to SW Interface
	wire [15:0] SW_data;								// put to SW Interface
	wire [31:0] Data_to_CPU, Data_from_CPU;
	wire [1:0] status;
	wire launch, launch_sw, launch_led;
	wire Device_Choose;
	wire catch;
	wire [15:0] LED_data;

	assign launch_sw = ~Device_Choose & launch;
	assign launch_led = Device_Choose & launch;

	sin_CPU CPU (
		.clk(clk),
		.rst(rst),
		.Data_Bus_Receive(Data_to_CPU),
		.Status_Bus_Receive(status),
		.launch(launch),
		.Device_Choose(Device_Choose),
		.catch(catch),
		.Data_Bus_Send(Data_from_CPU)
	);

	SW SW (
		.clk(clk),
		.rst(rst),
		.button_real(button_real),
		.SW_real(SW_real),
		.button(button),
		.SW_out(SW_data)
	);

	IO_Interface_SW SWITCH (
		.clk(clk),
		.rst(rst),
		.Data_IO_In(SW_data),
		.button(button),
		.launch(launch_sw),
		.catch(catch),
		.Data_Bus_Out(Data_to_CPU),
		.Status_Bus(status)
	);

	IO_Interface_LED LED (
		.clk(clk),
        .rst(rst),
		.Data_Bus_In(Data_from_CPU),
		.launch(launch_led),
		.LED_return(LED_data)
	);
endmodule
