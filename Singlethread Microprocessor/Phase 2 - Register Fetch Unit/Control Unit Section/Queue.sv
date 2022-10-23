/*
	Arkanil
*/

module QUEUE (data_in, clock, freeze, /*halt_data_in, halt_data_out, */data_out);
	parameter length = 5, reg_width = 32, default_val = 'b0;
	
	input logic clock;
	input logic freeze;
	//input logic halt_data_in;
	//input logic halt_data_out;
	input logic [reg_width-1:0] data_in;
	
	output logic [reg_width-1:0] data_out;
	
	logic [length:0] [reg_width-1:0] qvars;
	logic [reg_width-1:0] default_value = default_val;
	
	assign data_out = qvars[length];
	
	//always @(posedge halt_data_in) qvars[0] = default_value;
	//always @(posedge halt_data_out) qvars[length] = default_value;
	
	always begin
		@(posedge clock);
		if (data_in[0]=='b0||data_in[0]=='b1) begin
			if (!freeze) begin
				#1 /*if (!halt_data_in)*/ qvars[0] = data_in;
				@(negedge clock);
				//if (halt_data_out=='b1) begin
				//	for (int i=length-1; i>0; i--) qvars [i] = qvars[i-1];
				//end
				//else begin
					for (int i=length; i>0; i--) qvars [i] = qvars[i-1];
				//end
			end
		end
	end
endmodule:QUEUE
