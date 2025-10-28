module w_rom #(parameter D = 8, A =8) (
    input logic [A-1:0] addr,
    output logic [D-1:0] data
);
    
	// Load waveform data from hex file
	logic [D-1:0] rom [0:(1<<A)-1];

	initial 
		$readmemh("wave.hex", rom);

	assign data = rom[addr];
	
endmodule