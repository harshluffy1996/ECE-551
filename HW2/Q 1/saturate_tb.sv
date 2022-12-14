module saturate_tb();

reg [15:0]unsigned_err;
reg [15:0]signed_err;
reg [9:0]signed_D_diff;

reg [9:0]unsigned_err_sat;
reg [9:0]signed_err_sat;
reg [6:0]signed_D_diff_sat; 

saturate iDUT(.unsigned_err(unsigned_err),.signed_err(signed_err),.signed_D_diff(signed_D_diff),.unsigned_err_sat(unsigned_err_sat),.signed_err_sat(signed_err_sat),.signed_D_diff_sat(signed_D_diff_sat));

initial begin

    unsigned_err=16'hEA60; //60000
    #5;
    if(unsigned_err_sat==10'h3FF)begin
	$display("correctly satured!");    
    end
    else begin
	$stop();
    end
    unsigned_err=16'hF6;
    #5

    signed_err=16'hFFFF; 
    #5;
    if(signed_err_sat==10'h1FF)begin
	$display("correctly satured!");    
    end
    else
	$stop();

    signed_D_diff=10'hF8; //60000
    #5;
    signed_D_diff=10'hD; //504
    #5;

$stop();
end
endmodule 