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
	
	input [5:0] Value,		//64 possible characters. We use 37.
							//Numbers are 0-9, Letters are 10-35. ? is anything else
	
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
	
	always @ (posedge clk)
	begin
		case(Value)
			6'd0:		//Number 0
				begin
				Matrix0 <= 9'b111111111;
				Matrix1 <= 9'b100000001;
				Matrix2 <= 9'b100000001;
				Matrix3 <= 9'b111111111;
				end
			6'd1:		//Number 1
				begin
				Matrix0 <= 9'b000000000;
				Matrix1 <= 9'b000000000;
				Matrix2 <= 9'b000000000;
				Matrix3 <= 9'b111111111;
				end
			6'd2:		//Number 2
				begin
				Matrix0 <= 9'b111110001;
				Matrix1 <= 9'b100010001;
				Matrix2 <= 9'b100010001;
				Matrix3 <= 9'b100011111;
				end
			6'd3:		//Number 3
				begin
				Matrix0 <= 9'b100010001;
				Matrix1 <= 9'b100010001;
				Matrix2 <= 9'b100010001;
				Matrix3 <= 9'b111111111;
				end
			6'd4:		//Number 4
				begin
				Matrix0 <= 9'b000011111;
				Matrix1 <= 9'b000010000;
				Matrix2 <= 9'b000010000;
				Matrix3 <= 9'b111111111;
				end
			6'd5:		//Number 5
				begin
				Matrix0 <= 9'b100011111;
				Matrix1 <= 9'b100010001;
				Matrix2 <= 9'b100010001;
				Matrix3 <= 9'b111110001;
				end
			6'd6:		//Number 6
				begin
				Matrix0 <= 9'b111111111;
				Matrix1 <= 9'b100010000;
				Matrix2 <= 9'b100010000;
				Matrix3 <= 9'b111110000;
				end
			6'd7:		//Number 7
				begin
				Matrix0 <= 9'b000000001;
				Matrix1 <= 9'b000000001;
				Matrix2 <= 9'b000000001;
				Matrix3 <= 9'b111111111;
				end
			6'd8:		//Number 8
				begin
				Matrix0 <= 9'b111111111;
				Matrix1 <= 9'b100010001;
				Matrix2 <= 9'b100010001;
				Matrix3 <= 9'b111111111;
				end
			6'd9:		//Number 9
				begin
				Matrix0 <= 9'b000011111;
				Matrix1 <= 9'b000010001;
				Matrix2 <= 9'b000010001;
				Matrix3 <= 9'b111111111;
				end
			6'd10:		//Letter A
				begin
				Matrix0 <= 9'b111111110;
				Matrix1 <= 9'b000010001;
				Matrix2 <= 9'b000010001;
				Matrix3 <= 9'b111111110;
				end
			6'd11:		//Letter B
				begin
				Matrix0 <= 9'b111111111;
				Matrix1 <= 9'b100010001;
				Matrix2 <= 9'b100010001;
				Matrix3 <= 9'b011111110;
				end
			6'd12:		//Letter C
				begin
				Matrix0 <= 9'b011111110;
				Matrix1 <= 9'b100000001;
				Matrix2 <= 9'b100000001;
				Matrix3 <= 9'b100000001;
				end
			6'd13:		//Letter D
				begin
				Matrix0 <= 9'b111111111;
				Matrix1 <= 9'b100000001;
				Matrix2 <= 9'b100000001;
				Matrix3 <= 9'b011111110;
				end
			6'd14:		//Letter E
				begin
				Matrix0 <= 9'b111111111;
				Matrix1 <= 9'b100010001;
				Matrix2 <= 9'b100010001;
				Matrix3 <= 9'b100010001;
				end
			6'd15:		//Letter F
				begin
				Matrix0 <= 9'b111111111;
				Matrix1 <= 9'b000100001;
				Matrix2 <= 9'b000100001;
				Matrix3 <= 9'b000100001;
				end
			6'd16:		//Letter G
				begin
				Matrix0 <= 9'b111111111;
				Matrix1 <= 9'b100000001;
				Matrix2 <= 9'b100010001;
				Matrix3 <= 9'b111110011;
				end
			6'd17:		//Letter H
				begin
				Matrix0 <= 9'b111111111;
				Matrix1 <= 9'b000010000;
				Matrix2 <= 9'b000010000;
				Matrix3 <= 9'b111111111;
				end
			6'd18:		//Letter I
				begin
				Matrix0 <= 9'b100000001;
				Matrix1 <= 9'b111111111;
				Matrix2 <= 9'b111111111;
				Matrix3 <= 9'b100000001;
				end
			6'd19:		//Letter J
				begin
				Matrix0 <= 9'b011000001;
				Matrix1 <= 9'b100000001;
				Matrix2 <= 9'b100000001;
				Matrix3 <= 9'b111111111;
				end
			6'd20:		//Letter K
				begin
				Matrix0 <= 9'b111111111;
				Matrix1 <= 9'b000010000;
				Matrix2 <= 9'b000101000;
				Matrix3 <= 9'b111000111;
				end
			6'd21:		//Letter L
				begin
				Matrix0 <= 9'b111111111;
				Matrix1 <= 9'b100000000;
				Matrix2 <= 9'b100000000;
				Matrix3 <= 9'b100000000;
				end
			6'd22:		//Letter M
				begin
				Matrix0 <= 9'b111111111;
				Matrix1 <= 9'b000001110;
				Matrix2 <= 9'b000001110;
				Matrix3 <= 9'b111111111;
				end
			6'd23:		//Letter N
				begin
				Matrix0 <= 9'b111111111;
				Matrix1 <= 9'b000011100;
				Matrix2 <= 9'b011100000;
				Matrix3 <= 9'b111111111;
				end
			6'd24:		//Letter O
				begin
				Matrix0 <= 9'b011111110;
				Matrix1 <= 9'b100000001;
				Matrix2 <= 9'b100000001;
				Matrix3 <= 9'b011111110;
				end
			6'd25:		//Letter P
				begin
				Matrix0 <= 9'b111111111;
				Matrix1 <= 9'b000010001;
				Matrix2 <= 9'b000010001;
				Matrix3 <= 9'b000001110;
				end
			6'd26:		//Letter Q
				begin
				Matrix0 <= 9'b011111110;
				Matrix1 <= 9'b100000001;
				Matrix2 <= 9'b110000001;
				Matrix3 <= 9'b111111110;
				end
			6'd27:		//Letter R
				begin
				Matrix0 <= 9'b111111111;
				Matrix1 <= 9'b000010001;
				Matrix2 <= 9'b000010001;
				Matrix3 <= 9'b111101110;
				end
			6'd28:		//Letter S
				begin
				Matrix0 <= 9'b100001110;
				Matrix1 <= 9'b100010001;
				Matrix2 <= 9'b100010001;
				Matrix3 <= 9'b011100001;
				end
			6'd29:		//Letter T
				begin
				Matrix0 <= 9'b000000001;
				Matrix1 <= 9'b111111111;
				Matrix2 <= 9'b111111111;
				Matrix3 <= 9'b000000001;
				end
			6'd30:		//Letter U
				begin
				Matrix0 <= 9'b011111111;
				Matrix1 <= 9'b100000000;
				Matrix2 <= 9'b100000000;
				Matrix3 <= 9'b111111111;
				end
			6'd31:		//Letter V
				begin
				Matrix0 <= 9'b001111111;
				Matrix1 <= 9'b110000000;
				Matrix2 <= 9'b110000000;
				Matrix3 <= 9'b001111111;
				end
			6'd32:		//Letter W
				begin
				Matrix0 <= 9'b111111111;
				Matrix1 <= 9'b011000000;
				Matrix2 <= 9'b011000000;
				Matrix3 <= 9'b111111111;
				end
			6'd33:		//Letter X
				begin
				Matrix0 <= 9'b111101111;
				Matrix1 <= 9'b000010000;
				Matrix2 <= 9'b000010000;
				Matrix3 <= 9'b111101111;
				end
			6'd34:		//Letter Y
				begin
				Matrix0 <= 9'b100001111;
				Matrix1 <= 9'b100010000;
				Matrix2 <= 9'b100010000;
				Matrix3 <= 9'b111111111;
				end
			6'd35:		//Letter Z
				begin
				Matrix0 <= 9'b111000001;
				Matrix1 <= 9'b100110001;
				Matrix2 <= 9'b100011001;
				Matrix3 <= 9'b100000111;
				end
			6'd36:		//Space Character
				begin
				Matrix0 <= 9'b000000000;
				Matrix1 <= 9'b000000000;
				Matrix2 <= 9'b000000000;
				Matrix3 <= 9'b000000000;
				end
			
			default:	// ? Character
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