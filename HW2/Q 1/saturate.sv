module saturate(unsigned_err, signed_err, signed_D_diff, unsigned_err_sat, signed_err_sat, signed_D_diff_sat);

input [15:0] unsigned_err, signed_err;
input [9:0] signed_D_diff;

output reg [9:0] unsigned_err_sat, signed_err_sat;
output reg [6:0] signed_D_diff_sat;

initial begin

/*Saturating unsigned 16 bit number to 10 bit unsigned number which is the greater number represented by 10 bit*/
assign unsigned_err_sat=(unsigned_err[15]& ~unsigned_err[14:10]) ? 10'h3FF :unsigned_err[9:0];

/* Saturating 16 bit signed number to 10 bit signed number, here we are checking which
is the most obvious choice when it is neg and when it is positive*/
assign signed_err_sat=(!signed_err[15] & ~signed_err[14:9]) ? 10'h1FF :
			    (signed_err[15] & ~&signed_err[14:9]) ? 10'h200 :
			     signed_err[9:0];

/*Saturing 10 bit signed number to 7 bit signed number similar to last case*/
assign signed_D_diff_sat=(!signed_err[9] & ~signed_err[8:6]) ? 7'h3F :
				 (signed_err[9] & ~&signed_err[8:6]) ? 7'h40 :
				  signed_err[6:0];

end

endmodule 