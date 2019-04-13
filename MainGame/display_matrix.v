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
	
	output Hit,					//If HIGH, Then Poll Falls Within Object Bounds. Otherwise, LOW
	output Hit2
	);
	
	reg [11:0] ObjectW;
	reg [10:0] ObjectH;
	reg [9:0] TransformedPollX;
	reg [8:0] TransformedPollY;
	reg [1:0] ScaledPollX;
	reg [3:0] ScaledPollY;
	reg hit_out;
	reg hit2_out;
	
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
			if((ObjectX <= PollX & PollX < ObjectX+ObjectW)&(ObjectY <= PollY & PollY < ObjectY+ObjectH))
				begin
					hit_out <= 1'b0;
					hit2_out <= 1'b1;
					//Scale the polling coords
					TransformedPollX = PollX - ObjectX;
					TransformedPollY = PollY - ObjectY;
					ScaledPollX = TransformedPollX >> ObjectScale;
					ScaledPollY = TransformedPollY >> ObjectScale;
					
					case(ScaledPollX)
						2'b00:	hit_out <= Matrix0[ScaledPollY];
						2'b01:	hit_out <= Matrix1[ScaledPollY];
						2'b10:	hit_out <= Matrix2[ScaledPollY];
						2'b11:	hit_out <= Matrix3[ScaledPollY];
					endcase
				end
			else
				begin
				hit_out <= 1'b0;
				hit2_out <= 1'b0;
			//hit_out <= inArea;
				end
		end
	end
	
	assign Hit = hit_out;
	assign Hit2 = hit2_out;

endmodule