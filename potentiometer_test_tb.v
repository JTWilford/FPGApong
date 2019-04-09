// ----------------------------------------------------------------------
// 	A Verilog module to test the divider described in divider.v
//
// 	Written by Gandhi Puvvada  Date: 7/17/98, 2/15/2008, 10/13/08
//
//      File name: divider_tb.v
// ------------------------------------------------------------------------
//	In this test bench we are using repeated code for test #1, #2, #3.
//	This is not desirable. Refer to divider_tb_str.v for an improved
//	coding style using a task for the repeated code.
// ------------------------------------------------------------------------

`timescale 1 ns / 100 ps

module servo_test_tb ;

reg Clk_tb, Reset_tb;
reg [7:0] sw_tb;
wire PWM_tb;
integer  Clk_cnt;

parameter CLK_PERIOD = 20;


generate_pwm gen(
	.sw(sw_tb),
	.reset(Reset_tb),
	.sys_clk(Clk_tb),
	.PWM(PWM_tb)
	);

initial
  begin  : CLK_GENERATOR
    Clk_tb = 0;
    forever
       begin
	      #(CLK_PERIOD/2) Clk_tb = ~Clk_tb;
       end 
  end

initial
  begin  : RESET_GENERATOR
    Reset_tb = 1;
    #(2 * CLK_PERIOD) Reset_tb = 0;
  end

initial
  begin  : CLK_COUNTER
    Clk_cnt = 0;
    forever
       begin
	      #(CLK_PERIOD) Clk_cnt = Clk_cnt + 1;
       end 
  end

initial
  begin  : STIMULUS
	   sw_tb = 8'b00000000;		// initial values

	wait (!Reset_tb);    // wait until reset is over
	@(posedge Clk_tb);    // wait for a clock

// test #1 begin
	@(posedge Clk_tb);
	#1;  // a little (2ns) after the clock edge
	sw_tb = 8'b00000000;
	@(posedge Clk_tb); // After waiting for a clock
	#1;
	sw_tb = 8'b00000001;
	@(posedge PWM_tb);
	@(posedge PWM_tb);	//Wait for the PWM signal to happen twice
	#5;
	sw_tb = 8'b00000000;
	#10;
	sw_tb = 8'b10000001;
	#15;
	sw_tb = 8'b10000000;
	#20;
	sw_tb = 8'b00000000;
// test #1 end
  end // STIMULUS
  
task APPLY_STIMULUS;
	input [7:0] switch;
	begin
		#1;
		sw_tb = 8'b00000001;
		@(posedge PWM_tb);
		@(posedge PWM_tb);	//Wait for the PWM signal to happen twice
	end
endtask


endmodule  // servo_test_tb