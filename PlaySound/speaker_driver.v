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

module speaker_driver (
	input reset,
	input sys_clk,
	input [3:0] Tone,		//4-bit code for tone (tones listed below)
	output Out
	);
	
	reg [9:0] frequency;
	wire wave_out;
	
	localparam Tone_C = 4'b0000, Tone_C_sh = 4'b0001, Tone_D = 4'b0010, Tone_D_sh = 4'b0011, Tone_E = 4'b0100,
	Tone_F = 4'b0101, Tone_F_sh = 4'b0110, Tone_G = 4'b0111, Tone_G_sh = 4'b1000, Tone_A = 4'b1001,
	Tone_A_sh = 4'b1010, Tone_B = 4'b1011;
	
	frequency_generator wave(
		.reset(reset),
		.sys_clk(sys_clk),
		.frequency(frequency),
		.Out(wave_out)
	);
	
	//Get the ADC value from JPorts
	
	always @ (posedge sys_clk)
	begin
		if(reset)
		begin
			wave_out <= 1'b0;
			frequency <= 10'd1024;
		end
		else
		begin
			
			case(tone)
				Tone_C:
					begin
						frequency <= 10'd261;		//Middle C
					end
				Tone_C_sh
					begin
						frequency <= 10'd277;		//C#
					end
				Tone_D:
					begin
						frequency <= 10'd293;		//D
					end
				Tone_D_sh
					begin
						frequency <= 10'd311;		//D#
					end
				Tone_E:
					begin
						frequency <= 10'd329;		//E
					end
				Tone_F:
					begin
						frequency <= 10'd349;		//F
					end
				Tone_F_sh
					begin
						frequency <= 10'd370;		//F#
					end
				Tone_G:
					begin
						frequency <= 10'd392;		//G
					end
				Tone_G_sh
					begin
						frequency <= 10'd415;		//G#
					end
				Tone_A:
					begin
						frequency <= 10'd440;		//A
					end
				Tone_A_sh
					begin
						frequency <= 10'd466;		//A#
					end
				Tone_C:
					begin
						frequency <= 10'd494;		//B
					end
				default:
					begin
						frequency <= 10'd1024;
						wave_out <= 0;
					end
			endcase
		end
	end
	
	assign Out = wave_out;

endmodule