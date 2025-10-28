module regs #(parameter n = 8) // n - data bus width
(input logic clk, w, // clk and write control
 input logic [n-1:0] Wdata,
 input logic [2:0] Raddr1, Raddr2,
 input logic poll, // (SW8)
 input logic [n-1:0] inport, // (SW0~7)
 output logic [n-1:0] Rdata1, Rdata2,
 output logic [n-1:0] Rout
 );

 	// Declare 8 n-bit registers 
	logic [n-1:0] gpr [7:0];

	
	// write process, dest reg is Raddr2
	always_ff @ (posedge clk)
	begin
		if (w)
            gpr[Raddr2] <= Wdata;

	end

	// read process, output 0 if %0, inport if %1, poll if %7
	always_comb
	begin
		case (Raddr1)
			3'd0 : Rdata1 =  {n{1'b0}};
			3'd1 : Rdata1 =  inport;
			3'd7 : Rdata1 =  poll;
			default : Rdata1 = gpr[Raddr1];
		endcase
	 
		case (Raddr2)
			3'd0 : Rdata2  =  {n{1'b0}};
			3'd1 : Rdata2  =  inport;
			3'd7 : Rdata2  =  poll;
			default : Rdata2 = gpr[Raddr2];
		endcase
	end	
	
	assign Rout = gpr[6]; //Accumulator is Reg 6
	

endmodule // module regs