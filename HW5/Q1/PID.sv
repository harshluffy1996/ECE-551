module PID(ptch, ptch_rt,rider_off, pwr_up,vld, PID_cntrl, clk, rst_n, ss_tmr);


input clk, rst_n;
input rider_off, pwr_up, vld;
input signed [15:0] ptch, ptch_rt;
output signed [11:0] PID_cntrl;
output reg [7:0] ss_tmr;
reg [17:0] integrator;
logic signed [9:0]  ptch_err_sat;
logic signed [14:0] P_term, I_term;
logic signed [12:0] D_term;
logic signed [15:0]  PID_indmdte;

logic signed [17:0] ptch_err_SSE, ptch_err_sat_SEA, intgrtr_vld, ride_off_CI;
logic signed [26:0] ss_tmr_old, tmr, ss_tmr_new;

logic [8:0] tmr_inc;
reg validOverFlow, OverFlow, First_cond, Sec_cond;
localparam P_COEFF = 5'h0C;
parameter fast_sim =1;

generate if(fast_sim) begin
assign tmr_inc = 9'h100;
assign I_term = (~integrator[17] && |integrator[16:14]) ? 15'h3FFF :
		        (integrator[17] && ~&integrator[16:14]) ? 15'h8000 :					
	 	         integrator[15:1];
end
		else begin
			assign tmr_inc = 9'h001;
			assign I_term = {{3{integrator[17]}},integrator[17:6]};
end
endgenerate

assign ptch_err_sat =   (~ptch[15] && |ptch[14:9]) ? 10'h1FF :	
			(ptch[15] && ~&ptch[14:9]) ? 10'h200 :
			 ptch[9:0];				

assign P_term = ptch_err_sat*$signed(P_COEFF);


assign D_term = ~{{3{ptch_rt[15]}},ptch_rt[15:6]};		
assign PID_indmdte = {{{1{P_term[14]}}, P_term} + {{1{I_term[14]}}, I_term} + {{3{D_term[12]}}, D_term}}; 
assign PID_cntrl = (~PID_indmdte[15] && |PID_indmdte[14:11]) ? 12'h7FF :
		   		   (PID_indmdte[15] && ~&PID_indmdte[14:11]) ? 12'h800 :					
			  		  PID_indmdte[11:0];

assign ptch_err_SSE = {{8{ptch_err_sat[9]}},ptch_err_sat} ;
assign ptch_err_sat_SEA = ptch_err_SSE+integrator;
assign intgrtr_vld = validOverFlow ? ptch_err_sat_SEA : integrator;
assign ride_off_CI = rider_off ? 18'h00000 : intgrtr_vld;

always_ff@(posedge clk) begin
	if(!rst_n)
		integrator<=0;
	else
		integrator <= ride_off_CI;
end

assign validOverFlow = vld & ~OverFlow;
assign OverFlow = {~ptch_err_SSE[17]&&~integrator[17]&&ptch_err_sat_SEA[17]}||{ptch_err_SSE[17]&&integrator[17]&&~ptch_err_sat_SEA[17]};


always_ff @(posedge clk, negedge rst_n) begin
	if (!rst_n)
		ss_tmr_new <= 0;
	else ss_tmr_new <= ss_tmr_old;
end

assign tmr = &ss_tmr_new[26:8]? ss_tmr_new:ss_tmr_new+tmr_inc;
assign ss_tmr_old = pwr_up?tmr : 27'h0000000;
assign ss_tmr= ss_tmr_new[26:19];

endmodule

