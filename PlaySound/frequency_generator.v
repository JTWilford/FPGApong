//////////////////////////////////////////////////////////////////////////////////
// Author:			Justin Wilford
// Create Date:		03/17/2019 
// File Name:		generate_pwm.v
// Description: 
//		Generates a PWM signal based on switch inputs.
//
// Revision: 		1.0
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module frequency_generator (
	input reset,
	input sys_clk,
	input [9:0] frequency,		//Supports frequencies from 100Khz to 1024Khz
	output Out
	);
	
	reg wave_out;
	reg [9:0] timer;
	reg [9:0] max_time;
	
	//Get the ADC value from JPorts
	always @ (posedge sys_clk)
	begin
		if(reset)
		begin
			wave_out <= 1'b0;
		end
		else
		begin
			max_time = 17'd100000 / frequency;
			timer <= timer + 1;
			if(timer >= max_time)
				begin
					timer <= 10'd0;
					wave_out <= ~wave_out;
				end
		end
	end
	
	assign Out = wave_out;

endmodule