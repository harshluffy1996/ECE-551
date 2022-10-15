module MasterSlave(input d, input clk, output q);

wire md,mq,sd,iclk;

assign iclk=~clk;
assign #1 md=iclk?d:'bz;

not inv1(mq,md);
not (weak0,weak1) inv2(md,mq);

assign #1 sd=clk?mq:'bz;

not inv3(q,sd);
not (weak0,weak1) inv4(sd,q);

endmodule
