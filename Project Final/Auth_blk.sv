module Auth_blk(RX, rider_off,pwr_up,clk,rst_n);

input clk,rst_n, rider_off, RX;
logic [7:0] rx_data;					//8-bit data that we receive
output logic pwr_up;
logic rx_rdy, clr_rx_rdy;

localparam g = 8'h67;					//Values for STOP(s) and GO(g)
localparam s = 8'h73;


UART_rx iUART(.clk(clk), .rst_n(rst_n), .RX(RX), .clr_rdy(clr_rx_rdy), .rdy(rx_rdy), .rx_data(rx_data));
typedef enum reg[1:0] {OFF,PWR1,PWR2} state_t;		//States of State Machine
state_t state, nxt_state;

always_ff @(posedge clk, negedge rst_n)
   if (!rst_n)
    state <= OFF;
   else
    state <= nxt_state;

always_comb begin					  //Declaring the default values.
  	nxt_state = OFF;
 	pwr_up = 0;
  	clr_rx_rdy = 0;

  case (state)
    OFF : if (rx_data == g) begin			  //If the BLE121LR sends out g over its UART TX line.
      	pwr_up = 1;
      	clr_rx_rdy = 1;
      	nxt_state = PWR1;
    end

    PWR1 : if (rider_off && rx_rdy && rx_data == s) begin //If the rider not present and the phone app disconnects deliberately or due to range.
      	pwr_up = 0;
      	clr_rx_rdy = 1;
      	nxt_state = OFF;
    end 
    else if (!rider_off && rx_rdy && rx_data == s) begin  //If the rider gets off and the phone app disconnects deliberately or due to range.
      	pwr_up = 1;
      	clr_rx_rdy = 1;
      	nxt_state = PWR2;
    end
    else begin
      	pwr_up = 1;
      	nxt_state = PWR1;
    end

    PWR2 : if (rx_data == g && rx_rdy) begin  		  //Move back to the PWR1 state if pwr_up and clr_rx_rdy both are asserted
      	pwr_up = 1;
      	clr_rx_rdy = 1;
      	nxt_state = PWR1;
    end
    else if (rider_off) begin				 //Return to the OFF State if the rider gets off.
      	pwr_up = 0;
      	nxt_state = OFF;
    end
    else begin
      	pwr_up = 1;					//If pwr_up is still asserted stay in the same PWR2 State.
      	nxt_state = PWR2;
    end

  default : begin
    	nxt_state = OFF;
    	pwr_up = 0;
    	clr_rx_rdy = 0;
  end

  	endcase
end

     
endmodule
