//PMW Testbench
module PMW11_tb();
reg clk,rst_n;
wire [10:0] cnt;
reg[10:0] duty;
wire PWM_sig, PWM_synch;
wire OVR_I_blank_n;
wire cnt_all_zeros; 

//instantiate 
PWM11 iDUT(.clk(clk),.rst_n(rst_n),.cnt(cnt),.duty(duty),.PWM_sig(PWM_sig),.PWM_synch(PWM_synch),.OVR_I_blank_n(OVR_I_blank_n),.cnt_all_zeros(cnt_all_zeros));


initial begin 
clk=0;
rst_n=0;  


@(negedge clk) rst_n=1;
duty=11'h000;
#100;
duty=11'h400;
#100
repeat(2048) begin 
@(posedge clk);
end
$stop();
end
always 
#5clk=~clk;
endmodule
