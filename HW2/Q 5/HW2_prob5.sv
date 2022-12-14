/* a. According to me the given code d_latch is incorrect the reason being d is not in the sensitivity list */

//b. active high sync reset
module dff_sync_reset(d1,clk1,q1,reset1);
input d1, clk1,reset1;
output reg q1;

always_ff @(posedge clk1)
begin
	if(reset1)
		q1<=0;
	else
		q1<=d1;
end
endmodule


//c. asynchronous active low reset and an active high enable
module dff_async_reset(d2,clk2,asyn_reset_n2,en2,q2);
input d2,clk2,asyn_reset_n2,en2;
output reg q2;

always_ff@(posedge clk2,negedge asyn_reset_n2)
begin
if(asyn_reset_n2==0)
	q2<=0;
else if(en2)
	q2<=d2;
end
endmodule

//d. active low async reset
module SR(S,R,clk,async_reset_n,q);
input S,R,clk,async_reset_n;
output reg q;

always_ff@(posedge clk,negedge async_reset_n)
begin
	if(async_reset_n==0)
		q<=0;
	else if(S==0 && R==1)
		q<=0;
	else if(S==1 && R==0)
		q<=1;
	else if(S==1 && R==1)
		q<=0;
end
	
endmodule



/* e. Yes, the always_ff construct ensures the logic will infer a flop because it is a sequential logic block.*/
