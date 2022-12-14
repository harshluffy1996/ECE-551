module UART_rx (
	input RX, clr_rdy, clk, rst_n,
	output reg rdy,
	output [7:0] rx_data);
	
	logic set_rdy, start, receiving, sr_ff_out, shift ;
	logic RX_sync_ff1_q, RX_sync_ff2_q;
	logic [3:0] bit_cnt;
	logic bit_cnt_eq_10;
	logic [8:0] rx_shift_reg;
	logic [11:0] baud_cnt, initial_baud_cnt_value;
	
	// double flopping RX input for metastability resolution
	always_ff @ (posedge clk, negedge rst_n) begin
		if (!rst_n) begin
			RX_sync_ff1_q <= 1;
			RX_sync_ff2_q <= 1;
		end
		else  begin
			RX_sync_ff1_q <= RX ;
			RX_sync_ff2_q <= RX_sync_ff1_q;
		end
	end
	
	// input to SM for telling to move from receive state to IDLE state
	assign bit_cnt_eq_10 = bit_cnt[3] & (!bit_cnt[2]) & bit_cnt[1] & (!bit_cnt[0]) ;
	
	//////// FSM ///////
	typedef enum reg {IDLE, RECEIVE} state_t;
	state_t curr_state, next_state;
	
	// state register flop
	always_ff @ (posedge clk, negedge rst_n) begin
		if (!rst_n)
			curr_state <= IDLE;
		else
			curr_state <= next_state;
	end
	
	// state transition and output logic
	always_comb begin
		set_rdy = 0;
		receiving = 0;
		start = 0;
		next_state = curr_state;
		
		case (curr_state)
			RECEIVE : begin
				if (bit_cnt_eq_10 == 1) begin
					next_state = IDLE;
					set_rdy = 1;
				end
				else begin
					start = 0;
					receiving = 1;
				end
			end
			default : begin
				if (RX_sync_ff2_q == 0) begin
					next_state = RECEIVE;
					start = 1;
					receiving = 1;
				end
			end
		endcase
	end
	//// FSM end ///////

	// SR flop for rdy signal computation
	always_ff @ (posedge clk, posedge clr_rdy) begin
		if(clr_rdy)
			sr_ff_out <= 0;
		else if (start)
			sr_ff_out <= 0;
		else if (set_rdy)
			sr_ff_out <= 1;
	end
	
	always_ff @ (posedge clk, negedge rst_n) begin
		if (!rst_n)
			rdy <= 0;
		else
			rdy <= sr_ff_out;
	end
	
	// rx shifting data
	always_ff @ (posedge clk) begin
		if (shift)
			rx_shift_reg <= {RX_sync_ff2_q, rx_shift_reg[8:1]};

	end
	
	assign rx_data = rx_shift_reg[7:0];
	
	// tracking num of bit received, bit_cnt
	always_ff @ (posedge clk) begin
		if (start)
			bit_cnt <= 0;
		else if (shift)
			bit_cnt = bit_cnt + 1;
	end
	
	// baud_cnt for 1302 or 2604 cycles for receiving bits
	
	assign initial_baud_cnt_value = start ? 12'd1302 : 12'd2604 ;
	
	always_ff @ (posedge clk) begin
		if(start || shift)
			baud_cnt <= initial_baud_cnt_value ;
		else if (receiving)
			baud_cnt <= baud_cnt - 1;	
	end
	
	assign shift = (baud_cnt == 12'd0) ? 1 : 0;

endmodule