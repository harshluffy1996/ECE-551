module balance_cntrl_chk_tb();

reg signed [15:0]ptch, ptch_rt;

reg clk, rt_n, vld, rider_off, en_steer, pwr_up, rst_n;
reg [11:0]steer_pot;

localparam mem_depth = 1500;

wire signed [11:0]lft_spd, rght_spd;
wire too_fast;


reg [48:0]stim[0:mem_depth-1];
reg [24:0]resp[0:mem_depth-1];
logic [7:0]ss_tmr;
logic [10:0] no_received_correct_values;
integer i;





balance_cntrl #(.fast_sim(1)) iDUT(.rst_n(rst_n), .vld(vld), .ptch(ptch), .ptch_rt(ptch_rt), .pwr_up(pwr_up), .rider_off(rider_off), .steer_pot(steer_pot), .en_steer(en_steer), .lft_spd(lft_spd), .rght_spd(rght_spd), .too_fast(too_fast), .clk(clk), .ss_tmr(ss_tmr));




always #5 clk <= ~clk;

initial begin
clk = 0;
no_received_correct_values = 0;

$readmemh("balance_cntrl_stim.hex", stim);
$readmemh("balance_cntrl_resp.hex", resp);

force iDUT.ss_tmr = 8'hFF;

repeat(1) @(posedge clk);

for(i = 0; i < mem_depth; i++) begin
	

steer_pot = stim[i][12:1];
pwr_up = stim[i][14];
rider_off = stim[i][13];
ptch = stim[i][46:31];
vld = stim[i][47];
ptch_rt = stim[i][30:15];
en_steer = stim[i][0];
rst_n = stim[i][48];

@(posedge clk);
#1;
		

if(rght_spd === resp[i][12:1]) $display("%d CORRECT rght_spd ", i);
else $display("%d INCORRECT rght_spd ",i);	


if(lft_spd === resp[i][24:13]) $display("%d CORRECT lft_spd", i);
else $display("%d INCORRECT lft_spd",i);

	
if(too_fast === resp[i][0]) begin
$display("%d CORRECT too_fast", i);
no_received_correct_values = no_received_correct_values + 1;
end
else $display("%d INCORRECT too_fast", i);

end
	
if(no_received_correct_values === mem_depth) $display("All 1500 stimulus vectors matched...!");
else $display("TRY TRY ONLY %d passed.", no_received_correct_values);

$stop();

end

endmodule

