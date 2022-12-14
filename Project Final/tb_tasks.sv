/*File which includes all the tasks that are implemented in the Segway Testbench*/

localparam g = 8'h67;
localparam s = 8'h73;
//TASK 1 : Initialize Segway

task automatic InitializeSegway(ref clk, ref RST_n, ref send_cmd, ref OVR_I_lft, ref OVR_I_rght, 
								ref [7:0] cmd, 
								ref signed [15:0] rider_lean, 
								ref logic [11:0] ld_cell_lft, 
								ref logic [11:0] ld_cell_rght, 
								ref logic [11:0] steerPot, 
								ref logic [11:0] batt);
	clk = 0;
	RST_n = 0;
	send_cmd = 0;
	OVR_I_lft = 0;
	OVR_I_rght = 0;
	cmd = 8'h00;
	rider_lean = 16'h0000;
	ld_cell_lft = 12'h000;
	ld_cell_rght = 12'h000;
	steerPot = 12'h800;
	batt = 12'h000;
	@(posedge clk);
	@(negedge clk);
	RST_n = 1'b1;
endtask

//TASk 2 : Send Command for STOP AND GO. It initiates the transfer and waits for the cmd_sent signal.
		// g = 0x67 , s = 0x73

task automatic SendCmd(ref clk, ref send_cmd, ref logic [7:0] cmd, input logic [7:0] data, ref logic cmd_sent);
	@(negedge clk);
	cmd = data;
	send_cmd = 1;
	@(posedge clk);
	@(negedge clk);
	send_cmd = 0;
	@(posedge cmd_sent);
endtask 

//TASK 3 : CHECK AND COMPARE VALUES of the signals being tested.

task automatic CheckAndCompare(string signal_name, string test_name, integer actual, integer expected);
	if( actual !== expected) begin
		$display("Error..! : Signal Name : %s, Test Name : %s, Actual Value : %h, Expected Value : %h", signal_name, test_name, actual,expected);
		$stop();
	end
endtask
	
	
	
