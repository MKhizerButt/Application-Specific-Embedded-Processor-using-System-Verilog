// signed multiplier - utilises onboard DSP module
module signed_mult (
	output logic signed [15:0] product, 
	input logic signed [7:0] mult_in1, mult_in2
);

    assign product = (mult_in1 * mult_in2);

endmodule