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
	// Number Display
	reg [10:0] LeftSSDX;		//Object's origin X Coordinate
	reg [9:0] LeftSSDY;			//Object's origin Y Coordinate
	reg [3:0] LeftSSDScale;		//Object's scale factor in powers of 2
	
	reg [3:0] LeftSSDValue;		//0 through 9
	
	wire LeftSSDHit;
	
	reg [10:0] RightSSDX;		//Object's origin X Coordinate
	reg [9:0] RightSSDY;			//Object's origin Y Coordinate
	reg [9:0] RightSSDScale;		//Object's scale factor in powers of 2
	
	reg [3:0] RightSSDValue;		//0 through 9
	
	wire RightSSDHit;
	
	reg [7:0] LeftSSDColor;
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
	
	//Left SSD
	digital_ssd LeftSSD(
		.clk(clk),
		.reset(reset),
		.ObjectX(LeftSSDX),		//Object's origin X Coordinate
		.ObjectY(LeftSSDY),		//Object's origin Y Coordinate
		.ObjectScale(LeftSSDScale),		//Object's scale factor in powers of 2
		.Value(LeftSSDValue),		//0 through 9
		.PollX(CounterX),			//Position to Poll X Coordinate
		.PollY(CounterY),			//Position to Poll Y Coordinate
		.Hit(LeftSSDHit)
	);
	
	/////////////////////////////////////////////////////////////////
	///////////////		Game Logic Starts Here		/////////////////
	/////////////////////////////////////////////////////////////////
	
	//Update the position of the paddle based off of potentiometer
	always @(posedge DIV_CLK[18])
		begin
		if(reset)
			begin
			//SETUP SSDs
				LeftSSDX <= 11'd255;
				LeftSSDY <= 10'd220;
				LeftSSDColor <= 8'b11111111;	//Make Left SSD white
			end
		end
	
	/////////////////////////////////////////////////////////////////
	///////////////		VGA control starts here		/////////////////
	/////////////////////////////////////////////////////////////////
	
	//Rendering Block
	always @(posedge clk)
	begin
		if(inDisplayArea)
			begin
				vgaRed <= 3'b000;
				vgaGreen <= 3'b000;
				vgaBlue <= 3'b000;
				if(LeftSSDHit)
					begin
					vgaRed <= LeftSSDColor[7:5];
					vgaGreen <= LeftSSDColor[4:2];
					vgaBlue <= LeftSSDColor[1:0];
					end
			end
		else
			begin
			vgaRed <= 3'b000;
			vgaGreen <= 3'b000;
			vgaBlue <= 3'b000;
			end
	end
	
	assign LeftSSDValue = {Sw[3:0]};
	assign LeftSSDScale = {Sw[7:4]};
	
	/////////////////////////////////////////////////////////////////
	//////////////  	  VGA control ends here 	 ///////////////////
	/////////////////////////////////////////////////////////////////
	
	/////////////////////////////////////////////////////////////////
	//////////////  	  LD control starts here 	 ///////////////////
	/////////////////////////////////////////////////////////////////
	wire LD0, LD1, LD2, LD3, LD4, LD5, LD6, LD7;
	
	/////////////////////////////////////////////////////////////////
	//////////////  	  LD control ends here 	 	////////////////////
	/////////////////////////////////////////////////////////////////
	
	/////////////////////////////////////////////////////////////////
	//////////////  	  SSD control starts here 	 ///////////////////
	/////////////////////////////////////////////////////////////////
	reg 	[3:0]	SSD;
	wire 	[3:0]	SSD0, SSD1, SSD2, SSD3;
	wire 	[1:0] ssdscan_clk;
	
	assign SSD3 = {2'b00, LeftSSDY[9:8]};
	assign SSD2 = LeftSSDY[7:4];
	assign SSD1 = LeftSSDY[3:0];
	assign SSD0 = LeftSSDValue[3:0];
	
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
