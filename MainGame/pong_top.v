`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author:			Justin Wilford
// Create Date:		04/17/2019 
// File Name:		display_gandhi.v
// Description: 
//		Displays a 100px by 100px monochromatic image of Professor Gandhi Puvvada.
//
// Revision: 		1.1
// Additional Comments:  Was originally 200px by 200px, but ISE ran out of memory while synthesizing.
//
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
	reg [1:0] hitCounter;
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
	// General Purpose Characters (32 total)
		//All character's colors and hit markers
	reg [7:0] GPCharColor;
	wire [31:0] GPCharHit;
	reg [10:0] GPCharX [31:0];
	reg [9:0] GPCharY [31:0];
	reg [9:0] GPCharScale [31:0];
	reg [5:0] GPCharLetter [31:0];
	//-----------
	// Gandhi image
	reg [10:0] GandhiX;
	reg [9:0] GandhiY;
	reg [7:0] GandhiColor1;
	reg [7:0] GandhiColor2;
	wire GandhiHit;
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
	
	//Generate General Purpose Characters -> Generates 32
	genvar i;
	generate
		for(i=0; i<=31; i=i+1) begin: generate_general_purpose_characters
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
	
	//Gandhi Image
	display_gandhi Gandhi(
		.clk(clk),
		.reset(reset),
		.ObjectX(GandhiX),
		.ObjectY(GandhiY),
		.PollX(CounterX),
		.PollY(CounterY),
		.Hit(GandhiHit),
		.Hit2(GandhiHit2)
	);
	
	/////////////////////////////////////////////////////////////////
	///////////////		Game Logic Starts Here		/////////////////
	/////////////////////////////////////////////////////////////////
	
	reg [3:0] state;
	reg [7:0] iter;
	reg [10:0] xtemp;
	reg [11:0] countdown;
	
	//STATES
	localparam 	
	Q_INIT = 4'd0, Q_SETUP_MENU = 4'd1, Q_MENU = 4'd2, Q_SETUP_GAME = 4'd3, Q_WAIT = 4'd4, Q_UP = 4'd5,
	Q_UB = 4'd6, Q_UBC = 4'd7, Q_CC = 4'd8, Q_P1S = 4'd9, Q_P2S = 4'd10, Q_P1WIN = 4'd11, Q_P2WIN = 4'd12,
	Q_UNK = 4'bXXXX;
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
					for(iter=0; iter<=15; iter=iter+1) begin: setup_GPCharacters
						GPCharX[iter] <= 11'd641;		//Put GP Characters off screen
						GPCharY[iter] <= 10'd481;
						GPCharScale[iter] <= 4'd0;
					end
					
					//SETUP GANDHI
					GandhiX <= 11'd641;
					GandhiY <= 10'd481;
					GandhiColor1 <= 8'b00000011;
					GandhiColor2 <= 8'b00100001;
					
					state <= Q_SETUP_MENU;
					end
				Q_SETUP_MENU:
					begin
					//Create PONG Title Screen
					GPCharColor <= 8'b11111111;
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
					
					//PLACE GANDHI
					GandhiX <= 11'd220;
					GandhiY <= 10'd200;
					GandhiColor1 <= 8'b00000011;
					GandhiColor2 <= 8'b00100001;
					
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
					for(iter=4, xtemp=11'd96; iter <= 14; iter=iter+1, xtemp=xtemp+11'd15) begin: create_prompt
						GPCharX[iter] <= xtemp;
						GPCharY[iter] <= 10'd300;
						GPCharScale[iter] <= 4'd1;		//2 times bigger
					end
					
					state <= Q_MENU;		//Go to Menu state
					end
				Q_MENU:
					begin
					if(start_btn)		//Wait until start button is pressed to start the game
						state <= Q_SETUP_GAME;
					GPCharColor <= Sw[7:0];
					end
				Q_SETUP_GAME:
					begin
					//Setup game objects
					
					//SETUP GENERAL PURPOSE CHARACTERS
					GPCharColor <= 8'b11111111;		//Make general purpose characters white
					for(iter=0; iter<=15; iter=iter+1) begin: setup_GPCharacters_game
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
					hitCounter <= 2'b00;
					
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
					
					//REMOVE GANDHI
					GandhiX <= 11'd641;
					GandhiY <= 10'd481;
					GandhiColor1 <= 8'b00000011;
					GandhiColor2 <= 8'b00100001;
					
					//RESET WAIT TIMER
					countdown <= 12'd0;
					
					state <= Q_WAIT;
					end
				Q_WAIT:
					begin
					countdown <= countdown + 12'd1;
					if(countdown == 12'd1599)		//Clock runs at 800Hz in this section -> 2 second wait
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
					GPCharColor <= Sw[7:0];
					
					GPCharLetter[0] <= P1Score;
					GPCharLetter[2] <= P2Score;
					
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
						hitCounter <= hitCounter+1;
						if(hitCounter == 2'b11)
							begin
							ballXSpeed <= ballXSpeed+1;
							ballYSpeed <= ballYSpeed+1;
							end
						end
					if(obj3Collide)
						begin
						ballDirX <= 1;
						hitCounter <= hitCounter+1;
						if(hitCounter == 2'b11)
							begin
							ballXSpeed <= ballXSpeed+1;
							ballYSpeed <= ballYSpeed+1;
							end
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
					speedMultiplier <= 2'b00;
					hitCounter <= 2'b00;
					//Return to regular state machine
					state <= Q_WAIT;
					//If player 1 won, reset the game and return to title screen
					if(P1Score == 4'd11)
						state <= Q_P1WIN;
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
					speedMultiplier <= 2'b00;
					hitCounter <= 2'b00;
					//Return to regular state machine
					state <= Q_WAIT;
					//If player 2 won, reset the game and return to title screen
					if(P2Score == 4'd11)
						state <= Q_P2WIN;
					end
				Q_P1WIN:		//Player 1 Won
					begin
					//Set the win text
					//PLACE GANDHI
					GandhiX <= 11'd120;
					GandhiY <= 10'd190;
					GandhiColor1 <= 8'b11100000;
					GandhiColor2 <= 8'b00100000;
					//Set GPCharacter colors
					GPCharColor <= 8'b11111101;
					//Congratulate the player -> PLAYER 1 WINS
					GPCharLetter[4] 	<= L_P;
					GPCharLetter[5] 	<= L_L;
					GPCharLetter[6] 	<= L_A;
					GPCharLetter[7] 	<= L_Y;
					GPCharLetter[8] 	<= L_E;
					GPCharLetter[9] 	<= L_R;
					GPCharLetter[10] 	<= L_space;
					GPCharLetter[11] 	<= 6'd1;
					GPCharLetter[12] 	<= L_space;
					GPCharLetter[13] 	<= L_W;
					GPCharLetter[14] 	<= L_I;
					GPCharLetter[15] 	<= L_N;
					GPCharLetter[16] 	<= L_S;
					for(iter=4, xtemp=11'd300; iter <= 16; iter=iter+1, xtemp=xtemp+11'd15) begin: place_p1_win
						GPCharX[iter] <= xtemp;
						GPCharY[iter] <= 10'd220;
						GPCharScale[iter] <= 4'd1;		//2 times bigger
					end
					//Congratulate the player -> GOOD JOB
					GPCharLetter[17] 	<= L_G;
					GPCharLetter[18] 	<= L_O;
					GPCharLetter[19] 	<= L_O;
					GPCharLetter[20] 	<= L_D;
					GPCharLetter[21] 	<= L_space;
					GPCharLetter[22] 	<= L_J;
					GPCharLetter[23] 	<= L_O;
					GPCharLetter[24] 	<= L_B;
					for(iter=17, xtemp=11'd337; iter <= 24; iter=iter+1, xtemp=xtemp+11'd15) begin: place_p1_good
						GPCharX[iter] <= xtemp;
						GPCharY[iter] <= 10'd242;
						GPCharScale[iter] <= 4'd1;		//2 times bigger
					end
					
					countdown <= 12'd0;
					state <= Q_END_WAIT;
					end
				Q_P1WIN:		//Player 2 Won
					begin
					//Set the win text
					//PLACE GANDHI
					GandhiX <= 11'd120;
					GandhiY <= 10'd190;
					GandhiColor1 <= 8'b11100000;
					GandhiColor2 <= 8'b00100000;
					//Set GPCharacter colors
					GPCharColor <= 8'b11111101;
					//Congratulate the player -> PLAYER 1 WINS
					GPCharLetter[4] 	<= L_P;
					GPCharLetter[5] 	<= L_L;
					GPCharLetter[6] 	<= L_A;
					GPCharLetter[7] 	<= L_Y;
					GPCharLetter[8] 	<= L_E;
					GPCharLetter[9] 	<= L_R;
					GPCharLetter[10] 	<= L_space;
					GPCharLetter[11] 	<= 6'd2;
					GPCharLetter[12] 	<= L_space;
					GPCharLetter[13] 	<= L_W;
					GPCharLetter[14] 	<= L_I;
					GPCharLetter[15] 	<= L_N;
					GPCharLetter[16] 	<= L_S;
					for(iter=4, xtemp=11'd300; iter <= 16; iter=iter+1, xtemp=xtemp+11'd15) begin: place_p2_win
						GPCharX[iter] <= xtemp;
						GPCharY[iter] <= 10'd220;
						GPCharScale[iter] <= 4'd1;		//2 times bigger
					end
					//Congratulate the player -> GOOD JOB
					GPCharLetter[17] 	<= L_G;
					GPCharLetter[18] 	<= L_O;
					GPCharLetter[19] 	<= L_O;
					GPCharLetter[20] 	<= L_D;
					GPCharLetter[21] 	<= L_space;
					GPCharLetter[22] 	<= L_J;
					GPCharLetter[23] 	<= L_O;
					GPCharLetter[24] 	<= L_B;
					for(iter=17, xtemp=11'd337; iter <= 24; iter=iter+1, xtemp=xtemp+11'd15) begin: place_p2_good
						GPCharX[iter] <= xtemp;
						GPCharY[iter] <= 10'd242;
						GPCharScale[iter] <= 4'd1;		//2 times bigger
					end
					
					countdown <= 12'd0;
					state <= Q_END_WAIT;
					end
				Q_END_WAIT:
					begin
					countdown <= countdown + 12'd1;
					if(countdown == 12'd3999)		//Clock runs at 800Hz in this section -> 5 second wait
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
				//Text layer
				if(GPCharHit != 32'b00000000000000000000000000000000)
					begin
					vgaRed <= GPCharColor[7:5];
					vgaGreen <= GPCharColor[4:2];
					vgaBlue <= GPCharColor[1:0];
					end
				else if(obj1Hit)		//Ball always drawn over anything else
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
				else if(GandhiHit)
					begin
					vgaRed <= GandhiColor1[7:5];
					vgaGreen <= GandhiColor1[4:2];
					vgaBlue <= GandhiColor1[1:0];
					end
				else if(GandhiHit2)
					begin
					vgaRed <= GandhiColor2[7:5];
					vgaGreen <= GandhiColor2[4:2];
					vgaBlue <= GandhiColor2[1:0];
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
	
	assign LD0 = GPCharHit[0];
	assign LD1 = GPCharHit[1];
	assign LD2 = GPCharHit[2];
	assign LD3 = GPCharHit[3];
	assign LD4 = GPCharHit[4];
	assign LD5 = GPCharHit[5];
	assign LD6 = GPCharHit[6];
	assign LD7 = GPCharHit[7];
	
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
