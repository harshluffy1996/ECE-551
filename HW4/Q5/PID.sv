module PID(ptch, ptch_rt,rider_off, pwr_up,vld, PID_cntrl, clk, rst_n, ss_tmr);

input clk, rst_n;
input signed [15:0] ptch, ptch_rt;
input rider_off, pwr_up, vld;
output signed [11:0] PID_cntrl;
output reg [7:0] ss_tmr;

reg [17:0] integrator;
logic signed [9:0]  ptch_err_sat;
logic signed [14:0] P_term;
logic signed [14:0] I_term;
logic signed [12:0] D_term;
logic signed [15:0]  PID_inter;
logic signed [17:0] ptch_err_sat_signExt, ptch_err_sat_SEA;
logic [8:0] tmr_inc;
reg vld_ov, not_ovf;
logic signed [26:0] pre_ss_tmr, tmr, post_ss_tmr;



localparam P_COEFF = 5'h0C;
assign P_term = ptch_err_sat*$signed(P_COEFF);
//dividing pitch error to get D-Term
assign D_term = ~{{3{ptch_rt[15]}},ptch_rt[15:6]};

assign PID_inter = {{{1{P_term[14]}}, P_term} + {{1{I_term[14]}}, I_term} + {{3{D_term[12]}}, D_term}};
assign PID_cntrl = (~PID_inter[15] && |PID_inter[14:11]) ? 12'h7FF :
		    	   (PID_inter[15] && ~&PID_inter[14:11]) ? 12'h800 :					
			       PID_inter[11:0];

//Integrator Speed up
parameter fast_sim =1;
generate if(fast_sim) begin
assign tmr_inc = 9'h100;

assign I_term = (~integrator[17] && |integrator[16:14]) ? 15'h3FFF :
		        (integrator[17] && ~&integrator[16:14]) ? 15'h8000 :
	 	        integrator[15:1];
end else begin
assign tmr_inc = 9'h001;
assign I_term = {{3{integrator[17]}},integrator[17:6]};
end
endgenerate

//saturating pitch error to 10 bits
assign ptch_err_sat =   (~ptch[15] && |ptch[14:9]) ? 10'h1FF :
						(ptch[15] && ~&ptch[14:9]) ? 10'h200 :
						 ptch[9:0];		

//integrator
assign ptch_err_sat_signExt = {{8{ptch_err_sat[9]}},ptch_err_sat} ;
assign ptch_err_sat_SEA = ptch_err_sat_signExt + integrator;
assign not_ovf={~ptch_err_sat_signExt[17]&&~integrator[17]&&ptch_err_sat_SEA[17]}||{ptch_err_sat_signExt[17]&&integrator[17]&&~ptch_err_sat_SEA[17]};
assign vld_ov= vld & ~not_ovf;

always_ff@(posedge clk) begin
if(!rst_n)
integrator <= 0;
else if (rider_off)
integrator <= 18'h00000;
else if (vld_ov)
integrator <= ptch_err_sat_SEA;
else
integrator <= integrator;
end

always_ff @(posedge clk, negedge rst_n) begin
if (!rst_n)
post_ss_tmr<=0;
else 
post_ss_tmr <= pre_ss_tmr;
end

assign tmr = &post_ss_tmr[26:8] ? post_ss_tmr : post_ss_tmr + tmr_inc;
assign pre_ss_tmr = pwr_up ? tmr : 27'h0000000;
assign ss_tmr= post_ss_tmr[26:19];

endmodule
