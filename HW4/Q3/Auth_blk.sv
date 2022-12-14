module Auth_blk(clk,rst_n,rx_rdy,rx_data,rider_off,pwr_up,clr_rx_rdy);

//primary input and outputs
input clk,rst_n;
input rx_rdy,rider_off;
input [7:0] rx_data;
output logic pwr_up;
output logic clr_rx_rdy;

//States for state Machine
typedef enum reg[1:0] {OFF,PWP_UP,WAIT} state_t;
state_t state, nxt_state;

//Flop for state
always_ff @(posedge clk, negedge rst_n)
  if (!rst_n)
    state <= OFF;
  else
    state <= nxt_state;

//State Machine
always_comb begin
  nxt_state = OFF;
  pwr_up = 0;
  clr_rx_rdy = 0;

  case (state)
//Change State from OFF to Power on if rx_data gets Go signal G = 8'h67
    OFF : if (rx_data == 8'h67) begin
      pwr_up = 1;
      clr_rx_rdy = 1;
      nxt_state = PWP_UP;
    end

//Chech for balance go to OFF state if rider is OFF and sehway recieved STOP signal  
    PWP_UP : if (rider_off && rx_rdy && rx_data == 8'h73) begin
      pwr_up = 0;
      clr_rx_rdy = 1;
      nxt_state = OFF;
    end 
//If rider is ON and received STOP signal saty in WAIT State
    else if (!rider_off && rx_rdy && rx_data == 8'h73) begin
      pwr_up = 1;
      clr_rx_rdy = 1;
      nxt_state = WAIT;
    end
//Go back to Normal Power On mode
    else begin
      pwr_up = 1;
      nxt_state = PWP_UP;
    end
//Go back to Power On if Go signal is recieved
    WAIT : if (rx_data == 8'h67 && rx_rdy) begin
      pwr_up = 1;
      clr_rx_rdy = 1;
      nxt_state = PWP_UP;
    end
//If rider is off and recieved STOP signal go to OFF state
    else if (rider_off) begin
      pwr_up = 0;
      nxt_state = OFF;
    end
//Else continue to WAIT, we don't want our rider to fell, Right?
    else begin
      pwr_up = 1;
      nxt_state = WAIT;
    end

  default : begin
    nxt_state = OFF;
    pwr_up = 0;
    clr_rx_rdy = 0;
  end

  endcase
end

     
endmodule 