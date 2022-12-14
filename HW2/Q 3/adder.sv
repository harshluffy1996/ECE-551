module full_adder_behavioral(input [3:0]a,input [3:0]b,input cin,output [3:0]sum,output cout);
assign {cout,sum}=a+b+cin;
endmodule 


module full_adder_dataflow(input [3:0]a,input [3:0]b,input cin,output [3:0]sum,output cout);
wire w1,w2,w3;
full_adder_1bit f0(.a(a[0]),.b(b[0]),.cin(cin),.cout(w1),.sum(sum[0]));
full_adder_1bit f1(.a(a[1]),.b(b[1]),.cin(w1),.cout(w2),.sum(sum[1]));
full_adder_1bit f2(.a(a[2]),.b(b[2]),.cin(w2),.cout(w3),.sum(sum[2]));
full_adder_1bit f3(.a(a[3]),.b(b[3]),.cin(w3),.cout(cout),.sum(sum[3]));

endmodule 

module full_adder_1bit(input a,input b,input cin,output sum,output cout);
assign sum=a^b^cin;
assign cout=(a&b) | (cin&(a^b));
endmodule 