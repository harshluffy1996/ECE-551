module segwayMath_tb();
logic signed [11:0] PID_cntrl;
logic [11:0] steer_pot;
logic [7:0] ss_tmr;
reg en_steer, pwr_up;
wire signed [11:0] lft_spd, rght_spd;
wire too_fast;
reg signed[12:0] rght_shaped, lft_shaped;
logic signed [12:0] lft_torque, rght_torque;
logic signed [11:0] steer_pot_scaled;
 

segwayMath iDUT( .lft_torque(lft_torque), .rght_torque(rght_torque), .steer_pot_scaled(steer_pot_scaled), .rght_shaped(rght_shaped), .lft_shaped(lft_shaped), .PID_cntrl(PID_cntrl), .steer_pot(steer_pot), .ss_tmr(ss_tmr), .en_steer(en_steer), .pwr_up(pwr_up), .lft_spd(lft_spd), .rght_spd(rght_spd), .too_fast(too_fast));

initial begin

 en_steer = 1;
 pwr_up =  1;
end

initial begin
 ss_tmr = 8'hFF;
 PID_cntrl = 12'h3FF;
 repeat(2047) begin
 #5;
 PID_cntrl = PID_cntrl -1;
 end
end

initial begin
 steer_pot = 12'h000;
 repeat(4094) begin
 #5
 steer_pot = steer_pot +1;
 end

 
/*repeat(255) begin
 #5;
 ss_tmr = ss_tmr +1;
 end*/
 
repeat(300) begin
#1
pwr_up=0;
end
end
//$stop();

 


 

endmodule
