module PID_Math_tb();

//Signals
reg  [15:0] ptch, ptch_rt;
reg  [17:0] integrator;
wire  [11:0] PID_cntrl;


PID_Math iDUT( .ptch(ptch), .ptch_rt(ptch_rt), .integrator(integrator), .PID_cntrl(PID_cntrl));

initial begin

	ptch = 16'hFF00;
	ptch_rt = 16'h0FFF;
	integrator = 18'h3C000;

	repeat(64) begin
	#2;
	ptch = ptch + 16'h0001;
	ptch_rt = ptch_rt - 16'h0100;
	integrator = integrator + 18'h00080;
	end

	repeat(64) begin
	#2;
	ptch = ptch + 16'h0001;
	ptch_rt = ptch_rt + 16'h0100;
	integrator = integrator + 18'h00080;
	end
	
	repeat(64) begin
	#2;
	ptch = ptch + 16'h0001;
	ptch_rt = ptch_rt - 16'h0100;
	integrator = integrator - 18'h00080;
	end
	
	repeat(64) begin
	#2;
	ptch = ptch + 16'h0001;
	ptch_rt = ptch_rt + 16'h0100;
	integrator = integrator - 18'h00080;
	end
	
	repeat(64) begin
	#2;
	ptch = ptch + 16'h0001;
	ptch_rt = ptch_rt - 16'h0100;
	integrator = integrator + 18'h00080;
	end
	
	repeat(64) begin
	#2;
	ptch = ptch + 16'h0001;
	ptch_rt = ptch_rt + 16'h0100;
	integrator = integrator + 18'h00080;
	end
	
	repeat(64) begin
	#2;
	ptch = ptch + 16'h0001;
	ptch_rt = ptch_rt - 16'h0100;
	integrator = integrator - 18'h00080;
	end
	
	repeat(64) begin
	#2;
	ptch = ptch + 16'h0001;
	ptch_rt = ptch_rt + 16'h0100;
	integrator = integrator - 18'h00080;
	end
	
end

endmodule
