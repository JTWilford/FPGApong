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

module display_matrix (
	input clk,
	input reset,
	//input sys_clk,
	input [10:0] ObjectX,		//Object's origin X Coordinate
	input [9:0] ObjectY,		//Object's origin Y Coordinate
	input [3:0] ObjectScale,		//Object's scale factor in powers of 2
	
	input [8:0] Matrix0,	//The 4x9 matrix to display
	input [8:0] Matrix1,
	input [8:0] Matrix2,
	input [8:0] Matrix3,
	
	input [9:0] PollX,			//Position to Poll X Coordinate
	input [8:0] PollY,			//Position to Poll Y Coordinate
	
	output Hit					//If HIGH, Then Poll Falls Within Object Bounds. Otherwise, LOW
	);
	
	reg [11:0] ObjectW;
	reg [10:0] ObjectH;
	reg [1:0] ScaledPollX;
	reg [3:0] ScaledPollY;
	wire inArea;
	reg hit_out;
	
	object area(
		.clk(clk),
		.reset(reset),
		.ObjectX(ObjectX),
		.ObjectY(ObjectY),
		.ObjectW(ObjectW),
		.ObjectH(ObjectH),
		.PollX(PollX),
		.PollY(PollY),
		.Hit(inArea)
	);
	
	//Get the ADC value from JPorts
	always @ (posedge clk)
	begin
		if(reset)
		begin
			hit_out <= 1'b0;
		end
		else
		begin
			//Calculate this object's width
			ObjectW = 11'd4 << ObjectScale;
			ObjectH = 10'd9 << ObjectScale;
			
			//Check if poll falls within the bounds of this object
			if(inArea)
				begin
					//Scale the polling coords
					ScaledPollX = (PollX - ObjectX) >> ObjectScale;
					ScaledPollY = (PollY - ObjectY) >> ObjectScale;
					
					if(ScaledPollX == 0)
						hit_out <= Matrix0[ScaledPollY];
					if(ScaledPollX == 1)
						hit_out <= Matrix1[ScaledPollY];
					if(ScaledPollX == 2)
						hit_out <= Matrix2[ScaledPollY];
					if(ScaledPollX == 3)
						hit_out <= Matrix3[ScaledPollY];
				end
			else
				hit_out <= 0;
			//hit_out <= inArea;
		end
	end
	
	assign Hit = hit_out;

endmodule