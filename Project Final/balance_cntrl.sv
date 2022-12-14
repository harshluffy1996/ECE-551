//Instantiation of PID and SegwayMath.
module balance_cntrl(clk, rst_n, vld, ptch, ptch_rt, pwr_up, rider_off, steer_pot, en_steer, lft_spd, rght_spd, too_fast);

input clk, rst_n, vld, rider_off;
input en_steer;
input [15:0] ptch, ptch_rt;
input [11:0] steer_pot;

input pwr_up; 
output reg too_fast;
output  [11:0] lft_spd, rght_spd;

logic [11:0] PID_cntrl, PID_cntrl_pp;
logic  [7:0]  ss_tmr;
logic [15:0] ptch_pp;

    parameter fast_sim =1;


	PID iDUT1(.clk(clk), .rst_n(rst_n), .ptch(ptch), .ptch_rt(ptch_rt), .pwr_up(pwr_up), 
			  .vld(vld), .rider_off(rider_off), .PID_cntrl(PID_cntrl_pp), .ss_tmr(ss_tmr));



	SegwayMath iDUT2(.PID_cntrl(PID_cntrl), .ss_tmr(ss_tmr), .steer_pot(steer_pot), 
					 .en_steer(en_steer), .pwr_up(pwr_up), .lft_spd(lft_spd), 
					 .rght_spd(rght_spd), .too_fast(too_fast), .clk(clk), .rst_n(rst_n));



//Adding extra flops for pipelining purposes
	always_ff @(posedge clk or negedge rst_n)
		if (!rst_n)
			PID_cntrl <= 16'h0000;
		else
			PID_cntrl <= PID_cntrl_pp;
	

endmodule
