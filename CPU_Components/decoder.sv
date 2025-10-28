`include "alucodes.sv"
`include "opcodes.sv"
module decoder ( 
	input logic [2:0] opcode, // top 3 bits of instruction
	input flag, // ALU flag
	// PC control
	output logic PCincr, PCrelbranch, 
	//    ALU control
	output logic [1:0] ALUfunc, 
	// imm mux control
	output logic imm,
	//   register file control
	output logic w,
	//   Wave Data control
	output logic w_in,
	//   Kernel Data  control
	output logic g_in
);
   
	logic takeBranch; // temp variable to control conditional branching
	always_comb	begin
	
		// set default output signal values for NOP instruction
		PCincr = 1'b1; // PC increments by default
		PCrelbranch = 1'b0;
		ALUfunc = opcode[1:0]; 
		imm = 1'b0; 
		w = 1'b0; 
		w_in = 1'b0; 
		g_in = 1'b0; 
		takeBranch =  1'b0; 
	   
		case(opcode) // 3-bits - 8 Cases + Default
			`NOP: ;
			`ADD :	begin // Addition register-register 
				w = 1'b1; // write result to dest register
			end
			
			`ADDI:	begin // Addition register-immediate 
				w = 1'b1; // write result to dest register
				imm = 1'b1; // set ctrl signal for imm operand MUX
			end
			
			`BNE:	begin // Branch if not equal
				takeBranch = ~flag; // If z (flag) !=0
			end
			
			`LW:	begin //Load Value
				w = 1'b1; // Load to dest regiter
			end
			
			`LWW:	begin // Load from Wave ROM
				w = 1'b1; //Load to dest regiter
				w_in = 1'b1; // set ctrl signal for w_in, input to MUX
			end
			
			`LWG:	begin // Load from Gaussian Kernel ROM
				w = 1'b1; //Load to dest regiter
				g_in = 1'b1; // set ctrl signal for g_in, input to MUX
			end
			
			`MUL:	begin // register-register Multiplication 
				w = 1'b1; // write result to dest register
			end  
			
			default:
				$error("unimplemented opcode %b",opcode);	

		endcase // opcode
	  
	   if(takeBranch)	begin // if branch condition is true
		  PCincr = 1'b0; 
		  PCrelbranch = 1'b1; // Enable Relative Branching in PC
	   end
	   
	end // always_comb

endmodule //module decoder 