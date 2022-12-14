module PID(ptch, ptch_rt,rider_off, pwr_up,vld, PID_cntrl, clk, rst_n, ss_tmr);

//Primary Inputs & Outputs
input signed [15:0] ptch, ptch_rt;
reg [17:0] integrator;
output signed [11:0] PID_cntrl;
input clk, rst_n;
output reg [7:0] ss_tmr;

//intermidiate signals
logic signed [9:0]  ptch_err_sat;
logic signed [14:0] P_term;
logic signed [14:0] I_term;
logic signed [12:0] D_term;
logic signed [15:0]  PID_intdr;
input rider_off, pwr_up, vld;

logic signed [17:0] ptch_err_sat_signExt, ptch_err_sat_sign_Ext_Add;
logic signed [17:0] vld_integrator, ride_off_cond_integrator;

logic signed [26:0] tmr_inc;
reg vld_ov, not_ovf, cnd1, cnd2;

//For calculating P term
localparam P_COEFF = 5'h0D;

//saturating ptch error to 10 bits
assign ptch_err_sat =(~ptch[15] && |ptch[14:9]) ? 10'h1FF :(ptch[15] && ~&ptch[14:9]) ? 10'h200 :ptch[9:0];
//P_term for for PID_cntrl
assign P_term = ptch_err_sat* $signed(P_COEFF);
//I_term for for PID_cntrl
assign I_term = {{3{integrator[17]}},integrator[17:6]};
//D_term for for PID_cntrl 
assign D_term = ~{{3{ptch_rt[15]}},ptch_rt[15:6]};


assign PID_intdr = {{{1{P_term[14]}}, P_term} + {{1{I_term[14]}}, I_term} + {{3{D_term[12]}}, D_term}};
//saturated PID_cntrl
assign PID_cntrl = (~PID_intdr[15] && |PID_intdr[14:11]) ? 12'h7FF :(PID_intdr[15] && ~&PID_intdr[14:11]) ? 12'h800 :
			  PID_intdr[11:0];


//Integrator
assign ptch_err_sat_signExt = {{8{ptch_err_sat[9]}},ptch_err_sat} ;
assign ptch_err_sat_sign_Ext_Add = ptch_err_sat_signExt+integrator;
assign vld_integrator = vld_ov?ptch_err_sat_sign_Ext_Add:integrator;
assign ride_off_cond_integrator = rider_off?18'h00000:vld_integrator;

always_ff@(posedge clk) begin
if(!rst_n)
integrator<=0;
else
integrator<=ride_off_cond_integrator;
end

//
assign vld_ov= vld&~not_ovf;
//checking overflow
assign cnd1= {~ptch_err_sat_signExt[17]&&~integrator[17]&&ptch_err_sat_sign_Ext_Add[17]};
assign cnd2= {ptch_err_sat_signExt[17]&&integrator[17]&&~ptch_err_sat_sign_Ext_Add[17]};
assign not_ovf=cnd1||cnd2;

//Soft Timer
reg [26:0] pre_ss_tmr, tmr, tmr_and;

always_ff @(posedge clk) begin
if (!rst_n)
pre_ss_tmr<=0;
else pre_ss_tmr<=tmr;

end

assign tmr= pwr_up?tmr_inc:27'h0000000;
assign tmr_inc= &pre_ss_tmr[26:8]? pre_ss_tmr:pre_ss_tmr+1;
//ss_tmr
assign ss_tmr= pre_ss_tmr[26:19];


endmodule 