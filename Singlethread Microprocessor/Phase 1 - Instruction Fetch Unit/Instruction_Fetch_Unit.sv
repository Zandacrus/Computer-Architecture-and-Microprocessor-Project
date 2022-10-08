/*
	Arkanil
*/

module INS_FETCH_UNIT (pc_in_0, pc_in_1, wait_for_next_in, clock, reset, freeze_in, freeze_out, npc_out, ins_out, communication_signal_out, cu_enable_out, communication_enable_out);
	
	parameter reg_width = 32, bus_width = 32, pc_increment = 1, phases = 5;
	
	import MEMORY::read_ins_address;
	
	// ports
	input logic [bus_width-1:0] pc_in_0;
	input logic [bus_width-1:0] pc_in_1;
	input logic clock;
	input logic reset;
	input logic wait_for_next_in;
	input logic freeze_in;
	
	output logic freeze_out;
	output logic cu_enable_out;
	output logic communication_enable_out;
	output logic [18:0] communication_signal_out;
	output logic [bus_width-1:0] npc_out;
	output logic [bus_width-1:0] ins_out;
	
	logic pc_choice_signal;
	logic reset_ins_checker;
	logic jump;
	logic [bus_width-1:0] pc_wire;
	logic [bus_width-1:0] ins_wire;
	logic [bus_width-1:0] im_wire;
	logic [reg_width-1:0] pc;
	logic [reg_width-1:0] npc;
	logic [reg_width-1:0] im;
	
	MUX #(bus_width) mux (.in_0(pc_in_0), .in_1(pc_in_1), .signal(pc_choice_signal), .out(pc_wire));
	
	CHECK_INS #(bus_width, phases) ins_checker (.ins_in(ins_wire), .clock(clock), .wait_for_next_in(wait_for_next_in), .reset(reset_ins_checker), 
												.ins_out(im_wire), .signal_out(communication_signal_out), .pc_choice_out(pc_choice_signal), 
												.cu_enable_out(cu_enable_out), .communication_enable_out(communication_enable_out), .jump_out(jump));
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
		freeze_out = 'b0;
	end
	
	always begin
		@(posedge clock);
		#2
		if ((pc_wire[0]=='b0)||(pc_wire[0]=='b1)) begin
			if (!(wait_for_next_in||jump)) begin
				pc = pc_wire;
				ins_wire = read_ins_address(pc);
				@(negedge clock);
				npc = pc+'b1;
			end
		end
	end
	
	always begin
		@(posedge clock);
		#4
		if ((im_wire[0]=='b0)||(im_wire[0]=='b1)) begin
			if (!freeze_in) begin
				@(negedge clock);
				#1
				im <= im_wire;
			end
		end
	end
	
	always begin
		@(posedge jump);
		freeze_out = 'b1;
		#3 freeze_out = 'b0;
	end
endmodule:INS_FETCH_UNIT
