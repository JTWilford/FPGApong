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

module dotted_border (
	input clk,
	input reset,
	//input sys_clk,
	input [10:0] ObjectX,		//Object's origin X Coordinate
	input [3:0] ObjectW,		//Every object's width
	input [3:0] ObjectH,		//Every object's height
	
	input [9:0] PollX,			//Position to Poll X Coordinate
	input [8:0] PollY,			//Position to Poll Y Coordinate
	
	output Hit,					//If HIGH, Then Poll Falls Within Object Bounds. Otherwise, LOW
	output Hit2
	);
	wire hit_out;
	wire hit2_out;
	
	//Get the ADC value from JPorts
	always @ (posedge clk)
	begin
		if(ObjectX <= PollX & PollX <= ObjectX+ObjectW)
			begin
				if(PollY%(ObjectW<<1) < ObjectW)
					begin
						hit_out <= 1'b1;
						hit2_out <= 1'b0;
					end
				else
					begin
						hit_out <= 1'b0;
						hit2_out <= 1'b1;
					end
			end
		else
			begin
				hit_out <= 1'b0;
				hit2_out <= 1'b0;
			end
	end
	
	assign Hit = hit_out;
	assign Hit2 = hit2_out;

endmodule