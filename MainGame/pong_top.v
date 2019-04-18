`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// VGA verilog template
// Author:  Da Cheng
//////////////////////////////////////////////////////////////////////////////////
module pong_top(ClkPort, vga_h_sync, vga_v_sync, vgaRed, vgaGreen, vgaBlue, btnU, btnD, btnC,
	St_ce_bar, St_rp_bar, Mt_ce_bar, Mt_St_oe_bar, Mt_St_we_bar,
	An0, An1, An2, An3, Ca, Cb, Cc, Cd, Ce, Cf, Cg, Dp,
	LD0, LD1, LD2, LD3, LD4, LD5, LD6, LD7,
	JA, JB,
	Sw);
	input ClkPort, btnU, btnD, btnC;
	input [7:0] JA, JB;
	input [7:0] Sw;
	output St_ce_bar, St_rp_bar, Mt_ce_bar, Mt_St_oe_bar, Mt_St_we_bar;
	output vga_h_sync, vga_v_sync, vgaRed, vgaGreen, vgaBlue;
	output An0, An1, An2, An3, Ca, Cb, Cc, Cd, Ce, Cf, Cg, Dp;
	output LD0, LD1, LD2, LD3, LD4, LD5, LD6, LD7;
	reg [2:0] vgaRed, vgaGreen, vgaBlue;
	
	//-----------
	// Signals for Objects
	//Ball
	reg [10:0] obj1X;
	reg [9:0] obj1Y;
	reg [9:0] obj1W;
	reg [8:0] obj1H;
	wire obj1Hit;
	reg [7:0] obj1Color;		//highest 3 bits for Red, next 3 bits for Green, last 2 bits for Blue
	
	//Right Player
	reg [10:0] obj2X;
	reg [9:0] obj2Y;
	reg [9:0] obj2W;
	reg [8:0] obj2H;
	wire obj2Hit;
	reg [7:0] obj2Color;
	
	//Left Player
	reg [10:0] obj3X;
	reg [9:0] obj3Y;
	reg [9:0] obj3W;
	reg [8:0] obj3H;
	wire obj3Hit;
	reg [7:0] obj3Color;
	
	//
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
	reg [6:0] ballXSpeed;
	reg [6:0] ballYSpeed;
	
	reg [9:0] ballYCenter;
	reg [10:0] ballRightX;
	
	reg [1:0] speedMultiplier;
	//-----------
	// Player Hitboxes
	wire obj2Collide;
	wire obj3Collide;
	//-----------
	// Number Display
	reg [10:0] LeftSSDX;		//Object's origin X Coordinate
	reg [9:0] LeftSSDY;			//Object's origin Y Coordinate
	reg [9:0] LeftSSDScale;		//Object's scale factor in powers of 2
	reg [7:0] LeftSSDColor;
	
	reg [3:0] P1Score;		//0 through 9
	
	wire LeftSSDHit;
	
	reg [10:0] RightSSDX;		//Object's origin X Coordinate
	reg [9:0] RightSSDY;			//Object's origin Y Coordinate
	reg [9:0] RightSSDScale;		//Object's scale factor in powers of 2
	reg [7:0] RightSSDColor;
	
	reg [3:0] P2Score;		//0 through 9
	
	wire RightSSDHit;
	
	//-----------
	// Border
	reg [10:0] BorderX;
	reg [10:0] BorderW;
	reg [8:0] BorderH;
	reg [7:0] BorderColor;
	
	wire BorderHit;
	//-----------
	// General Purpose Characters (16 total)
		//All character's colors and hit markers
	reg [7:0] GPCharColor;
	wire [15:0] GPCharHit;
	reg [10:0] GPCharX [15:0];
	reg [9:0] GPCharY [15:0];
	reg [9:0] GPCharScale [15:0];
	reg [5:0] GPCharLetter [15:0];
	/*
		//Char0
	reg [10:0] char0X;		//Object's origin X Coordinate
	reg [9:0] char0Y;			//Object's origin Y Coordinate
	reg [9:0] char0Scale;		//Object's scale factor in powers of 2
	
	reg [5:0] char0Letter;		//0 through 35
		//Char1
	reg [10:0] char1X;		//Object's origin X Coordinate
	reg [9:0] char1Y;			//Object's origin Y Coordinate
	reg [9:0] char1Scale;		//Object's scale factor in powers of 2
	
	reg [5:0] char1Letter;		//0 through 35
		//Char2
	reg [10:0] char2X;		//Object's origin X Coordinate
	reg [9:0] char2Y;			//Object's origin Y Coordinate
	reg [9:0] char2Scale;		//Object's scale factor in powers of 2
	
	reg [5:0] char2Letter;		//0 through 35
		//Char0
	reg [10:0] char3X;		//Object's origin X Coordinate
	reg [9:0] char3Y;			//Object's origin Y Coordinate
	reg [9:0] char3Scale;		//Object's scale factor in powers of 2
	
	reg [5:0] char3Letter;		//0 through 35
		//Char4
	reg [10:0] char4X;		//Object's origin X Coordinate
	reg [9:0] char4Y;			//Object's origin Y Coordinate
	reg [9:0] char4Scale;		//Object's scale factor in powers of 2
	
	reg [5:0] char4Letter;		//0 through 35
		//Char5
	reg [10:0] char5X;		//Object's origin X Coordinate
	reg [9:0] char5Y;			//Object's origin Y Coordinate
	reg [9:0] char5Scale;		//Object's scale factor in powers of 2
	
	reg [5:0] char5Letter;		//0 through 35
		//Char4
	reg [10:0] char6X;		//Object's origin X Coordinate
	reg [9:0] char6Y;			//Object's origin Y Coordinate
	reg [9:0] char6Scale;		//Object's scale factor in powers of 2
	
	reg [5:0] char6Letter;		//0 through 35
		//Char7
	reg [10:0] char7X;		//Object's origin X Coordinate
	reg [9:0] char7Y;			//Object's origin Y Coordinate
	reg [9:0] char7Scale;		//Object's scale factor in powers of 2
	
	reg [5:0] char7Letter;		//0 through 35
		//Char8
	reg [10:0] char8X;		//Object's origin X Coordinate
	reg [9:0] char8Y;			//Object's origin Y Coordinate
	reg [9:0] char8Scale;		//Object's scale factor in powers of 2
	
	reg [5:0] char8Letter;		//0 through 35
		//Char9
	reg [10:0] char9X;		//Object's origin X Coordinate
	reg [9:0] char9Y;			//Object's origin Y Coordinate
	reg [9:0] char9Scale;		//Object's scale factor in powers of 2
	
	reg [5:0] char9Letter;		//0 through 35
		//Char10
	reg [10:0] char10X;		//Object's origin X Coordinate
	reg [9:0] char10Y;			//Object's origin Y Coordinate
	reg [9:0] char10Scale;		//Object's scale factor in powers of 2
	
	reg [5:0] char10Letter;		//0 through 35
		//Char11
	reg [10:0] char11X;		//Object's origin X Coordinate
	reg [9:0] char11Y;			//Object's origin Y Coordinate
	reg [9:0] char11Scale;		//Object's scale factor in powers of 2
	
	reg [5:0] char11Letter;		//0 through 35
		//Char12
	reg [10:0] char12X;		//Object's origin X Coordinate
	reg [9:0] char12Y;			//Object's origin Y Coordinate
	reg [9:0] char12Scale;		//Object's scale factor in powers of 2
	
	reg [5:0] char12Letter;		//0 through 35
		//Char13
	reg [10:0] char13X;		//Object's origin X Coordinate
	reg [9:0] char13Y;			//Object's origin Y Coordinate
	reg [9:0] char13Scale;		//Object's scale factor in powers of 2
	
	reg [5:0] char13Letter;		//0 through 35
		//Char14
	reg [10:0] char14X;		//Object's origin X Coordinate
	reg [9:0] char14Y;			//Object's origin Y Coordinate
	reg [9:0] char14Scale;		//Object's scale factor in powers of 2
	
	reg [5:0] char14Letter;		//0 through 35
		//Char15
	reg [10:0] char15X;		//Object's origin X Coordinate
	reg [9:0] char15Y;			//Object's origin Y Coordinate
	reg [9:0] char15Scale;		//Object's scale factor in powers of 2
	
	reg [5:0] char15Letter;		//0 through 35
	*/
	//-----------
	
	
	
	//////////////////////////////////////////////////////////////////////////////////////////
	
	/*  LOCAL SIGNALS */
	wire	reset, start, ClkPort, board_clk, clk, button_clk, start_btn;
	
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
	
	assign start_btn = btnC;
	
	wire inDisplayArea;
	wire [9:0] CounterX;
	wire [9:0] CounterY;

	hvsync_generator syncgen(.clk(clk), .reset(reset),.vga_h_sync(vga_h_sync), .vga_v_sync(vga_v_sync), .inDisplayArea(inDisplayArea), .CounterX(CounterX), .CounterY(CounterY));
	
	object obj1(
		.clk(clk),
		.reset(reset),
		.ObjectX(ballX),
		.ObjectY(ballY),
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
		.PollX(CounterX),
		.PollY(CounterY),
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
	
	//Left SSD
	digital_ssd LeftSSD(
		.clk(clk),
		.reset(reset),
		.ObjectX(LeftSSDX),		//Object's origin X Coordinate
		.ObjectY(LeftSSDY),		//Object's origin Y Coordinate
		.ObjectScale(LeftSSDScale),		//Object's scale factor in powers of 2
		.Value(P1Score),		//0 through 9
		.PollX(CounterX),			//Position to Poll X Coordinate
		.PollY(CounterY),			//Position to Poll Y Coordinate
		.Hit(LeftSSDHit)
	);
	
	//Right SSD
	digital_ssd RightSSD(
		.clk(clk),
		.reset(reset),
		.ObjectX(RightSSDX),		//Object's origin X Coordinate
		.ObjectY(RightSSDY),		//Object's origin Y Coordinate
		.ObjectScale(RightSSDScale),		//Object's scale factor in powers of 2
		.Value(P2Score),		//0 through 9
		.PollX(CounterX),			//Position to Poll X Coordinate
		.PollY(CounterY),			//Position to Poll Y Coordinate
		.Hit(RightSSDHit)
	);
	
	//Border
	dotted_border Border(
		.clk(clk),
		.reset(reset),
		.ObjectX(BorderX),		//Object's origin X Coordinate
		.ObjectW(BorderW),		//Repeated object's width
		.ObjectH(BorderH),		//Repeated object's height
		.PollX(CounterX),			//Position to Poll X Coordinate
		.PollY(CounterY),			//Position to Poll Y Coordinate
		.Hit(BorderHit)
	);
	
	//Generate General Purpose Characters
	genvar i;
	generate
		for(i=0; i<=15; i=i+1) begin: generate_general_purpose_characters
			digital_ssd GPChar(
				.clk(clk),
				.reset(reset),
				.ObjectX(GPCharX[i]),
				.ObjectY(GPCharY[i]),
				.ObjectScale(GPCharScale[i]),
				.Value(GPCharLetter[i]),
				.PollX(CounterX),
				.PollY(CounterY),
				.Hit(GPCharHit[i])
			);
		end
	endgenerate
	
	/////////////////////////////////////////////////////////////////
	///////////////		Game Logic Starts Here		/////////////////
	/////////////////////////////////////////////////////////////////
	
	reg [3:0] state;
	reg [7:0] iter;
	
	//STATES
	localparam 	
	Q_INIT = 4'd0, Q_SETUP_MENU = 4'd1, Q_MENU = 4'd2, Q_SETUP_GAME = 4'd3, Q_WAIT = 4'd4, Q_UP = 4'd5, Q_UB = 4'd6, Q_UBC = 4'd7, Q_CC = 4'd8, Q_P1S = 4'd9, Q_P2S = 4'd10, Q_UNK = 4'bXXXX;
	//LETTERS
	localparam
	L_A = 6'd10, L_B = 6'd11, L_C = 6'd12, L_D = 6'd13, L_E = 6'd14, L_F = 6'd15, L_G = 6'd16, L_H = 6'd17, L_I = 6'd18, L_J = 6'd19, L_K = 6'd20, L_L = 6'd21,
	L_M = 6'd22, L_N = 6'd23, L_O = 6'd24, L_P = 6'd25, L_Q = 6'd26, L_R = 6'd27, L_S = 6'd28, L_T = 6'd29, L_U = 6'd30, L_V = 6'd31, L_W = 6'd32, L_X = 6'd33,
	L_Y = 6'd34, L_Z = 6'd35, L_space = 6'd36;
	//Update the position of the paddle based off of potentiometer
	always @(posedge DIV_CLK[16])
		begin
		if(reset)
			begin
			state <= Q_INIT;
			end
		case(state)
				Q_INIT:		//Initialize State
					begin
					//Move everything off screen so it wont render
					//SETUP BALL OBJECT
					ballX <= 11'd641;
					ballY <= 10'd481;
					obj1W <= 10'd0;
					obj1H <= 9'd0;
					
					//SETUP PLAYER 2 PADDLE OBJECT
					obj2X <= 11'd641;
					obj2Y <= 10'd481;
					obj2W <= 10'd00;
					obj2H <= 9'd0;
					
					//SETUP PLAYER 1 PADDLE OBJECT
					obj3X <= 11'd641;
					obj3Y <= 10'd481;
					obj3W <= 10'd0;
					obj3H <= 9'd0;
					
					//SETUP SSDs
					LeftSSDX <= 11'd641;
					LeftSSDY <= 10'd481;
					LeftSSDScale <= 4'd0;
					
					RightSSDX <= 11'd641;
					RightSSDY <= 10'd481;
					RightSSDScale <= 4'd0;
					
					//SETUP BORDER
					BorderX <= 11'd641;
					BorderW <= 10'd0;
					BorderH <= 11'd10;
					
					//SETUP GENERAL PURPOSE CHARACTERS
					GPCharColor <= 8'b11111111;		//Make general purpose characters white
					for(iter=1; iter<=15; iter=i+1) begin: setup_GPCharacters
						GPCharX[iter] <= 11'd641;		//Put GP Characters off screen
						GPCharY[iter] <= 10'd481;
						GPCharScale[iter] <= 4'd0;
					end
					
					state <= Q_SETUP_MENU;
					end
				Q_SETUP_MENU:
					begin
					//Create PONG Title Screen
					GPCharLetter[0] <= L_P;
					GPCharX[0] <= 11'd96;
					GPCharY[0] <= 10'd60;
					GPCharScale[0] <= 4'd4;		//16 times bigger
					
					GPCharLetter[1] <= L_O;
					GPCharX[1] <= 11'd224;
					GPCharY[1] <= 10'd60;
					GPCharScale[1] <= 4'd4;		//16 times bigger
					
					GPCharLetter[2] <= L_N;
					GPCharX[2] <= 11'd352;
					GPCharY[2] <= 10'd60;
					GPCharScale[2] <= 4'd4;		//16 times bigger
					
					GPCharLetter[3] <= L_G;
					GPCharX[3] <= 11'd480;
					GPCharY[3] <= 10'd60;
					GPCharScale[3] <= 4'd4;		//16 times bigger
					
					//Create prompt to start game -> PRESS START
					GPCharLetter[4] <= L_P;
					GPCharLetter[5] <= L_R;
					GPCharLetter[6] <= L_E;
					GPCharLetter[7] <= L_S;
					GPCharLetter[8] <= L_S;
					GPCharLetter[9] <= L_space;
					GPCharLetter[10] <= L_S;
					GPCharLetter[11] <= L_T;
					GPCharLetter[12] <= L_A;
					GPCharLetter[13] <= L_R;
					GPCharLetter[14] <= L_T;
					for(iter=4; iter <= 14; iter=iter+1) begin: create_prompt
						GPCharX[iter] <= 11'd96 + ((i-4)*15);
						GPCharY[iter] <= 10'd300;
						GPCharScale[iter] <= 4'd1;		//2 times bigger
					end
					
					state <= Q_MENU;		//Go to Menu state
					end
				Q_MENU:
					begin
					if(start_btn)		//Wait until start button is pressed to start the game
						state <= Q_SETUP_GAME;
					end
				Q_SETUP_GAME:
					begin
					//Setup game objects
					
					//SETUP GENERAL PURPOSE CHARACTERS
					GPCharColor <= 8'b11111111;		//Make general purpose characters white
					for(iter=0; iter<=15; iter=i+1) begin: setup_GPCharacters_game
						GPCharX[iter] <= 11'd641;		//Put GP Characters off screen
						GPCharY[iter] <= 10'd481;
						GPCharScale[iter] <= 4'd0;
					end
					
					//SETUP BALL OBJECT
					obj1W <= 10'd10;
					obj1H <= 9'd10;
					obj1Color <= 8'b11011011;		//Make Object 1 yellow
					
					//SETUP PLAYER 2 PADDLE OBJECT
					obj2X <= 11'd600;
					obj2Y <= 10'd0;
					obj2W <= 10'd10;
					obj2H <= 9'd50;
					obj2Color <= 8'b11011011;		//Make Object 2 yellow
					
					//SETUP PLAYER 1 PADDLE OBJECT
					obj3X <= 11'd40;
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
					ballYCenter <= 10'd240;
					ballRightX <= 11'd325;
					speedMultiplier <= 2'b00;
					
					//SETUP SCORE DISPLAY
					GPCharX[0] <= 11'd255;
					GPCharY[0] <= 10'd10;
					GPCharScale[0] <= 4'd2;
					GPCharLetter[0] <= 6'd0;
					P1Score <= 4'd0;
					
					GPCharX[2] <= 11'd345;
					GPCharY[2] <= 10'd10;
					GPCharScale[2] <= 4'd2;
					GPCharLetter[0] <= 6'd0;
					P2Score <= 4'd0;
					
					//SETUP BORDER
					BorderX <= 11'd319;
					BorderW <= 10'd2;
					BorderH <= 11'd10;
					BorderColor <= 8'b11111111;		//Make Border white
					
					
					state <= Q_WAIT;
					end
				Q_WAIT:
					begin
					state <= Q_UP;
					end
				Q_UP:		//Update Players State
					begin
					//Scale the pots from 7-bit to 9-bit
					scaledPot1 = {1'b0, potentiometer1[7:0], 1'b0};
					scaledPot2 = {1'b0, potentiometer2[7:0], 1'b0};
					
					//Add deadzone to player 1 pot
					if(scaledPot1 < 41)
						player1Pos = 0;
					else
						begin
						scaledPot1 = scaledPot1 - 9'd41;
						if(scaledPot1 > 430)
							player1Pos = 430;
						else
							player1Pos = scaledPot1;
						end
					
					//Add deadzone to player 2 pot
					if(scaledPot2 < 41)
						player2Pos = 0;
					else
						begin
						scaledPot2 = scaledPot2 - 9'd41;
						if(scaledPot2 > 430)
							player2Pos = 430;
						else
							player2Pos = scaledPot2;
						end
					obj3Y <= player1Pos;
					obj2Y <= player2Pos;
					
					obj2Color <= Sw[7:0];
					obj3Color <= Sw[7:0];
					LeftSSDColor <= Sw[7:0];
					RightSSDColor <= Sw[7:0];
					BorderColor <= Sw[7:0];
					
					state <= Q_UP;
					speedMultiplier <= speedMultiplier + 1;
					if(speedMultiplier == 2'b00)
						state <= Q_UB;
					end
				Q_UB:		//Update Ball State
					begin
					if(ballDirX)
						ballX <= ballX + ballXSpeed;
					else
						ballX <= ballX - ballXSpeed;
						
					if(ballDirY)
						ballY <= ballY + ballYSpeed;
					else
						ballY <= ballY - ballYSpeed;
					
					obj1Color <= Sw[7:0];
					
					state <= Q_UBC;
					end
				Q_UBC:		//Update Ball Center State
					begin
					ballYCenter <= ballY + 5;
					ballRightX <= ballX + 10;
					
					state <= Q_CC;
					end
				Q_CC:		//Collision Check State
					begin
					state <= Q_UP;
					//Check if ball hit the bounds of the screen
					if(ballX < ballXSpeed)		//Hit Player 1's goal
						state <= Q_P2S;
					if(ballX >= 11'd630)		//Hit Player 2's goal
						state <= Q_P1S;
					if(ballY < ballYSpeed)		//Hit top of screen
						ballDirY <= 1;
					if(ballY >= 10'd470)		//Hit bottom of screen
						ballDirY <= 0;
						
					//Check if ball hit a player paddle
					if(obj2Collide)
						begin
						ballDirX <= 0;
						ballXSpeed <= ballXSpeed+1;
						ballYSpeed <= ballYSpeed+1;
						end
					if(obj3Collide)
						begin
						ballDirX <= 1;
						ballXSpeed <= ballXSpeed+1;
						ballYSpeed <= ballYSpeed+1;
						end
					end
				Q_P1S:		//Player 1 Scored State
					begin
					//Add to Player 1's score
					P1Score <= P1Score + 1;
					//Reset the ball's position and give player 2 the serve
					ballX <= 11'd315;
					ballY <= 10'd235;
					ballDirX <= 1'b1;
					ballDirY <= 1'b0;
					ballXSpeed <= 4'd1;
					ballYSpeed <= 4'd1;
					ballYCenter <= 10'd240;
					ballRightX <= 11'd325;
					//Return to regular state machine
					state <= Q_WAIT;
					//If player 1 won, reset the game and return to title screen
					if(P1Score == 4'd11)
						state <= Q_INIT;
					end
				Q_P2S:		//Player 2 Scored State
					begin
					//Add to Player 2's score
					P2Score <= P2Score + 1;
					//Reset the ball's position and give player 1 the serve
					ballX <= 11'd315;
					ballY <= 10'd235;
					ballDirX <= 1'b0;
					ballDirY <= 1'b0;
					ballXSpeed <= 4'd1;
					ballYSpeed <= 4'd1;
					ballYCenter <= 10'd240;
					ballRightX <= 11'd325;
					//Return to regular state machine
					state <= Q_WAIT;
					//If player 2 won, reset the game and return to title screen
					if(P2Score == 4'd11)
						state <= Q_INIT;
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
			if(state == Q_MENU)
				begin
				end
			else
				begin
					//Text layer
					if(GPCharHit ~= 16'b0000000000000000)
						begin
						vgaRed <= GPCharColor[7:5];
						vgaGreen <= GPCharColor[4:2];
						vgaBlue <= GPCharColor[1:0];
						end
					if(obj1Hit)		//Ball always drawn over anything else
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
					else if(LeftSSDHit)
						begin
						vgaRed <= LeftSSDColor[7:5];
						vgaGreen <= LeftSSDColor[4:2];
						vgaBlue <= LeftSSDColor[1:0];
						end
					else if(RightSSDHit)
						begin
						vgaRed <= RightSSDColor[7:5];
						vgaGreen <= RightSSDColor[4:2];
						vgaBlue <= RightSSDColor[1:0];
						end
					else if(BorderHit)		//Background border always drawn under everything else
						begin
						vgaRed <= BorderColor[7:5];
						vgaGreen <= BorderColor[4:2];
						vgaBlue <= BorderColor[1:0];
						end
					else
						begin
						vgaRed <= 3'b000;
						vgaGreen <= 3'b000;
						vgaBlue <= 3'b000;
						end
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
	
	assign LD0 = player1Pos[0];
	assign LD1 = player1Pos[1];
	assign LD2 = player1Pos[2];
	assign LD3 = player1Pos[3];
	assign LD4 = player1Pos[4];
	assign LD5 = player1Pos[5];
	assign LD6 = player1Pos[6];
	assign LD7 = player1Pos[7];
	
	/////////////////////////////////////////////////////////////////
	//////////////  	  LD control ends here 	 	////////////////////
	/////////////////////////////////////////////////////////////////
	
	/////////////////////////////////////////////////////////////////
	//////////////  	  SSD control starts here 	 ///////////////////
	/////////////////////////////////////////////////////////////////
	reg 	[3:0]	SSD;
	wire 	[3:0]	SSD0, SSD1, SSD2, SSD3;
	wire 	[1:0] ssdscan_clk;
	
	assign SSD3 = 4'b0000;
	assign SSD2 = P1Score[3:0];
	assign SSD1 = 4'b0000;
	assign SSD0 = P2Score[3:0];
	
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
