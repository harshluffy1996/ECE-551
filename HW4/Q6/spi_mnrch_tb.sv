module SPI_mnrch_tb();

//Primary input registers
reg clk, rst_n, MISO, wrt;
reg [15:0]wt_data;

wire SS_n, INT, SCLK, MOSI, done;
wire [15:0]rd_data;

//16-bit locacal variables
localparam Finding_Nemo_Address=16'h006A;
localparam Pitch=16'h0063;

//intanstiating SPI
SPI_mnrch iDUT_SPI_mnrch(.clk(clk),.rst_n(rst_n),.MISO(MISO),.wrt(wrt),.SS_n(SS_n),
                        .SCLK(SCLK),.MOSI(MOSI),.wt_data(wt_data),.done(done),.rd_data(rd_data));
//intanstiating Nemo
SPI_iNEMO1 iDUT_SPI_iNEMO1(.SS_n(SS_n),.SCLK(SCLK),.MISO(MISO),.MOSI(MOSI),.INT(INT));

initial begin
//default values
clk=1;
rst_n=0;
repeat(5)@(posedge clk);
rst_n=1;
//at posedge write data
wt_data=16'h8Fxx;
wrt=1;
repeat(5)@(posedge clk);
wrt=0;
repeat(300)@(posedge clk);

//cheching rd_datais equal to our desired value or not
if(rd_data===Finding_Nemo_Address)
	$display("Finanlly Found NEMO!");
else 
	$display("Bad Luck, I'm not NEMO (Device Not Found)");
	
//Changing write data
wt_data = 16'h0D02;
wrt=1;
repeat(5)@(posedge clk);
wrt=0;
repeat(300)@(posedge clk);

//Changing write data
wt_data = 16'h8Dxx;
wrt=1;
repeat(5)@(posedge clk);
wrt=0;
repeat(300)@(posedge clk);

if(rd_data===16'h0002)
	$display("Sucessful in writing data!");
else 
	$display("Sorry Better Luck Next Time!!! (Not Written)");

while(!INT) begin
@(posedge clk);
end
wait(INT);
$display("INT pin raised!");

/*Read Pitch value*/
//Changing write data
wt_data = 16'hA2xx;
wrt=1;
repeat(5)@(posedge clk);
wrt=0;
repeat(300)@(posedge clk);
if(rd_data===Pitch)
	$display("Finally! Correct Pitch value");

$stop();
end

always
#40 clk<=~clk;


endmodule