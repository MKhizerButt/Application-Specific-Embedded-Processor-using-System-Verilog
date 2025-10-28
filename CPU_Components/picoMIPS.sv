module picoMIPS (
	input logic clk, 
	input logic [9:0] SW, 
	output logic [7:0] LED
); 
	
	cpu #(.n(8))	cpu(.clk(clk), .reset(SW[9]), .poll(SW[8]), .inport(SW[7:0]), .outport(LED));

endmodule
