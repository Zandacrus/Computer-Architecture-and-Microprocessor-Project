/*
	Arkanil
*/

module CHECK_INS (ins_in, clock, wait_for_next_in, reset, signal_out, ins_out, pc_choice_out, cu_enable_out, communication_enable_out);
	
	parameter bus_width = 32, phases = 5;
	
	// ports
	input logic [bus_width-1:0] ins_in;
	input logic clock;
	input logic reset;
	input logic wait_for_next_in;
	output logic pc_choice_out;
	output logic communication_enable_out;
	output logic cu_enable_out;
	output logic [18:0] signal_out;
	output logic [bus_width-1:0] ins_out;
	
	logic [bus_width-7:0] temp;
	
	/*
	always begin
		@(posedge reset);
		communication_enable_out = 'b1;
		cu_enable_out = 'b0;
		//reset <= 'b0;
	end
	*/
	
	initial begin 
		//reset <= 'b1;
		pc_choice_out = 'b1;
		communication_enable_out = 'b1;
		cu_enable_out = 'b0;
	end
	
	always begin 
		@(posedge clock);
		#2
		if (!wait_for_next_in) begin
			priority if (ins_in[bus_width-1:bus_width-6]=='b111111) begin
				unique0 if (ins_in[bus_width-7:bus_width-8]=='b10) begin
					// start
					signal_out = ins_in[bus_width-7:bus_width-25];
					pc_choice_out = 'b0;
				end
				else if (ins_in[bus_width-7:bus_width-8]=='b11) begin
					// stop
					temp = ins_in[bus_width-7:0];
					cu_enable_out = 'b0;
					@(posedge clock);
					@(posedge clock);
					@(posedge clock);
					@(posedge clock);
					@(posedge clock);
					communication_enable_out = 'b1;
					signal_out = temp;
				end
				else if (ins_in[bus_width-7:bus_width-8]=='b00) signal_out = ins_in[bus_width-7:0]; // end
			end
			else if (ins_in[bus_width-1]=='b0||ins_in[bus_width-1]=='b1) begin
				if (!(cu_enable_out=='b1)) cu_enable_out = 'b1;
				ins_out = ins_in;
				if (communication_enable_out=='b1) communication_enable_out = 'b0;
			end
			else begin end
		end
	end
	
endmodule:CHECK_INS