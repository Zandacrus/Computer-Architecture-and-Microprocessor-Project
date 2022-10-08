/*
	Arkanil
*/

module CHECK_INS (ins_in, clock, wait_for_next_in, reset, signal_out, ins_out, pc_choice_out, cu_enable_out, communication_enable_out, jump_out);
	
	parameter bus_width = 32, phases = 5;
	
	// ports
	input logic [bus_width-1:0] ins_in;
	input logic clock;
	input logic reset;
	input logic wait_for_next_in;
	output logic pc_choice_out;
	output logic communication_enable_out;
	output logic cu_enable_out;
	output logic jump_out;
	output logic [18:0] signal_out;
	output logic [bus_width-1:0] ins_out;
	
	logic [18:0] temp;
	
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
		communication_enable_out = 'b0;
		cu_enable_out = 'b0;
		jump_out = 'b0;
	end
	
	always begin 
		@(posedge clock);
		#3
		if (!wait_for_next_in) begin
			priority if (ins_in[bus_width-1:bus_width-6]=='b111111) begin
				unique0 if (ins_in[bus_width-7:bus_width-8]=='b10) begin
					// start
					signal_out = ins_in[bus_width-7:bus_width-25];
					pc_choice_out = 'b0;
					communication_enable_out = 'b1;
				end
				else if (ins_in[bus_width-7:bus_width-8]=='b11) begin
					// stop
					temp = ins_in[bus_width-7:bus_width-25];
					cu_enable_out = 'b0;
					signal_out = temp;
					communication_enable_out = 'b1;
					#2
					communication_enable_out = 'b0;
				end
				else if (ins_in[bus_width-7:bus_width-8]=='b00) begin
					// end
					signal_out = ins_in[bus_width-7:bus_width-25];
					communication_enable_out = 'b1;
				end
			end
			else if (ins_in[0]=='b0||ins_in[0]=='b1) begin
				if (!(cu_enable_out=='b1)) cu_enable_out = 'b1;
				ins_out = ins_in;
				if (communication_enable_out=='b1) communication_enable_out = 'b0;
				if (ins_in[bus_width-1:bus_width-6]=='b101010) begin
					#10 
					jump_out = 'b1;
					@(posedge clock);
					@(posedge clock);
					@(posedge clock);
					jump_out = 'b0;
				end
			end
			else begin end
		end
	end
	
endmodule:CHECK_INS