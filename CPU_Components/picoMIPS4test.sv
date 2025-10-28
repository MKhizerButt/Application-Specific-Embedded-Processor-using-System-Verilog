// synthesise to run on Altera DE1 for testing and demo 
module picoMIPS4test ( 
	input logic fastclk,  // 50MHz Altera DE0 clock 
	input logic [9:0] SW, // Switches SW0..SW9 
	output logic [7:0] LED // LEDs 
);
	logic clk; // slow clock, about 10Hz 

	counter c (.fastclk(fastclk),.clk(clk)); // slow clk from counter 

	picoMIPS myDesign (.clk(clk), .SW(SW),.LED(LED)); 
endmodule  