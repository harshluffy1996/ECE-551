module PID_Math(ptch, ptch_rt, integrator, PID_cntrl);

/*Primary input and outputs*/
input signed [15:0] ptch, ptch_rt;
input signed [17:0] integrator;
output signed [11:0] PID_cntrl;

/*signals used for intermidiate stages*/
logic signed [9:0]  ptch_err_sat;
logic signed [14:0] P_term;
logic signed [14:0] I_term;
logic signed [12:0] D_term;
logic signed [15:0] PID_inter;

localparam  P_COEFF = 5'h0C;

/*For P_term calculation*/
assign ptch_err_sat =   (~ptch[15] && |ptch[14:9]) ? 10'h1FF :
			(ptch[15] && ~&ptch[14:9]) ? 10'h200 :
			 ptch[9:0];
//First Term
assign P_term = ptch_err_sat*$signed(P_COEFF);

//Second Term which is calculated by diving integrator by 64
assign I_term = {{3{integrator[17]}},integrator[17:6]};

/*D_term is simply proportional to the angular rate ( ptch_rt )
So, we can calculate it by dividing ptch_rt by 64 and taking its 2's complement*/
assign D_term = ~{{3{ptch_rt[15]}},ptch_rt[15:6]};


/*For a summation of the three terms we need all terms of 16 bits, that's why we are performing sign extension here*/
assign PID_inter = {{{1{P_term[14]}}, P_term} + {{1{I_term[14]}}, I_term} + {{3{D_term[12]}}, D_term}};

/*saturating to 12 bits because that's the desired size*/
assign PID_cntrl = (~PID_inter[15] && |PID_inter[14:11]) ? 12'h7FF :
		    (PID_inter[15] && ~&PID_inter[14:11]) ? 12'h800 :
				    PID_inter[11:0];

endmodule

