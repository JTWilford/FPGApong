`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// VGA verilog template
// Author:  Da Cheng
//////////////////////////////////////////////////////////////////////////////////
module pong_top(ClkPort, vga_h_sync, vga_v_sync, vgaRed, vgaGreen, vgaBlue, Sw0, Sw1, btnU, btnD,
	St_ce_bar, St_rp_bar, Mt_ce_bar, Mt_St_oe_bar, Mt_St_we_bar,
	An0, An1, An2, An3, Ca, Cb, Cc, Cd, Ce, Cf, Cg, Dp,
	LD0, LD1, LD2, LD3, LD4, LD5, LD6, LD7,
	JA, JB);
	input ClkPort, Sw0, btnU, btnD, Sw0, Sw1;
	input [7:0] JA, JB;
	output St_ce_bar, St_rp_bar, Mt_ce_bar, Mt_St_oe_bar, Mt_St_we_bar;
	output vga_h_sync, vga_v_sync, vgaRed, vgaGreen, vgaBlue;
	output An0, An1, An2, An3, Ca, Cb, Cc, Cd, Ce, Cf, Cg, Dp;
	output LD0, LD1, LD2, LD3, LD4, LD5, LD6, LD7;
	reg [2:0] vgaRed, vgaGreen, vgaBlue;
	//-----------
	// Signals for Objects
	reg [9:0] obj1X;
	reg [8:0] obj1Y;
	reg [9:0] obj1W;
	reg [9:0] obj1H;
	wire obj1Hit;
	reg [7:0] obj1Color;		//highest 3 bits for Red, next 3 bits for Green, last 2 bits for Blue
	
	reg [9:0] obj2X;
	reg [8:0] obj2Y;
	reg [9:0] obj2W;
	reg [9:0] obj2H;
	wire obj2Hit;
	reg [7:0] obj2Color;
	
	reg [9:0] obj3X;
	reg [8:0] obj3Y;
	reg [9:0] obj3W;
	reg [9:0] obj3H;
	wire obj3Hit;
	reg [7:0] obj3Color;
	//-----------
	// Signals for Potentiometers
	wire [7:0] potentiometer1;
	wire [7:0] potentiometer2;
	
	reg [8:0] scaledPot1;
	reg [8:0] scaledPot2;
	
	reg [8:0] player1Pos;
	reg [8:0] player2Pos;
	//-----------
	
	
	//////////////////////////////////////////////////////////////////////////////////////////
	
	/*  LOCAL SIGNALS */
	wire	reset, start, ClkPort, board_clk, clk, button_clk;
	
	BUF BUF1 (board_clk, ClkPort); 	
	BUF BUF2 (reset, Sw0);
	BUF BUF3 (start, Sw1);
	
	reg [27:0]	DIV_CLK;
	always @ (posedge board_clk, posedge reset)  
	begin : CLOCK_DIVIDER
      if (reset)
			DIV_CLK <= 0;
      else
			DIV_CLK <= DIV_CLK + 1'b1;
	end	

	assign	button_clk = DIV_CLK[18];
	assign	clk = DIV_CLK[1];
	assign 	{St_ce_bar, St_rp_bar, Mt_ce_bar, Mt_St_oe_bar, Mt_St_we_bar} = {5'b11111};
	
	wire inDisplayArea;
	wire [9:0] CounterX;
	wire [9:0] CounterY;

	hvsync_generator syncgen(.clk(clk), .reset(reset),.vga_h_sync(vga_h_sync), .vga_v_sync(vga_v_sync), .inDisplayArea(inDisplayArea), .CounterX(CounterX), .CounterY(CounterY));
	
	object obj1(
		.clk(clk),
		.reset(reset),
		.ObjectX(obj1X),
		.ObjectY(obj1Y),
		.ObjectW(obj1W),
		.ObjectH(obj1H),
		.PollX(CounterX),
		.PollY(CounterY),
		.Hit(obj1Hit)
	);
	object obj2(
		.clk(clk),
		.reset(reset),
		.ObjectX(obj2X),
		.ObjectY(obj2Y),
		.ObjectW(obj2W),
		.ObjectH(obj2H),
		.PollX(CounterX),
		.PollY(CounterY),
		.Hit(obj2Hit)
	);
	object obj3(
		.clk(clk),
		.reset(reset),
		.ObjectX(obj3X),
		.ObjectY(obj3Y),
		.ObjectW(obj3W),
		.ObjectH(obj3H),
		.PollX(CounterX),
		.PollY(CounterY),
		.Hit(obj3Hit)
	);
	
	read_potentiometer pot1(
		.sys_clk(clk),
		.reset(reset),
		.JPorts(JA[7:0]),
		.Value(potentiometer1)
	);
	
	/////////////////////////////////////////////////////////////////
	///////////////		VGA control starts here		/////////////////
	/////////////////////////////////////////////////////////////////
	
	//Update the position of the paddle based off of potentiometer
	always @(posedge DIV_CLK[20])
		begin
		scaledPot1 = ({potentiometer1[6:0], 2'b00});
		if(scaledPot1 < 41)
			player1Pos <= 0;
		else
			begin
			scaledPot1 = scaledPot1 - 9'd41;
			if(scaledPot1 > 430)
				player1Pos <= 430;
			else
				player1Pos <= scaledPot1;
			end
		end
	
	always @(posedge clk)
	begin
		if(reset)
			begin
			obj1X <= 10'd100;
			obj1Y <= 9'd100;
			obj1W <= 10'd300;
			obj1H <= 9'd100;
			obj1Color <= 8'b11100000;		//Make Object 1 all red
			
			obj2X <= 10'd500;
			obj2Y <= 9'd50;
			obj2W <= 10'd100;
			obj2H <= 9'd400;
			obj2Color <= 8'b000010110;		//Make Object 2 greenish-blue
			
			obj3X <= 10'd0;
			obj3Y <= 9'd0;
			obj3W <= 10'd10;
			obj3H <= 9'd50;
			obj3Color <= 8'b111111110;		//Make Object 3 white
			end
		if(inDisplayArea)
			begin
			if(obj1Hit)
				begin
				vgaRed <= obj1Color[7:5];
				vgaGreen <= obj1Color[4:2];
				vgaBlue <= {obj1Color[1:0],0};
				end
			else if(obj2Hit)
				begin
				vgaRed <= obj2Color[7:5];
				vgaGreen <= obj2Color[4:2];
				vgaBlue <= {obj2Color[1:0],0};
				end
			else if(obj3Hit)
				begin
				vgaRed <= obj3Color[7:5];
				vgaGreen <= obj3Color[4:2];
				vgaBlue <= {obj3Color[1:0],0};
				end
			else
				begin
				vgaRed <= 3'b000;
				vgaGreen <= 3'b000;
				vgaBlue <= 3'b000;
				end
			end
		else
			begin
			vgaRed <= 3'b000;
			vgaGreen <= 3'b000;
			vgaBlue <= 3'b000;
			end
		obj3Y <= player1Pos;
	end
	
	/////////////////////////////////////////////////////////////////
	//////////////  	  VGA control ends here 	 ///////////////////
	/////////////////////////////////////////////////////////////////
	
	/////////////////////////////////////////////////////////////////
	//////////////  	  LD control starts here 	 ///////////////////
	/////////////////////////////////////////////////////////////////
	`define QI 			2'b00
	`define QGAME_1 	2'b01
	`define QGAME_2 	2'b10
	`define QDONE 		2'b11
	
	reg [3:0] p2_score;
	reg [3:0] p1_score;
	reg [1:0] state;
	wire LD0, LD1, LD2, LD3, LD4, LD5, LD6, LD7;
	
	assign LD0 = (p1_score == 4'b1010);
	assign LD1 = (p2_score == 4'b1010);
	
	assign LD2 = start;
	assign LD4 = reset;
	
	assign LD3 = (state == `QI);
	assign LD5 = (state == `QGAME_1);	
	assign LD6 = (state == `QGAME_2);
	assign LD7 = (state == `QDONE);
	
	/////////////////////////////////////////////////////////////////
	//////////////  	  LD control ends here 	 	////////////////////
	/////////////////////////////////////////////////////////////////
	
	/////////////////////////////////////////////////////////////////
	//////////////  	  SSD control starts here 	 ///////////////////
	/////////////////////////////////////////////////////////////////
	reg 	[3:0]	SSD;
	wire 	[3:0]	SSD0, SSD1, SSD2, SSD3;
	wire 	[1:0] ssdscan_clk;
	
	assign SSD3 = 4'b1111;
	assign SSD2 = 4'b1111;
	assign SSD1 = 4'b1111;
	assign SSD0 = position[3:0];
	
	// need a scan clk for the seven segment display 
	// 191Hz (50MHz / 2^18) works well
	assign ssdscan_clk = DIV_CLK[19:18];	
	assign An0	= !(~(ssdscan_clk[1]) && ~(ssdscan_clk[0]));  // when ssdscan_clk = 00
	assign An1	= !(~(ssdscan_clk[1]) &&  (ssdscan_clk[0]));  // when ssdscan_clk = 01
	assign An2	= !( (ssdscan_clk[1]) && ~(ssdscan_clk[0]));  // when ssdscan_clk = 10
	assign An3	= !( (ssdscan_clk[1]) &&  (ssdscan_clk[0]));  // when ssdscan_clk = 11
	
	always @ (ssdscan_clk, SSD0, SSD1, SSD2, SSD3)
	begin : SSD_SCAN_OUT
		case (ssdscan_clk) 
			2'b00:
					SSD = SSD0;
			2'b01:
					SSD = SSD1;
			2'b10:
					SSD = SSD2;
			2'b11:
					SSD = SSD3;
		endcase 
	end	

	// and finally convert SSD_num to ssd
	reg [6:0]  SSD_CATHODES;
	assign {Ca, Cb, Cc, Cd, Ce, Cf, Cg, Dp} = {SSD_CATHODES, 1'b1};
	// Following is Hex-to-SSD conversion
	always @ (SSD) 
	begin : HEX_TO_SSD
		case (SSD)		
			4'b1111: SSD_CATHODES = 7'b1111111 ; //Nothing 
			4'b0000: SSD_CATHODES = 7'b0000001 ; //0
			4'b0001: SSD_CATHODES = 7'b1001111 ; //1
			4'b0010: SSD_CATHODES = 7'b0010010 ; //2
			4'b0011: SSD_CATHODES = 7'b0000110 ; //3
			4'b0100: SSD_CATHODES = 7'b1001100 ; //4
			4'b0101: SSD_CATHODES = 7'b0100100 ; //5
			4'b0110: SSD_CATHODES = 7'b0100000 ; //6
			4'b0111: SSD_CATHODES = 7'b0001111 ; //7
			4'b1000: SSD_CATHODES = 7'b0000000 ; //8
			4'b1001: SSD_CATHODES = 7'b0000100 ; //9
			4'b1010: SSD_CATHODES = 7'b0001000 ; //10 or A
			default: SSD_CATHODES = 7'bXXXXXXX ; // default is not needed as we covered all cases
		endcase
	end
	
	/////////////////////////////////////////////////////////////////
	//////////////  	  SSD control ends here 	 ///////////////////
	/////////////////////////////////////////////////////////////////
endmodule
