`timescale 1ns / 1ps

module tb_picoMIPS;

    // Parameters
    parameter n = 8; // Data bus width

    // Signals
    logic clk;
    logic reset;
	logic poll;
    logic [n-1:0] inport;
    logic [n-1:0] outport;
	
	// Instantiate the picoMIPS
	picoMIPS uut (
	.clk(clk), 
	.SW({reset, poll, inport}), 
	.LED(outport)
	); 
    
	// Clock generation
    initial begin
        clk = 0;
        forever begin
		#5 clk = ~clk; // 10 time units clock period
        $display("Reset: %b | Inport: %h | Outport: %h | ProgAddress: %d", reset, inport, outport, uut.cpu.ProgAddress);
		$display("Instruction = %b, Opcode = %d", uut.cpu.I, uut.cpu.D.opcode);
		$display("Reg 1 = %d, Reg 2 = %d, Reg 3 = %d, Reg 4 = %d", uut.cpu.gpr.gpr[1], uut.cpu.gpr.gpr[2], uut.cpu.gpr.gpr[3], uut.cpu.gpr.gpr[4]);
		$display("Reg 5 = %d, Reg 6 = %d, Reg 7 = %d", uut.cpu.gpr.gpr[5], uut.cpu.gpr.gpr[6], uut.cpu.gpr.gpr[7]);
		$display("Flag = %b, PCincr = %b, PCrelbranch = %b", uut.cpu.flag, uut.cpu.PCincr, uut.cpu.PCrelbranch);
		end
    end

    // Test sequence
    initial begin
        // Initialize inputs
        reset = 1; // Assert reset
		poll = 0;
        inport = 8'h00; // Initial value for inport
		

        // Wait for a clock cycle
        #10;

        // Deassert reset
        reset = 0;
		
		#10 reset = 1;

        // Apply test vectors
        inport = 8'h06; // Sample Input
        #10; // Wait for a clock cycle
		#40; // Wait
		poll = 1;
    end
	
endmodule