//3'ABC A - Load Functions : BC - ALU FUNCTION (B also checks Immediate for ADDI)
`define NOP   3'b000 // NOP
`define MUL   3'b001 // MUL %d, %s;  %d = %d * %s
`define ADD   3'b010 // ADD %d, %s;  %d = %d + %s
`define BNE   3'b011 // BNE %d, %s, imm; PC = (%d!=%s? PC + imm : PC+1)
`define LW    3'b100 // Load word
`define LWW	  3'b101 // Load from Wave
`define ADDI  3'b110 // ADDI %d, %s, Imm;  %d = %s + Imm
`define LWG	  3'b111 // Load from Gaussain Kernel