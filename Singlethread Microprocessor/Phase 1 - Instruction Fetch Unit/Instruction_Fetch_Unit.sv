/*
	Arkanil
*/

module INS_FETCH_UNIT (pc_in_0, pc_in_1, wait_for_next_in, clock, reset, freeze, npc_out, ins_out, communication_signal_out, cu_enable_out, communication_enable_out);
	
	parameter reg_width = 32, bus_width = 32, pc_increment = 1, phases = 5;
	
	import MEMORY::read_address;
	
	// ports
	input logic [bus_width-1:0] pc_in_0;
	input logic [bus_width-1:0] pc_in_1;
	input logic clock;
	input logic reset;
	input logic wait_for_next_in;
	
	inout logic freeze;
	
	output logic cu_enable_out;
	output logic communication_enable_out;
	output logic [18:0] communication_signal_out;
	output logic [bus_width-1:0] npc_out;
	output logic [bus_width-1:0] ins_out;
	
	logic pc_choice_signal;
	logic reset_ins_checker;
	logic [bus_width-1:0] pc_wire;
	logic [bus_width-1:0] ins_wire;
	logic [bus_width-1:0] im_wire;
	logic [reg_width-1:0] pc;
	logic [reg_width-1:0] npc;
	logic [reg_width-1:0] im;
	
	MUX #(bus_width) mux (.in_0(pc_in_0), .in_1(pc_in_1), .signal(pc_choice_signal), .out(pc_wire));
	
	CHECK_INS #(bus_width, phases) ins_checker (.ins_in(ins_wire), .clock(clock), .wait_for_next_in(wait_for_next_in), .reset(reset_ins_checker), 
												.ins_out(im_wire), .signal_out(communication_signal_out), .pc_choice_out(pc_choice_signal), 
												.cu_enable_out(cu_enable_out), .communication_enable_out(communication_enable_out));
	//
	assign ins_out = im;
	assign npc_out = npc;
	
	/*
	always begin
		@(posedge reset);
		//wait_for_next_in <= 'b0;
		//pc_choice_signal = 'b1;
		//reset <= 'b0;
	end
	*/
	
	initial begin 
		//reset <= 'b1;
	end
	
	always begin
		@(posedge clock);
		
		if ((pc_wire[0]=='b0)||(pc_wire[0]=='b1)) begin
			if (!wait_for_next_in) begin
				#1
				pc = pc_wire;
				ins_wire = read_address(pc);
				npc = pc+'b1;
			end
		end
	end
	
	always begin
		@(posedge clock);
		#3
		if ((im_wire[0]=='b0)||(im_wire[0]=='b1)) begin
			if (!freeze) begin
				im <= im_wire;
			end
		end
	end
	
endmodule:INS_FETCH_UNIT
