module MasterSlave_tb();

reg d,clk,q;
wire md,mq,sd,iclk;

MasterSlave iDUT(.d(d),.clk(clk),.q(q));

always #5 clk=~clk;

initial begin
clk=0;
d=0;
#10
if(q==0)
$display("Proceed\n");
else 
$display("Try again\n");
#10

d=1;
#10
if(q==1)
$display("Proceed\n");
else 
$display("Try again\n");

d=0;
#15;
if(q==0)
$display("Proceed\n");
else 
$display("Try again\n");

d=1;
#15
if(q==1)
$display("Proceed\n");
else 
$display("Try again\n");
$stop();
end
endmodule