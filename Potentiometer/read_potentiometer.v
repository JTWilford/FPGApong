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

module read_potentiometer (
	input [7:0] JPorts,
	input reset,
	input sys_clk,
	output [7:0] Value
	);
	
	reg [7:0] val_out;
	
	//Get the ADC value from JPorts
	always @ (posedge sys_clk)
	begin
		if(reset)
		begin
			val_out <= 8'b00000000;
		end
		else
		begin
			val_out[7:0] <= JPorts[7:0];
		end
	end
	
	assign Value[7:0] = val_out[7:0];

endmodule