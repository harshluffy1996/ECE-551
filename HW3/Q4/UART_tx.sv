module UART_tx(clk,rst_n,trmt,tx_data,TX,tx_done);

//primary input & outputs
input clk,rst_n,trmt;
input [7:0]tx_data;
output logic TX,tx_done;

//intermidiate signals
logic load,shft,transmitting,set_done,clr_done;
logic [3:0] bit_cnt;
logic [11:0] baud_cnt;
logic [8:0] tx_shft_reg;

//for state machine
typedef enum reg{IDLE,TRANSMIT}state_t;
state_t state,nxt_state;


//state flop
always_ff@(posedge clk) begin
	if(load) begin
	  bit_cnt<=4'h0;
	  end
	else if(shft) begin
	  bit_cnt<=bit_cnt+1;
	  end
end
always_ff@(posedge clk) begin
	if(load|shft) begin
	  baud_cnt<=12'h0000;
	  end
	else if(transmitting) begin
 	  baud_cnt<=baud_cnt+1;
	  end
end

always_ff@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
	  tx_shft_reg<=9'h1FF;
	  end
	else if(load) begin
	  tx_shft_reg<={tx_data,1'b0};
	  end
	else if(shft) begin
	  tx_shft_reg<={1'b1,tx_shft_reg[8:1]};
	  end
end

assign TX=tx_shft_reg[0];

always_ff@(posedge clk, negedge rst_n) begin
	if(!rst_n)begin
	  state<=IDLE;
	  end
	else begin
	  state<=nxt_state;
	  end
end

always_comb begin
load=0;
transmitting=0;
shft=0;
set_done=1;
clr_done=0;
nxt_state=IDLE;

 case(state)
	IDLE:if(trmt) begin
	      load=1;
              transmitting=0;
              shft=0;
              set_done=0;
              clr_done=1;
              nxt_state=TRANSMIT;
	     end
    TRANSMIT:if(baud_cnt==12'hA2C)begin
	      load=0;
              transmitting=1;
              shft=1;
              set_done=0;
              clr_done=1;
              nxt_state=TRANSMIT;
	     end
	     else if(bit_cnt<4'hA)begin
	      load=0;
              transmitting=1;
              shft=0;
              set_done=0;
              clr_done=1;
              nxt_state=TRANSMIT;
             end
	     else if(bit_cnt>=4'hA)begin
	       load=0;
               transmitting=0;
               shft=0;
               set_done=1;
               clr_done=0;
               nxt_state=IDLE;
             end

    default:begin
	load=0;
        transmitting=0;
        shft=0;
        set_done=1;
        clr_done=0;
        nxt_state=IDLE;
    end
  endcase
end

always_ff@(posedge clk,negedge rst_n) begin
	if(!rst_n) begin
	 tx_done<=1'b0;
	 end
	else if(clr_done) begin
	 tx_done<=1'b0;
	 end
	else if(set_done) begin
	 tx_done<=1'b1;
	 end
end

endmodule
