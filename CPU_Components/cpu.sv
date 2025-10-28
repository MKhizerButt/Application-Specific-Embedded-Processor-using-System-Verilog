`include "alucodes.sv"
module cpu #( parameter n = 8) ( // data bus width
	input logic clk, reset, // Clock, Reset (SW9)
	input logic poll, // Polling Switch (SW8)
	input logic [n-1:0] inport, // Input Port (SW0~7)
	output logic [n-1:0] outport // LEDs (LED0~7)
);       

	// declarations of local signals that connect CPU modules
	// ALU
	logic [1:0] ALUfunc; // ALU function [2:0]
	logic flag; // ALU flag, routed to decoder
	logic imm; // immediate operand signal
	logic [n-1:0] Alub; // output from imm MUX
	logic [n-1:0] ALUres;
	//
	// Registers
	logic [n-1:0] Rdata1, Rdata2, Wdata; // Register data
	logic w; // register write control
	logic [n-1:0] Rout;
	//
	// Program Counter 
	parameter Psize = 5; // up to 32 instructions
	logic PCincr, PCrelbranch; // program counter control 
	logic [Psize-1 : 0] ProgAddress;
	// 
	// Program Memory
	parameter Isize = n+6; // Isize - instruction width (16-bits)
	logic [Isize-1:0] I; // I - instruction code
	//
	// Decoder
	logic w_in;  // Control for selection Wave Rom Output
	logic g_in;  // Control for selection Gaussian Kernel Rom Output
	//
	// ROM Data Output
	logic [7:0] wave_data, gaus_data; 

	// module instantiations
	pc  #(.Psize(Psize)) progCounter (.clk(clk), .reset(reset),
			.PCincr(PCincr),
			.PCrelbranch(PCrelbranch),
			.Branchaddr(I[Psize-1:0]), 
			.PCout(ProgAddress) );

	prog #(.Psize(Psize),.Isize(Isize)) progMemory (.address(ProgAddress), .I(I));

	decoder  D (.opcode(I[Isize-1:Isize-3]),
			.PCincr(PCincr),
			.PCrelbranch(PCrelbranch),
			.flag(flag), // ALU flag
			.ALUfunc(ALUfunc),.imm(imm),.w(w), 
			.w_in(w_in), .g_in(g_in));

	regs   #(.n(n))  gpr(.clk(clk),.w(w),
			.Wdata(Wdata),
			.Raddr2(I[Isize-4:Isize-6]), // reg %d number (3-bits : 8 Registers)
			.Raddr1(I[Isize-7:Isize-9]), // reg %s number (3-bits : 8 Registers)
			.inport(inport), // Input Port (SW0~7)
			.poll(poll), // Polling Switch (SW8)
			.Rdata1(Rdata1),.Rdata2(Rdata2),
			.Rout(Rout));

	alu    #(.n(n))  iu(.a(Rdata1), .b(Alub),
		   .func(ALUfunc), .flag(flag),
		   .result(ALUres)); // ALU result -> destination reg

	w_rom	#(.D(8),.A(8))	wave(.addr(Rdata1), .data(wave_data));
	g_rom 	#(.D(8), .A(3)) kernel (.addr(Rdata1[2:0]), .data(gaus_data)); //[2:0] as 5 MSB were dangling in the analysis and synthesis

	// MUX for immediate operand
	assign Alub = (imm ? {{3{I[n-4]}}, I[n-4:0]} : Rdata2); // 5-bit Immedaite with entended MSB/Sign Bit (n-4)

	// MUX for selection between Wave, Gaussain Kernel OR ALU Result
	always_comb begin
		case ({w_in, g_in})  // Concatenate the two control signals
			2'b10: Wdata = wave_data;    // w_in=1, g_in=0
			2'b01: Wdata = gaus_data;    // w_in=0, g_in=1
			default: Wdata = ALUres;     // default (w_in=0,g_in=0 or w_in=1,g_in=1)
		endcase
	end

	// Connects LEDs/Outport to Accumulator (Reg 5)
	assign outport = Rout;

endmodule