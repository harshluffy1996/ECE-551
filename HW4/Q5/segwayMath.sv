module segwayMath(PID_cntrl, ss_tmr, steer_pot, en_steer, pwr_up, lft_spd, rght_spd, too_fast, clk, rst_n);

//primary inputs and outputs
input clk, rst_n;
input signed [11:0] PID_cntrl; 
input [11:0] steer_pot;
input  [7:0] ss_tmr;
input signed en_steer, pwr_up;
output signed [11:0] lft_spd, rght_spd;
output signed too_fast;


//intermediate signals
logic signed [19:0] PID_SS_inter;
logic signed [11:0] steer_pot;
logic signed [11:0] steer_pot_inter;
wire signed  [12:0] steer_control;
logic signed [11:0] PID_ss;
logic signed [12:0] lft_steer_cntrl, rght_steer_cntrl;
logic signed [12:0] PID_ss_new;
logic signed [11:0] steer_control_div;
logic signed [11:0] steer_pot_scaled;
logic signed [12:0] lft_shaped;
logic signed [12:0] rght_shaped;
logic signed [12:0] lft_torque, rght_torque;
logic signed [12:0] lft_torque_high, lft_torque_comp, lft_torque_scaled;
logic signed [12:0] rght_torque_high, rght_torque_comp, rght_torque_scaled;


localparam  Coeff = 12'h7FF;
localparam  MIN_DUTY = 13'h3C0;
localparam  LOW_TORQUE_BAND = 8'h3C;
localparam GAIN_MULT = 6'h10;

assign PID_SS_inter =  $signed({1'b0,ss_tmr})*PID_cntrl; 
assign PID_ss = {PID_SS_inter[19:8]};

assign steer_pot_scaled = (steer_pot >= 12'hE00) ?  12'hE00 : (steer_pot <= 12'h200) ?
       						 12'h200 : steer_pot; 

assign steer_pot_inter = steer_pot_scaled - $signed(Coeff); 
// (3/16) of th steer_pot_inter value 
assign steer_control_div = {{{3{steer_pot_inter[11]}},steer_pot_inter[11:3]}} + {{{4{steer_pot_inter[11]}},
								steer_pot_inter[11:4]}};

//Sign extend the value to make it 13 bit
assign steer_control = {steer_control_div[11], steer_control_div}; 
assign PID_ss_new = {1{PID_ss[11], PID_ss}};				
assign lft_steer_cntrl = PID_ss_new + steer_control;
assign rght_steer_cntrl = PID_ss_new - steer_control;

//Both the torques depend on enabled steer
assign lft_torque = (en_steer) ? lft_steer_cntrl : PID_ss_new;
assign rght_torque = (en_steer) ? rght_steer_cntrl : PID_ss_new;


//LEFT
//Comparing pos and neg left torque
assign lft_torque_comp = (lft_torque[12]) ? (lft_torque - MIN_DUTY) : (lft_torque + MIN_DUTY);
assign lft_torque_high = lft_torque*$signed(GAIN_MULT);
assign lft_torque_abs = (lft_torque[12]) ? (~(lft_torque) +1) : lft_torque;
assign lft_torque_scaled = (lft_torque_abs > LOW_TORQUE_BAND) ? lft_torque_comp : lft_torque_high;
assign lft_shaped = (pwr_up) ? lft_torque_scaled : 13'h0000;
//left speed
assign lft_spd =   (~lft_shaped[12] && |lft_shaped[11]) ? 12'h7FF :
		   		   (lft_shaped[12] && ~&lft_shaped[11]) ? 12'h800 :
		            lft_shaped[11:0];  
//Right
//Comparing pos and neg right torque
assign rght_torque_comp = (rght_torque[12]) ? (rght_torque - MIN_DUTY) : (rght_torque + MIN_DUTY); 

// Right Shaped torque
assign rght_torque_high = rght_torque*$signed(GAIN_MULT);		
assign rght_torque_abs = (rght_torque[12]) ? (~(rght_torque) +1) : rght_torque;
assign rght_torque_scaled = (rght_torque_abs > LOW_TORQUE_BAND) ? rght_torque_comp : rght_torque_high;
assign rght_shaped = pwr_up ? rght_torque_scaled : 13'h0000;
//right speed
assign rght_spd =   (~rght_shaped[12] && |rght_shaped[11]) ? 12'h7FF :
		            (rght_shaped[12] && ~&rght_shaped[11]) ? 12'h800 :
		     		rght_shaped[11:0];

//To showcase too fast warning for rider
assign too_fast = (lft_spd > $signed(12'd1792) || rght_spd > $signed(12'd1792)) ? 1'b1 : 1'b0; 

endmodule