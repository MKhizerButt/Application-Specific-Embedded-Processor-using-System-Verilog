module prog #(parameter Psize = 5, Isize = 14) ( // psize - address width, Isize - instruction width
	input logic [Psize-1:0] address,
	output logic [Isize-1:0] I // I - instruction code
);
	// program memory declaration, note: 1<<n is same as 2^n
	logic [Isize-1:0] progMem[(1<<Psize)-1:0];

	// get memory contents from file
	initial
		$readmemb("prog.bin", progMem); // hex/bin file is required to be in the ModelSim project folder
	  
	// program memory read 
	assign  I = progMem[address];
	  
endmodule // end of module prog