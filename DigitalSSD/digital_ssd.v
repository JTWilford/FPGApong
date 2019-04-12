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

module digital_ssd (
	input clk,
	input reset,
	//input sys_clk,
	input [10:0] ObjectX,		//Object's origin X Coordinate
	input [9:0] ObjectY,		//Object's origin Y Coordinate
	input [9:0] ObjectScale,		//Object's scale factor in powers of 2
	
	input [3:0] Value,		//0 through 9
	
	input [9:0] PollX,			//Position to Poll X Coordinate
	input [8:0] PollY,			//Position to Poll Y Coordinate
	
	output Hit					//If HIGH, Then Poll Falls Within Object Bounds. Otherwise, LOW
	);
	
	reg [11:0] ObjectW;
	reg [10:0] ObjectH;
	reg [1:0] ScaledPollX;
	reg [3:0] ScaledPollY;
	reg [8:0][3:0] Matrix;
	wire hit_out;
	
	display_matrix matrix(
		.clk(clk),
		.reset(reset),
		.ObjectX(ObjectX),
		.ObjectY(ObjectY),
		.ObjectScale(ObjectScale),
		.Matrix0(Matrix[0]),
		.Matrix1(Matrix[1]),
		.Matrix2(Matrix[2]),
		.Matrix3(Matrix[3]),
		.PollX(PollX),
		.PollY(PollY),
		.Hit(hit_out)
	);
	
	//Get the ADC value from JPorts
	always @ (posedge clk)
	begin
		case(Value)
			4'd0:
				begin
				Matrix[0] <= 9'b111111111;
				Matrix[1] <= 9'b100000001;
				Matrix[2] <= 9'b100000001;
				Matrix[3] <= 9'b111111111;
				end
			4'd1:
				begin
				Matrix[0] <= 9'b000000000;
				Matrix[1] <= 9'b000000000;
				Matrix[2] <= 9'b000000000;
				Matrix[3] <= 9'b111111111;
				end
			4'd2:
				begin
				Matrix[0] <= 9'b111110001;
				Matrix[1] <= 9'b100010001;
				Matrix[2] <= 9'b100010001;
				Matrix[3] <= 9'b100011111;
				end
			4'd3:
				begin
				Matrix[0] <= 9'b100010001;
				Matrix[1] <= 9'b100010001;
				Matrix[2] <= 9'b100010001;
				Matrix[3] <= 9'b111111111;
				end
			4'd4:
				begin
				Matrix[0] <= 9'b000011111;
				Matrix[1] <= 9'b000010000;
				Matrix[2] <= 9'b000010000;
				Matrix[3] <= 9'b111111111;
				end
			4'd5:
				begin
				Matrix[0] <= 9'b100011111;
				Matrix[1] <= 9'b100010001;
				Matrix[2] <= 9'b100010001;
				Matrix[3] <= 9'b111110001;
				end
			4'd6:
				begin
				Matrix[0] <= 9'b111111111;
				Matrix[1] <= 9'b100010000;
				Matrix[2] <= 9'b100010000;
				Matrix[3] <= 9'b111110000;
				end
			4'd7:
				begin
				Matrix[0] <= 9'b000000001;
				Matrix[1] <= 9'b000000001;
				Matrix[2] <= 9'b000000001;
				Matrix[3] <= 9'b111111111;
				end
			4'd8:
				begin
				Matrix[0] <= 9'b111111111;
				Matrix[1] <= 9'b100010001;
				Matrix[2] <= 9'b100010001;
				Matrix[3] <= 9'b111111111;
				end
			4'd9:
				begin
				Matrix[0] <= 9'b000011111;
				Matrix[1] <= 9'b000010001;
				Matrix[2] <= 9'b000010001;
				Matrix[3] <= 9'b111111111;
				end
			default:
				begin
				Matrix[0] <= 9'b000000011;
				Matrix[1] <= 9'b000000001;
				Matrix[2] <= 9'b101110001;
				Matrix[3] <= 9'b000011111;
				end
		endcase
	end
	
	assign Hit = hit_out;

endmodule