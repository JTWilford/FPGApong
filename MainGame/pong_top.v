`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// VGA verilog template
// Author:  Da Cheng
//////////////////////////////////////////////////////////////////////////////////
module pong_top(ClkPort, vga_h_sync, vga_v_sync, vgaRed, vgaGreen, vgaBlue, btnU, btnD,
	St_ce_bar, St_rp_bar, Mt_ce_bar, Mt_St_oe_bar, Mt_St_we_bar,
	An0, An1, An2, An3, Ca, Cb, Cc, Cd, Ce, Cf, Cg, Dp,
	LD0, LD1, LD2, LD3, LD4, LD5, LD6, LD7,
	JA, JB,
	Sw);
	input ClkPort, btnU, btnD;
	input [7:0] JA, JB;
	input [7:0] Sw;
	output St_ce_bar, St_rp_bar, Mt_ce_bar, Mt_St_oe_bar, Mt_St_we_bar;
	output vga_h_sync, vga_v_sync, vgaRed, vgaGreen, vgaBlue;
	output An0, An1, An2, An3, Ca, Cb, Cc, Cd, Ce, Cf, Cg, Dp;
	output LD0, LD1, LD2, LD3, LD4, LD5, LD6, LD7;
	reg [2:0] vgaRed, vgaGreen, vgaBlue;
	
	//-----------
	// Signals for Objects
	reg [10:0] obj1X;
	reg [9:0] obj1Y;
	reg [9:0] obj1W;
	reg [8:0] obj1H;
	wire obj1Hit;
	reg [7:0] obj1Color;		//highest 3 bits for Red, next 3 bits for Green, last 2 bits for Blue
	
	reg [10:0] obj2X;
	reg [9:0] obj2Y;
	reg [9:0] obj2W;
	reg [8:0] obj2H;
	wire obj2Hit;
	reg [7:0] obj2Color;
	
	reg [10:0] obj3X;
	reg [9:0] obj3Y;
	reg [9:0] obj3W;
	reg [8:0] obj3H;
	wire obj3Hit;
	reg [7:0] obj3Color;
	//-----------
	// Signals for Potentiometers
	wire [7:0] potentiometer1;
	wire [7:0] potentiometer2;
	
	reg [8:0] scaledPot1;
	reg [8:0] scaledPot2;
	
	reg [9:0] player1Pos;
	reg [9:0] player2Pos;
	//-----------
	// Registers for Ball position and motion
	reg [10:0] ballX;
	reg [9:0] ballY;
	reg ballDirX;
	reg ballDirY;
	reg [3:0] ballXSpeed;
	reg [3:0] ballYSpeed;
	
	reg [9:0] ballYCenter;
	reg [10:0] ballRightX;
	//-----------
	// Player Hitboxes
	wire obj2Collide;
	wire obj3Collide;
	//-----------
	
	
	//////////////////////////////////////////////////////////////////////////////////////////
	
	/*  LOCAL SIGNALS */
	wire	reset, start, ClkPort, board_clk, clk, button_clk;
	
	BUF BUF1 (board_clk, ClkPort); 	
	BUF BUF2 (reset, BtnU);
	BUF BUF3 (start, ~BtnD);
	
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
	object obj2Collision(
		.clk(clk),
		.reset(reset),
		.ObjectX(obj2X),
		.ObjectY(obj2Y),
		.ObjectW(obj2W),
		.ObjectH(obj2H),
		.PollX(ballRightX),
		.PollY(ballYCenter),
		.Hit(obj2Collide)
	);
	object obj3(
		.clk(clk),
		.reset(reset),
		.ObjectX(obj3X),
		.ObjectY(obj3Y),
		.ObjectW(obj3W),
		.ObjectH(obj3H),
		.PollX(counterX),
		.PollY(counterY),
		.Hit(obj3Hit)
	);
	object obj3Collision(
		.clk(clk),
		.reset(reset),
		.ObjectX(obj3X),
		.ObjectY(obj3Y),
		.ObjectW(obj3W),
		.ObjectH(obj3H),
		.PollX(ballX),
		.PollY(ballYCenter),
		.Hit(obj3Collide)
	);
	
	//Read potentiometer 1
	read_potentiometer pot1(
		.sys_clk(clk),
		.reset(reset),
		.JPorts(JA[7:0]),
		.Value(potentiometer1)
	);
	//Read potentiometer 2
	read_potentiometer pot2(
		.sys_clk(clk),
		.reset(reset),
		.JPorts(JB[7:0]),
		.Value(potentiometer2)
	);
	
	/////////////////////////////////////////////////////////////////
	///////////////		Game Logic Starts Here		/////////////////
	/////////////////////////////////////////////////////////////////
	
	reg [3:0] state;
	
	//STATES
	localparam 	
	Q_INIT = 5'b00001, Q_UP = 5'b00010, Q_UB = 5'b00100, Q_UBC = 5'b01000, Q_CC = 5'b10000, Q_UNK = 5'bXXXXX;
	
	//Update the position of the paddle based off of potentiometer
	always @(posedge DIV_CLK[18])
		begin
		if(reset)
			begin
			state <= Q_INIT;
			end
		case(state)
				Q_INIT:
					begin
					//SETUP BALL OBJECT
					obj1X <= 11'd315;
					obj1Y <= 10'd235;
					obj1W <= 10'd10;
					obj1H <= 9'd10;
					obj1Color <= 8'b11011011;		//Make Object 1 yellow
					
					//SETUP PLAYER 2 PADDLE OBJECT
					obj2X <= 11'd620;
					obj2Y <= 10'd0;
					obj2W <= 10'd10;
					obj2H <= 9'd50;
					obj2Color <= 8'b11011011;		//Make Object 2 yellow
					
					//SETUP PLAYER 1 PADDLE OBJECT
					obj3X <= 11'd20;
					obj3Y <= 10'd0;
					obj3W <= 10'd10;
					obj3H <= 9'd50;
					obj3Color <= 8'b11011011;		//Make Object 3 yellow
					
					//SETUP BALL MOTION
					ballX <= 11'd315;
					ballY <= 10'd235;
					ballDirX <= 1'b1;
					ballDirY <= 1'b0;
					ballXSpeed <= 4'd2;
					ballYSpeed <= 4'd2;
					
					state <= Q_UP;
					end
				Q_UP:
					begin
					//Scale the pots from 7-bit to 9-bit
					scaledPot1 = {1'b0, potentiometer1[7:0], 1'b0};
					scaledPot2 = {1'b0, potentiometer2[7:0], 1'b0};
					
					//Add deadzone to player 1 pot
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
					
					//Add deadzone to player 2 pot
					if(scaledPot2 < 41)
						player2Pos <= 0;
					else
						begin
						scaledPot2 = scaledPot2 - 9'd41;
						if(scaledPot2 > 430)
							player2Pos <= 430;
						else
							player2Pos <= scaledPot2;
						end
					obj3Y <= player1Pos;
					obj2Y <= player2Pos;
					
					obj2Color <= Sw[7:0];
					obj3Color <= Sw[7:0];
					
					state <= Q_UB;
					end
				Q_UB:
					begin
					if(ballDirX)
						obj1X <= obj1X + ballXSpeed;
					else
						obj1X <= obj1X - ballXSpeed;
						
					if(ballDirY)
						obj1Y <= obj1Y + ballYSpeed;
					else
						obj1Y <= obj1Y - ballYSpeed;
					
					obj1Color <= Sw[7:0];
					state <= Q_UBC;
					end
				Q_UBC:
					begin
					ballYCenter <= ballY + 5;
					ballRightX <= ballX + 10;
					
					state <= Q_CC;
					end
				Q_CC:
					begin
					//Check if ball hit the bounds of the screen
					if(obj1X == 11'd0 || obj1X == 11'd640)
						ballDirX <= ~ballDirX;
					if(obj1Y == 10'd0 || obj1Y == 10'd480)
						ballDirY <= ~ballDirY;
						
					//Check if ball hit a player paddle
					if(obj2Collide)
						begin
						ballDirX <= 0;
						end
					if(obj3Collide)
						begin
						ballDirX <= 1;
						end
					state <= Q_UP;
					end
				default:
					state <= Q_INIT;
			endcase
		end
	
	/////////////////////////////////////////////////////////////////
	///////////////		VGA control starts here		/////////////////
	/////////////////////////////////////////////////////////////////
	
	//Rendering Block
	always @(posedge clk)
	begin
		if(inDisplayArea)
			begin
			if(obj1Hit)
				begin
				vgaRed <= obj1Color[7:5];
				vgaGreen <= obj1Color[4:2];
				vgaBlue <= obj1Color[1:0];
				end
			else if(obj2Hit)
				begin
				vgaRed <= obj2Color[7:5];
				vgaGreen <= obj2Color[4:2];
				vgaBlue <= obj2Color[1:0];
				end
			else if(obj3Hit)
				begin
				vgaRed <= obj3Color[7:5];
				vgaGreen <= obj3Color[4:2];
				vgaBlue <= obj3Color[1:0];
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
	end
	
	/////////////////////////////////////////////////////////////////
	//////////////  	  VGA control ends here 	 ///////////////////
	/////////////////////////////////////////////////////////////////
	
	/////////////////////////////////////////////////////////////////
	//////////////  	  LD control starts here 	 ///////////////////
	/////////////////////////////////////////////////////////////////
	wire LD0, LD1, LD2, LD3, LD4, LD5, LD6, LD7;
	
	assign LD0 = player2Pos[0];
	assign LD1 = player2Pos[1];
	assign LD2 = player2Pos[2];
	assign LD3 = player2Pos[3];
	assign LD4 = player2Pos[4];
	assign LD5 = player2Pos[5];
	assign LD6 = player2Pos[6];
	assign LD7 = player2Pos[7];
	
	/////////////////////////////////////////////////////////////////
	//////////////  	  LD control ends here 	 	////////////////////
	/////////////////////////////////////////////////////////////////
	
	/////////////////////////////////////////////////////////////////
	//////////////  	  SSD control starts here 	 ///////////////////
	/////////////////////////////////////////////////////////////////
	reg 	[3:0]	SSD;
	wire 	[3:0]	SSD0, SSD1, SSD2, SSD3;
	wire 	[1:0] ssdscan_clk;
	
	assign SSD3 = {0, 0, 0, reset};
	assign SSD2 = {3'b000, player1Pos[8]};
	assign SSD1 = player1Pos[7:4];
	assign SSD0 = state[3:0];
	
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
			4'b1011: SSD_CATHODES = 7'b0000000 ; //11 or B
			4'b1100: SSD_CATHODES = 7'b0110001 ; //12 or C
			4'b1101: SSD_CATHODES = 7'b0000001 ; //13 or D
			4'b1110: SSD_CATHODES = 7'b0001000 ; //14 or E
			4'b1111: SSD_CATHODES = 7'b0111000 ; //15 or F
			default: SSD_CATHODES = 7'bXXXXXXX ; // default is not needed as we covered all cases
		endcase
	end
	
	/////////////////////////////////////////////////////////////////
	//////////////  	  SSD control ends here 	 ///////////////////
	/////////////////////////////////////////////////////////////////
endmodule
