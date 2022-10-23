/*
	Arkanil
*/

module MUX (in_0, in_1, signal, out);
	
	parameter bus_width = 32;
	
	// ports
	input logic [bus_width-1:0] in_0;
	input logic [bus_width-1:0] in_1;
	input logic signal;
	output logic [bus_width-1:0] out;
	
	always begin
		#1
		unique0 if (signal=='b0) out <= in_0;
		else if (signal=='b1) out <= in_1;
	end
endmodule:MUX