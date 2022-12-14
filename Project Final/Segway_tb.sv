
module Segway_tb();
			
//// Interconnects to DUT/support defined as type wire /////
wire SS_n,SCLK,MOSI,MISO,INT;				// to inertial sensor
wire A2D_SS_n,A2D_SCLK,A2D_MOSI,A2D_MISO;	// to A2D converter
wire RX_TX;
wire PWM1_rght, PWM2_rght, PWM1_lft, PWM2_lft;
wire piezo,piezo_n;
wire cmd_sent;
wire rst_n;					// synchronized global reset

////// Stimulus is declared as type reg ///////
reg clk, RST_n;
reg [7:0] cmd;				// command host is sending to DUT
reg send_cmd;				// asserted to initiate sending of command
reg signed [15:0] rider_lean;
reg [11:0] ld_cell_lft, ld_cell_rght,steerPot,batt;	// A2D values
reg OVR_I_lft, OVR_I_rght;

///// Internal registers for testing purposes??? /////////
//logic turn_left, turn_rght;
logic cmd_sent_test;


////////////////////////////////////////////////////////////////
// Instantiate Physical Model of Segway with Inertial sensor //
//////////////////////////////////////////////////////////////	
SegwayModel iPHYS(.clk(clk),.RST_n(RST_n),.SS_n(SS_n),.SCLK(SCLK),
                  .MISO(MISO),.MOSI(MOSI),.INT(INT),.PWM1_lft(PWM1_lft),
				  .PWM2_lft(PWM2_lft),.PWM1_rght(PWM1_rght),
				  .PWM2_rght(PWM2_rght),.rider_lean(rider_lean));				  

/////////////////////////////////////////////////////////
// Instantiate Model of A2D for load cell and battery //
///////////////////////////////////////////////////////
ADC128S_FC iA2D(.clk(clk),.rst_n(RST_n),.SS_n(A2D_SS_n),.SCLK(A2D_SCLK),
             .MISO(A2D_MISO),.MOSI(A2D_MOSI),.ld_cell_lft(ld_cell_lft),.ld_cell_rght(ld_cell_rght),
			 .steerPot(steerPot),.batt(batt));			
	 
////// Instantiate DUT ////////
Segway /*#(.fast_sim(1'b1))*/iDUT(.clk(clk),.RST_n(RST_n),.INERT_SS_n(SS_n),.INERT_MOSI(MOSI),
            .INERT_SCLK(SCLK),.INERT_MISO(MISO),.INERT_INT(INT),.A2D_SS_n(A2D_SS_n),
			.A2D_MOSI(A2D_MOSI),.A2D_SCLK(A2D_SCLK),.A2D_MISO(A2D_MISO),
			.PWM1_lft(PWM1_lft),.PWM2_lft(PWM2_lft),.PWM1_rght(PWM1_rght),
			.PWM2_rght(PWM2_rght),.OVR_I_lft(OVR_I_lft),.OVR_I_rght(OVR_I_rght),
			.piezo_n(piezo_n),.piezo(piezo),.RX(RX_TX));

//// Instantiate UART_tx (mimics command from BLE module) //////
UART_tx iTX(.clk(clk),.rst_n(rst_n),.TX(RX_TX),.trmt(send_cmd),.tx_data(cmd),.tx_done(cmd_sent));

/////////////////////////////////////
// Instantiate reset synchronizer //
///////////////////////////////////
rst_synch iRST(.clk(clk),.RST_n(RST_n),.rst_n(rst_n));


	assign cmd_sent_test =  cmd_sent;

	typedef enum {RIDER_PRESENT, RIDER_LEAN, RIDER_STEPPING_DOWN, STOP_COMMAND_TESTS, OVER_CURRENT_TESTING} test_t;
	test_t test;

	

	initial begin
	  
	  /// Your magic goes here ///
	  

          //Test 1 : RIDER_PRESENT : Test to check the functionality of pwr_up signal with above min_rider_weight and before and after asserting go command.
	  test = RIDER_PRESENT;
	  // Initialize values and Reset
	  InitializeSegway(.clk(clk), .RST_n(RST_n), .send_cmd(send_cmd), .OVR_I_lft(OVR_I_lft), .OVR_I_rght(OVR_I_rght), 
			   .cmd(cmd), .rider_lean(rider_lean), .ld_cell_lft(ld_cell_lft), .ld_cell_rght(ld_cell_rght), 
			   .steerPot(steerPot), .batt(batt));
	  
	  ld_cell_lft = 12'h200;
	  ld_cell_rght = 12'h200;
	  batt = 12'hFFF;
	  repeat(800000) @(posedge clk);

	  CheckAndCompare("pwr_up", "RIDER_PRESENT", iDUT.pwr_up, 0 );

	  SendCmd(.clk(clk), .send_cmd(send_cmd), .cmd(cmd), .data(g), .cmd_sent(cmd_sent_test));

	  repeat(1600000) @(posedge clk);
	  $display("TESTING....1");
	  CheckAndCompare("pwr_up", "RIDER_PRESENT", iDUT.pwr_up, 1 );
	  
	  


          //TEST 2 : RIDER_LEAN : Checking if the theta_platform signal converges to zero after providing values to rider_lean. Essentially checking if the segway balances after the rider steps on 
          //and leans forward.
	  test = RIDER_LEAN;
	  $display("TESTING....2");
	  InitializeSegway(.clk(clk), .RST_n(RST_n), .send_cmd(send_cmd), .OVR_I_lft(OVR_I_lft), .OVR_I_rght(OVR_I_rght), 
					   .cmd(cmd), .rider_lean(rider_lean), .ld_cell_lft(ld_cell_lft), .ld_cell_rght(ld_cell_rght), 
					   .steerPot(steerPot), .batt(batt));
	  ld_cell_lft = 12'h200;
	  ld_cell_rght = 12'h200;

	  repeat(100) @(posedge clk);

	  SendCmd(.clk(clk), .send_cmd(send_cmd), .cmd(cmd), .data(g), .cmd_sent(cmd_sent_test));

	  repeat(800000) @(posedge clk);
	  rider_lean = 16'h0FFF;

	  repeat(1600000) @(posedge clk);
	  rider_lean = 16'h0000;

	  repeat(800000) @(posedge clk);

	  
	  
	  //TEST 3 : RIDER_STEPPING_DOWN : Checking the functionality of the en_steer signal after the rider steps off. Ideally the en_steer should be deasserted.
	   
           test = RIDER_STEPPING_DOWN;
	   InitializeSegway(.clk(clk), .RST_n(RST_n), .send_cmd(send_cmd), .OVR_I_lft(OVR_I_lft), .OVR_I_rght(OVR_I_rght), 
					   .cmd(cmd), .rider_lean(rider_lean), .ld_cell_lft(ld_cell_lft), .ld_cell_rght(ld_cell_rght), 
					   .steerPot(steerPot), .batt(batt));
	   ld_cell_lft = 12'h200;
	   ld_cell_rght = 12'h200;
	   batt = 12'hFFF;
	    
	   repeat(800000) @(posedge clk);
	   SendCmd(.clk(clk), .send_cmd(send_cmd), .cmd(cmd), .data(g), .cmd_sent(cmd_sent_test));
	    
	   repeat(800000) @(posedge clk);
	   rider_lean = 16'h0FFF;
	    
	   repeat(2000000) @(posedge clk);
	   CheckAndCompare("pwr_up", "RIDER_STEPPING_DOWN", iDUT.pwr_up, 1);
	    
	   repeat(2000000) @(posedge clk);
	   CheckAndCompare("en_steer", "RIDER_STEPPING_DOWN", iDUT.iBAL.en_steer, 1);
	    
	   repeat(2000000) @(posedge clk);
	   ld_cell_lft = 12'h200;
	   ld_cell_rght = 12'h000;
	   $display("TESTING....3");
	   repeat(2000000) @(posedge clk);
	   CheckAndCompare("en_steer", "RIDER_STEPPING_DOWN", iDUT.iBAL.en_steer, 0); 
	  
	  


          //TEST 4 : STOP_COMMAND_TESTS: Test about checking pwr_up and en_steer functionality upon the reception of STOP command and providing values less than min_rider_weight and more than min_rider_weight.
	  test =  STOP_COMMAND_TESTS;
	  InitializeSegway(.clk(clk), .RST_n(RST_n), .send_cmd(send_cmd), .OVR_I_lft(OVR_I_lft), .OVR_I_rght(OVR_I_rght), 
					   .cmd(cmd), .rider_lean(rider_lean), .ld_cell_lft(ld_cell_lft), .ld_cell_rght(ld_cell_rght), 
					   .steerPot(steerPot), .batt(batt));
	  ld_cell_lft = 12'h200;
	  ld_cell_rght = 12'h200;
	  batt = 12'hFFF;
	  repeat(600000) @(posedge clk);

	  SendCmd(.clk(clk), .send_cmd(send_cmd), .cmd(cmd), .data(s), .cmd_sent(cmd_sent_test));

	  repeat(1400000) @(posedge clk);
	  CheckAndCompare("pwr_up", "STOP_COMMAND_TESTS", iDUT.pwr_up, 1);
	  repeat(1400000) @(posedge clk);
	  ld_cell_lft = 0;
	  ld_cell_rght = 0;

	  repeat(2000000) @(posedge clk);
	  $display("TESTING....4");
	  CheckAndCompare("en_steer", "STOP_COMMAND_TESTS", iDUT.iBAL.en_steer, 0);
	  repeat(600000) @(posedge clk);
	  SendCmd(.clk(clk), .send_cmd(send_cmd), .cmd(cmd), .data(s), .cmd_sent(cmd_sent_test));
	  repeat(2000000) @(posedge clk);
	  
	  CheckAndCompare("pwr_up", "STOP_COMMAND_TESTS", iDUT.pwr_up, 0);
	  
	  


          //TEST 5 : OVER_CURRENT_TESTING : 
          test = OVER_CURRENT_TESTING;
	  InitializeSegway(.clk(clk), .RST_n(RST_n), .send_cmd(send_cmd), .OVR_I_lft(OVR_I_lft), .OVR_I_rght(OVR_I_rght), 
					   .cmd(cmd), .rider_lean(rider_lean), .ld_cell_lft(ld_cell_lft), .ld_cell_rght(ld_cell_rght), 
					   .steerPot(steerPot), .batt(batt));
          $display("TESTING....5");
	  
          repeat(165)@(posedge iDUT.iDRV.PWM_synch) 
          begin
          
          repeat(2) @(posedge clk) begin 
          end
          @(negedge clk)
          OVR_I_lft = 1;
          
          repeat(20) @(negedge clk) begin end
          OVR_I_lft = 0;
          end
          
          @(posedge clk)
          CheckAndCompare("OVR_I_shtdwn", "OVER_CURRENT_TESTING", iDUT.iDRV.OVR_I_shtdwn, 0);
          
          repeat(136) begin
          @(posedge iDUT.iDRV.PWM_synch) begin
          
          repeat(256)@(posedge clk) begin 
          end
          
          repeat (2) @(posedge clk) begin 
          end
          @(negedge clk)
          OVR_I_lft = 1;
          
          repeat(20) @(negedge clk) begin 
          end
          OVR_I_lft = 0;
          end
          end
          @(posedge clk)
          CheckAndCompare("OVR_I_shtdwn", "OVER_CURRENT_TESTING", iDUT.iDRV.OVR_I_shtdwn, 1);

	   
	  
	   
	  
	  
	  
	  
	  $display("All Tests are Passed.....!!");
	  $stop();
	end

always
  #10 clk = ~clk;

  `include "tb_tasks.sv"
endmodule	
