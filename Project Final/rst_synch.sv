module rst_synch(input RST_n, input clk, output reg rst_n);
logic rs1;

	always_ff @(negedge clk, negedge RST_n)
	  if (!RST_n)
		rs1 <= 1'b0; 
	  else
		rs1 <= 1'b1;    

	//metastability reasons
	always_ff @(negedge clk, negedge RST_n)
	  if (!RST_n)
		rst_n <= 1'b0; 
	  else
		rst_n <= rs1;    

endmodule 