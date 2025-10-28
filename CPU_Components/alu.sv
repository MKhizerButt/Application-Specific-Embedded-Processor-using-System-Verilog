`include "alucodes.sv"  
module alu #(parameter n =8) (
	input logic [n-1:0] a, b, // ALU operands
	input logic [1:0] func, // ALU function code [1:0]
	output logic flag, // ALU flag Z
	output logic [n-1:0] result // ALU result
);       

	logic [n-1:0] ar,b1; // temp signals
	logic [15:0] product;

	// Signed Multiplier
	signed_mult mul (.product(product), .mult_in1(a), .mult_in2(b));

	always_comb
	begin
		if(func==`RSUB)
			b1 = ~b + 1'b1; // 2's complement subtrahend
		else 
			b1 = b;

		ar = a+b1; // n-bit adder
	end // always_comb
	   
	// create the ALU, use signal ar in arithmetic operations
	always_comb
	begin
		//default output values; prevent latches 
		flag = 1'b0;
		result = a; // default
		case(func)
			`RA : result = a;
			`RADD : result = ar; // arithmetic addition
			`RSUB : result = ar; // arithmetic subtraction 
			`RMUL : result = product[14:7]; // Extracting/Trucating Product 14:7 for Fixed-Point Arithmetic
		endcase

		// calculate flags Z
		flag = result == {n{1'b0}}; // Z

		end //always_comb

endmodule //end of module ALU	