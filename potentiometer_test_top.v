//////////////////////////////////////////////////////////////////////////////////
// Author:			Justin Wilford
// Create Date:		03/17/2019 
// File Name:		servo_test_top.v
// Description: 
//		Runs a servo based off of switch inputs
//
// Revision: 		1.0
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module potentiometer_test_top (   
		MemOE, MemWR, RamCS, FlashCS, QuadSpiFlashCS, // Disable the three memory chips
		ClkPort,                           // the 100 MHz incoming clock signal
		Led,								// LED ports for debugging
		JA									// JA ports for external communication
	  );


	/*  INPUTS */
	// Clock & Reset I/O
	input	ClkPort;	
	
	/*  OUTPUTS */
	// Control signals on Memory chips 	(to disable them)
	output 	MemOE, MemWR, RamCS, FlashCS, QuadSpiFlashCS;
	// Project Specific Outputs
	input [7:0]	JA;
	output [7:0]	Led;
	
	
	
	/*  LOCAL SIGNALS */
	wire		reset, ClkPort;
	wire		board_clk, sys_clk;
	reg [7:0]	inJA;
	reg [7:0]	outLed;
	wire [7:0]	Led_wire;

	
//------------	
// Disable the three memories so that they do not interfere with the rest of the design.
	assign {MemOE, MemWR, RamCS, FlashCS, QuadSpiFlashCS} = 5'b11111;
	assign Led[7:0] = outLed[7:0];
	
	
//------------
// CLOCK DIVISION

	// The clock division circuitary works like this:
	//
	// ClkPort ---> [BUFGP2] ---> board_clk
	// board_clk ---> [clock dividing counter] ---> DIV_CLK
	// DIV_CLK ---> [constant assignment] ---> sys_clk;
	
	BUFGP BUFGP1 (board_clk, ClkPort); 	

// As the ClkPort signal travels throughout our design,
// it is necessary to provide global routing to this signal. 
// The BUFGPs buffer these input ports and connect them to the global 
// routing resources in the FPGA.

//------------
// INPUT: SWITCHES & BUTTONS
	
	always @ (board_clk)
	begin
		inJA[7:0] = JA[7:0];
	end

//------------
// DESIGN
	read_potentiometer(
		.JPorts(inJA),
		.reset(reset),
		.sys_clk(board_clk),
		.Value(Led_wire)
		);
//------------
// OUTPUT: JA
//------------
// OUTPUT: Led
	
	always @ (Led_wire)
	begin
		outLed[7:0] = Led_wire[7:0];
	end
//------------
endmodule


