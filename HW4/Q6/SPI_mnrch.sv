module SPI_mnrch(clk, rst_n, wt_data, rd_data, done, MOSI, MISO, SCLK, SS_n, wrt);

//primary input and outputs
input clk;
input rst_n;
input MISO;
input wrt;
input [15:0] wt_data;
output SCLK, MOSI;
output reg SS_n;
output reg done;
output [15:0] rd_data;


logic [3:0] bit_3_counter;
logic [15:0] bit_15_shft_reg;
logic [3:0] Div_SCLK;

//1 bit intermidiate signals
logic finally_done;
logic bits_done;
logic shft;
logic sample;
logic shft_im;
logic ld_clk;
logic init;
logic MISO_SMPL;

//state machine states
typedef enum reg [1:0] {IDLE, FRONT_PORCH, WAIT, BACK_PORCH} state_t;
state_t state, nxt_state;

//state transsition
always_ff @ (posedge clk, negedge rst_n) begin
	if (!rst_n) begin
		state <= IDLE;
	end
	else begin
		state <= nxt_state;
	end
end

///SS_n
always_ff @(posedge clk, negedge rst_n) begin
	if (!rst_n )begin
			SS_n <= 1;
      end
	else if(init )begin
			SS_n  <= 0;
      end
	else if(finally_done)begin
			SS_n <= 1;
      end	
end
//flopt for output done
always_ff @(posedge clk, negedge rst_n) begin
	if (!rst_n ) begin
			done <= 0;
			end
	else if(init || !finally_done) begin
			done <= 0;
			end
	else if(finally_done) begin
			done <= 1;
			end
end



///Flipflop for bit counter
always_ff @ (posedge clk) begin
	if (init) begin
		bit_3_counter <= 4'b0000;
    end
	else if (shft) begin
		bit_3_counter <= bit_3_counter + 1;
    end
end
	
assign bits_done = & bit_3_counter[3:0];

//logic SCLK
always_ff @ (posedge clk) begin
	if (ld_clk)begin
		Div_SCLK <= 4'b1011;
    end
	else begin
		Div_SCLK <= Div_SCLK + 1;
    end
end

//Shift data on falling edge and sample MISo on rising edge
assign SCLK = Div_SCLK[3];
assign shft_im = (Div_SCLK == 4'b1111) ? 1:0; 
assign sample    = (Div_SCLK == 4'b0111) ? 1:0; 

//MISO sample
always_ff @ (posedge clk) begin
	if (sample) begin
		MISO_SMPL <= MISO;
    end
end

assign MOSI = bit_15_shft_reg[15];
assign rd_data = bit_15_shft_reg;

//shift for MOSI
always_ff @ (posedge clk) begin 
	if (init) begin
		bit_15_shft_reg <= wt_data;
    end
	else if (shft) begin
		bit_15_shft_reg <= {bit_15_shft_reg[14:0], MISO_SMPL};
    end
end

		

//state machine begin
always_comb begin
	init = 0;
	shft = 0;
	finally_done = 0;
	ld_clk = 1;
	nxt_state = state;
	
	case (state)
	IDLE : begin
		if(wrt) begin
			init = 1;
			finally_done = 0;
			ld_clk = 0;
			shft = 0;
			nxt_state =  FRONT_PORCH;
			
		end
		
	end
	
	FRONT_PORCH : begin
		init = 0;
		ld_clk = 0;
		
		if(!shft_im && sample) 
			nxt_state = WAIT;
	end
	
	WAIT : begin
	
		ld_clk = 0;
		if(!shft_im && sample && bits_done) begin
			shft = 0;
			nxt_state = BACK_PORCH;
		end
		else if(shft_im && !sample) begin
			
			shft = 1;
		end
	
	end
	
	BACK_PORCH : begin
		if(shft_im && !sample && bits_done) begin
			init = 0;
			finally_done = 1;
			ld_clk = 1;
			shft = 1;
			nxt_state = IDLE;
		end
		else 
			ld_clk = 0;
	end
    endcase	
end
endmodule	