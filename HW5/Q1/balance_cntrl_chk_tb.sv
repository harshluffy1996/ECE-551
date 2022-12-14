`timescale 1ns/1ps
module balance_cntrl_chk_tb();

reg signed [15:0]ptch, ptch_rt;

localparam mem_loc = 1500;
reg clk, vld, rider_off, pwr_up, rst_n;
reg signed en_steer;
reg [11:0]steer_pot;
reg [48:0]stim[0:mem_loc-1];
reg [24:0]resp[0:mem_loc-1];
logic [7:0]ss_tmr;
integer k;

localparam P_COEFF = 5'h0C;
logic signed [11:0]lft_spd, rght_spd;
logic too_fast;
logic [10:0] correct_values_count;



balance_cntrl iDUT(.rst_n(rst_n), .vld(vld), .ptch(ptch), .ptch_rt(ptch_rt), .pwr_up(pwr_up), .rider_off(rider_off), .steer_pot(steer_pot), .en_steer(en_steer), .lft_spd(lft_spd), .rght_spd(rght_spd), .too_fast(too_fast), .clk(clk), .ss_tmr(ss_tmr));

always #5 clk <= ~clk;

initial begin
clk = 0;
rst_n = 0;
correct_values_count = 0;

$readmemh("balance_cntrl_stim.hex", stim);
$readmemh("balance_cntrl_resp.hex", resp);

@(posedge clk);
@(negedge clk);
rst_n = 1;

repeat(1) @(posedge clk);

for(k = 0; k < mem_loc; k++) begin

	//asiisging vakuves to the respective signals
	steer_pot = stim[k][12:1];
	pwr_up = stim[k][14];
	rider_off = stim[k][13];
	ptch = stim[k][46:31];
	vld = stim[k][47];
	ptch_rt = stim[k][30:15];
	en_steer = stim[k][0];
	rst_n = stim[k][48];

	@(posedge clk);
	#1;
		if((rght_spd === resp[k][12:1]) && (lft_spd === resp[k][24:13]) && (too_fast === resp[k][0]))begin
					correct_values_count = correct_values_count + 1;
		end
	end
	
	if(correct_values_count === mem_loc) 
		$display(" YAHOO!! All test passed!");
	else 
		$display("Try Again %d passed.", correct_values_count);

$stop();

end

endmodule

