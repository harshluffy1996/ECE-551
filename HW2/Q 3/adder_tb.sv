module full_adder_tb();
reg [3:0]a,b;
reg cin;
wire [3:0]sum_behavioral,sum_dataflow;
wire cout_behavioral,cout_dataflow;


full_adder_behavioral iDUT_golden(.a(a),.b(b),.cin(cin),.cout(cout_behavioral),.sum(sum_behavioral));
full_adder_dataflow iDUT_dataflow(.a(a),.b(b),.cin(cin),.cout(cout_dataflow),.sum(sum_dataflow));
int correct=0;
initial begin
a=0;
b=0;
cin=0;

for(int i=0;i<2;i++) begin
for(int j=0;j<16;j++) begin
for(int k=0;k<16;k++) begin
a=j;
b=k;
cin=i;
#1;
if((cout_behavioral==cout_dataflow)&&(sum_behavioral==sum_dataflow)) begin
	correct++;
end
else
	$stop();
end
end
end
if(correct==512)
$display("testbench sucessful :)");
$stop();
end

endmodule
