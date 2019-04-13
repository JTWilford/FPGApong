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
	input [3:0] ObjectScale,		//Object's scale factor in powers of 2
	
	input [3:0] Value,		//0 through 9
	
	input [9:0] PollX,			//Position to Poll X Coordinate
	input [8:0] PollY,			//Position to Poll Y Coordinate
	
	output Hit,					//If HIGH, Then Poll Falls Within Object Bounds. Otherwise, LOW
	output Hit2
	);
	
	reg [8:0] Matrix0;
	reg [8:0] Matrix1;
	reg [8:0] Matrix2;
	reg [8:0] Matrix3;
	wire hit_out;
	wire hit2_out;
	
	display_matrix matrix(
		.clk(clk),
		.reset(reset),
		.ObjectX(ObjectX),
		.ObjectY(ObjectY),
		.ObjectScale(ObjectScale),
		.Matrix0(Matrix0),
		.Matrix1(Matrix1),
		.Matrix2(Matrix2),
		.Matrix3(Matrix3),
		.PollX(PollX),
		.PollY(PollY),
		.Hit(hit_out),
		.Hit2(hit2_out)
	);
	
	//Get the ADC value from JPorts
	always @ (posedge clk)
	begin
		case(Value)
			4'd0:
				begin
				Matrix0 <= 9'b111111111;
				Matrix1 <= 9'b100000001;
				Matrix2 <= 9'b100000001;
				Matrix3 <= 9'b111111111;
				end
			4'd1:
				begin
				Matrix0 <= 9'b000000000;
				Matrix1 <= 9'b000000000;
				Matrix2 <= 9'b000000000;
				Matrix3 <= 9'b111111111;
				end
			4'd2:
				begin
				Matrix0 <= 9'b111110001;
				Matrix1 <= 9'b100010001;
				Matrix2 <= 9'b100010001;
				Matrix3 <= 9'b100011111;
				end
			4'd3:
				begin
				Matrix0 <= 9'b100010001;
				Matrix1 <= 9'b100010001;
				Matrix2 <= 9'b100010001;
				Matrix3 <= 9'b111111111;
				end
			4'd4:
				begin
				Matrix0 <= 9'b000011111;
				Matrix1 <= 9'b000010000;
				Matrix2 <= 9'b000010000;
				Matrix3 <= 9'b111111111;
				end
			4'd5:
				begin
				Matrix0 <= 9'b100011111;
				Matrix1 <= 9'b100010001;
				Matrix2 <= 9'b100010001;
				Matrix3 <= 9'b111110001;
				end
			4'd6:
				begin
				Matrix0 <= 9'b111111111;
				Matrix1 <= 9'b100010000;
				Matrix2 <= 9'b100010000;
				Matrix3 <= 9'b111110000;
				end
			4'd7:
				begin
				Matrix0 <= 9'b000000001;
				Matrix1 <= 9'b000000001;
				Matrix2 <= 9'b000000001;
				Matrix3 <= 9'b111111111;
				end
			4'd8:
				begin
				Matrix0 <= 9'b111111111;
				Matrix1 <= 9'b100010001;
				Matrix2 <= 9'b100010001;
				Matrix3 <= 9'b111111111;
				end
			4'd9:
				begin
				Matrix0 <= 9'b000011111;
				Matrix1 <= 9'b000010001;
				Matrix2 <= 9'b000010001;
				Matrix3 <= 9'b111111111;
				end
			default:
				begin
				Matrix0 <= 9'b000000011;
				Matrix1 <= 9'b000000001;
				Matrix2 <= 9'b101110001;
				Matrix3 <= 9'b000011111;
				end
		endcase
	end
	
	assign Hit = hit_out;
	assign Hit2 = hit2_out;

endmodule