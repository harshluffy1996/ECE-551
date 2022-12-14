module piezo_drv(clk,rst_n,en_steer,too_fast,batt_low,piezo,piezo_n);
input clk,rst_n,en_steer,too_fast,batt_low;
output piezo,piezo_n;

logic [26:0]dur_cnt;			//Counter to determine the duration of the note.
logic [15:0]freq_cnt;			//Timer used to establish the note frequency.
logic [27:0]repeat_tmr;			//Timer used to repeat Charge Fanfare every 3 seconds.
logic [6:0] fast_inc;			//Used for simulation purposes.
logic [26:0]dur_cnt_en;			//It is used to store the individual duration period.
logic [15:0]frq_cnt_en;			//It is used to store the frequency period of the notes.
logic three_sec_tmr_met;		

localparam three_sec_tmr = 28'h8F0D180;
parameter fast_sim = 1;

///Frequency periods of 6 different notes.
localparam G6_freq_pd = 16'h7C8F;
localparam C7_freq_pd = 16'h5D51;
localparam E7_freq_pd = 16'h4A10;
localparam G7_freq_pd = 16'h3E47;
localparam E7_1_freq_pd = 16'h4A10;
localparam G7_1_freq_pd = 16'h3E47;

///Duration period of 6 different notes.
localparam G6_dur_pd = 27'h07FFFFF;
localparam C7_dur_pd = 27'h07FFFFF;
localparam E7_dur_pd = 27'h07FFFFF;
localparam G7_dur_pd = 27'h0BFFFFE;
localparam E7_1_dur_pd = 27'h03FFFFF;
localparam G7_1_dur_pd = 27'h1FFFFFF;

	typedef enum reg[2:0]{IDLE,G6_S1,C7_S2,E7_S3,G7_S4,E7_S5,G7_S6} state_t;
	state_t curr_state, nxt_state;

	always@(posedge clk, negedge rst_n) begin
	if (!rst_n)
		curr_state<=IDLE;
	else 
		curr_state<=nxt_state;
	end

    //////////////////////////////////////////////////////////////////////////////////
	////////////////////Infer state transition logic & SM outputs////////////////////
    //////////////////////////////////////////////////////////////////////////////// 
	always_comb begin
		nxt_state = curr_state;
		dur_cnt_en = 0;
		frq_cnt_en = 0;
    //////////////////////////////////////////////////////////////////////////////////
	////////////////////Next state logic default outputs/////////////////////////////
    //////////////////////////////////////////////////////////////////////////////// 
	case (curr_state)

	IDLE : begin					

	if (too_fast) begin                   ///too_fast the highest priority///
		nxt_state = G6_S1;
		
	end

	else if (batt_low & !too_fast & repeat_tmr > three_sec_tmr)                        ///charge fanfare should be played backwards if its batt_low//
		nxt_state = G7_S6;
	else if (en_steer & !too_fast & !batt_low & repeat_tmr > three_sec_tmr) begin   ////en_steer should occur once every 3 seconds///
		nxt_state = G6_S1;
		
		end
	else 
		nxt_state=IDLE;
    end

	G6_S1 : begin

		dur_cnt_en = G6_dur_pd;                                                      //dur_cnt of respective note has to be met to go further the next state//
		frq_cnt_en = G6_freq_pd;

	if (dur_cnt > dur_cnt_en) begin
	if (too_fast) begin
		nxt_state = C7_S2;
		
	end
	else if (batt_low & !too_fast)
		nxt_state = IDLE;
	else if (en_steer & !too_fast & !batt_low) begin
		nxt_state = C7_S2;
	
	end
	else
		nxt_state = IDLE;
	end
	end



	C7_S2 : begin

		dur_cnt_en = C7_dur_pd;
		frq_cnt_en = C7_freq_pd;

	if (dur_cnt > dur_cnt_en) begin
	if (too_fast) begin                                        
		nxt_state = E7_S3 ;
		
	end
	else if (batt_low & !too_fast) begin
		nxt_state = G6_S1;
		
	end
		else if(en_steer & !too_fast & !batt_low) begin
		nxt_state = E7_S3;
		
	end
	else 
		nxt_state = IDLE;
	end
	end


	E7_S3 : begin			

		dur_cnt_en = E7_dur_pd;
		frq_cnt_en = E7_freq_pd;

	if (dur_cnt > dur_cnt_en) begin
	if (too_fast) begin                                             ////too_fast should be the first 3 notes of charge fanfare///
		nxt_state = G6_S1;
		
	end
		else if (batt_low & !too_fast) begin
		nxt_state = C7_S2;
	
	end
	else if (en_steer & !batt_low & !too_fast) begin
		nxt_state = G7_S4;
		
	end
	else 
		nxt_state = IDLE; 
	end
	end


	G7_S4 : begin

		dur_cnt_en = G7_dur_pd;
		frq_cnt_en = G7_freq_pd;

	if (dur_cnt > dur_cnt_en) begin
	if (too_fast) begin
		nxt_state = G6_S1;
		
	end
	else if (batt_low & !too_fast) begin
		nxt_state = E7_S3;
		
	end
	else if (en_steer & !too_fast & !batt_low) begin
		nxt_state = E7_S5;
		
	end
	else 
		nxt_state = IDLE; 
	end
	end


	E7_S5 : begin

		dur_cnt_en = E7_1_dur_pd;
		frq_cnt_en = E7_1_freq_pd;

	if (dur_cnt > dur_cnt_en) begin
	if (too_fast) begin
		nxt_state = G6_S1;
		
	end
	else if (batt_low & !too_fast) begin
		nxt_state = G7_S4;
		
	end
	else if (en_steer & !too_fast & !batt_low) begin
		nxt_state = G7_S6;
		
	end
	else 
		nxt_state = IDLE;
	end
	end


	G7_S6 : begin

		dur_cnt_en = G7_1_dur_pd;
		frq_cnt_en = G7_1_freq_pd;

	if (dur_cnt > dur_cnt_en) begin
	if (too_fast) begin
		nxt_state = G6_S1;
	
	end
	else if (batt_low & !too_fast) begin
		nxt_state = E7_S5;
	
	end
	else if (en_steer & repeat_tmr > three_sec_tmr) begin
		nxt_state = G6_S1;
		
	end
	else 
		nxt_state = IDLE;
	end
	end

	default : nxt_state = IDLE;
	endcase
	end
     ////////////////////////////////////////////////////////////////////
	 ////To fatsen simulation purposes, fastsim is implemented///////////
     ///////////////////////////////////////////////////////////////////
	generate if(fast_sim) begin
		assign fast_inc = 64;
	end
	else begin
		assign fast_inc = 1;
	end
	endgenerate
	 //////////////////////////////////////////////////////////////
	 /////frequency counter logic//////////////////////////////////
     ////////////////////////////////////////////////////////////

	always@(posedge clk, negedge rst_n) begin
	if(!rst_n)
		freq_cnt<=16'h0000;
	else if (freq_cnt >= frq_cnt_en)
		freq_cnt<=16'h0000;
	else if (en_steer | batt_low)
		freq_cnt<=freq_cnt+fast_inc;
		
	end
 
     //////////////////////////////////////////////////////////////
	 /////duration counter logic//////////////////////////////////
     ////////////////////////////////////////////////////////////
	always@(posedge clk, negedge rst_n) begin
	if(!rst_n)
		dur_cnt<=27'h0000000;
	else if (dur_cnt >= dur_cnt_en)
		dur_cnt<=27'h0000000;
	else if (en_steer | batt_low)
		dur_cnt <= dur_cnt + fast_inc;
	
	end

      //////////////////////////////////////////////////////////////
	 /////Three seconds timer logic//////////////////////////////////
     ////////////////////////////////////////////////////////////
	always_ff@(posedge clk, negedge rst_n)begin
	if(!rst_n)
		repeat_tmr <= 27'h0000000;
	else if ( three_sec_tmr_met)
		repeat_tmr <= 27'h0000000;
	else repeat_tmr <= repeat_tmr + fast_inc;
	end

	
	
	assign three_sec_tmr_met = (repeat_tmr > three_sec_tmr)?1:0;

	assign piezo = (freq_cnt >= frq_cnt_en/2) ? 1 : 0;       ////when freq_cnt reaches half the note period, piezo switches from high to low//
	
	assign piezo_n = ~piezo;


endmodule























