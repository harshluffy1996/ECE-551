module PWM11(clk,rst_n,duty,PWM_sig,PWM_synch,OVR_I_blank_n, cnt,cnt_all_zeros );
//primary input and outputs
input clk;
input rst_n;
input [10:0]duty;
output reg PWM_sig;
output reg PWM_synch;
output reg OVR_I_blank_n;
output reg cnt_all_zeros;
output reg [10:0]cnt;

assign PWM_synch=(&cnt);   //To synchronize changes to in duty to PWM Cycle.
assign cnt_all_zeros=|cnt;

 

//Always block for setting and resetting PWM_sig
always_ff@(posedge clk,negedge rst_n) begin
	if(rst_n==0) begin
              PWM_sig<=0;  
	end

	else if (cnt_all_zeros==0)begin
	      PWM_sig<=1;
	end

	else if(cnt>=duty) begin  
              PWM_sig<=0;
	end

end

//Always block for 11 bit Counter & OVR_I_blank_n
always_ff@(posedge clk,negedge rst_n) begin
	if(rst_n==0) begin
              cnt<=0;
	end
	else if(cnt<duty) begin
              cnt<=cnt+1;
	end
	else if (cnt>255) begin
	      OVR_I_blank_n<=1;
	end

end

endmodule 