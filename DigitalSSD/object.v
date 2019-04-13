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

module object (
	input clk,
	input reset,
	//input sys_clk,
	input [10:0] ObjectX,		//Object's origin X Coordinate
	input [9:0] ObjectY,		//Object's origin Y Coordinate
	input [9:0] ObjectW,		//Object's Width in Pixels
	input [8:0] ObjectH,		//Object's Height in Pixels
	
	input [9:0] PollX,			//Position to Poll X Coordinate
	input [8:0] PollY,			//Position to Poll Y Coordinate
	
	output Hit					//If HIGH, Then Poll Falls Within Object Bounds. Otherwise, LOW
	);
	
	reg hit_out;
	
	//Get the ADC value from JPorts
	always @ (posedge clk)
	begin
		if(reset)
		begin
			hit_out <= 1'b0;
		end
		else
		begin
			hit_out <= (ObjectX <= PollX & PollX <= ObjectX+ObjectW)&(ObjectY <= PollY & PollY <= ObjectY+ObjectH);
		end
	end
	
	assign Hit = hit_out;

endmodule