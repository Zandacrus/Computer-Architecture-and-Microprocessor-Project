/*
	Arkanil
*/

package REGISTERS;
	reg [28:0][31:0] registers; // 29 registers each of 32 bit
	reg [2:0][31:0] special_registers = '{3{32'b0}}; // 3 special registers each of 32 bit (zero(0), lo(1), hi(2))
	reg [30:0][2:0] state = '{31{3'b0}}; // state[i] represents whether register i is busy(>0) or not (0) 
	// max possible value of state[i] is 5 since it is a 5 stage pipelined architecture
	reg set_special_reg_state;
	
	function logic signed [31:0] read_reg_data (logic [4:0] reg_num);
		unique0 if (reg_num=='b0) return special_registers['b0]; // reg_num = 0 -> zero reg
		else if (reg_num>'d29) return special_registers[(reg_num-'d29)]; // reg_num = 30 -> lo reg, reg_num = 31 -> hi reg
		else return registers[(reg_num-'b1)];
	endfunction
	
	function logic [2:0] read_reg_state (logic [4:0] reg_num);
		if (reg_num>'b0) return state[(reg_num-'b1)];
		else return 3'b0;
	endfunction
	
	function void set_reg_state(logic [4:0] reg_num);
		if (reg_num>'b0&&reg_num<'d30) state[(reg_num-'b1)] += 'b1;
		else if (reg_num>'d29&&set_special_reg_state) begin
			state[(reg_num-'b1)] += 'b1;
			set_special_reg_state = 'b0;
		end
	endfunction
	
	function void write_reg_data (logic [4:0] reg_num, logic [31:0] data);
		if ((reg_num>'b0)&&(reg_num<'d30)) begin
			registers[(reg_num-'b1)] = data;
			state[(reg_num-'b1)] -= 'b1;
		end
	endfunction
	
	function void write_lo_reg (logic [31:0] data);
		special_registers['d1] = data;
		state['d29] -= 'b1;
	endfunction
	
	function void write_hi_reg (logic [31:0] data);
		special_registers['d2] = data;
		state['d30] -= 'b1;
	endfunction
	
	task display_regs ();
		begin
			$write("Registers: ");
			foreach(registers[i]) $write("Reg %0d = %0d (%b) [state = %0d], ", i+1, read_reg_data(i+1), read_reg_data(i+1), read_reg_state(i+1));
			$write("\nSpecial registers: ");
			$write("Zero reg = %0d (%b) [state = %0d], ", read_reg_data(0), read_reg_data(0), read_reg_state(0));
			$write("Lo reg = %0d (%b) [state = %0d], ", read_reg_data(30), read_reg_data(30), read_reg_state(30));
			$display("Hi reg = %0d (%b) [state = %0d]", read_reg_data(31), read_reg_data(31), read_reg_state(31));
		end
	endtask
endpackage

/*
	Arkanil
*/

package MEMORY;
	reg [(256*1024)-1:0][31:0] memory; // 1 MB 
	
	reg [31:0] data_memory_start = 16*1024; // leaving 64 KB for instruction memory
	
	// INSTRUCTION MEMORY
	function logic [31:0] read_ins_address (logic [31:0] address);
		return memory[address];
	endfunction
	
	function void write_ins_data (logic [31:0] address, logic [31:0] data);
		memory[address] = data;
	endfunction
	
	// DATA MEMORY
	function logic [31:0] read_address (logic [31:0] address);
		return memory[(data_memory_start+address)];
	endfunction
	
	function void write_data (logic [31:0] address, logic [31:0] data);
		memory[(data_memory_start+address)] = data;
	endfunction
	
endpackage

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
      	#2
		if (data_in[0]=='b0||data_in[0]=='b1) begin
			if (!freeze) begin
				/*if (!halt_data_in)*/ qvars[0] = data_in;
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

/*
	Arkanil
*/

module COMMUNICATION_UNIT(clock, enable_in, initial_pc_in, ins_signal_in, signal_in, initial_pc_out, wait_for_next_out, signal_out, end_signal_out);
	
	parameter bus_width = 32, reg_width = 32;
	
	input logic clock, enable_in;
  	input logic [bus_width-1:0] initial_pc_in;
	input logic [18:0] ins_signal_in;
	input logic [15:0] signal_in;
	
	output logic [reg_width-1:0] initial_pc_out;
	output logic wait_for_next_out;
	output logic [15:0] signal_out;
	output logic end_signal_out;
	
	logic [18:0] ins_signal;
	logic [reg_width-1:0] initial_pc;
	bit time_pass;
	
	assign initial_pc_out = initial_pc;
	
	initial begin
		
		wait_for_next_out <= 'b1;
		end_signal_out <= 'b1;
		@(initial_pc_in);
		#1
		initial_pc <= initial_pc_in;
		end_signal_out <= 'b0;
		wait_for_next_out <= 'b0;
	end
	
	always begin
		// @(negedge clock) #5
		@(posedge enable_in);
		ins_signal = ins_signal_in;
		unique if (ins_signal[18:17]=='b10) begin // START
			unique if (ins_signal[16]=='b0) begin // INDEPENDENT
				wait_for_next_out <= 'b0; // Do nothing
			end
			else if (ins_signal[16]=='b1) begin // DEPENDENT
				wait_for_next_out <= 'b1;
				while(signal_in!=ins_signal[15:0]) begin
					#1 time_pass <= 1; // Do nothing
				end
				wait_for_next_out <= 'b0;
			end
		end
		else if (ins_signal[18:17]=='b11) begin // STOP
			wait_for_next_out <= 'b1;
			// Wait for all phases to freeze
			@(negedge clock);
			@(negedge clock);
			@(negedge clock);
			signal_out <= ins_signal;
			wait_for_next_out <= 'b0;
		end
		else if (ins_signal[18:17]=='b00) begin // END
			wait_for_next_out <= 'b1;
			// Wait for all phases to freeze
			@(negedge clock);
			@(negedge clock);
			@(negedge clock);
			signal_out <= ins_signal;
          	#7
			end_signal_out <= 'b1;
		end
		
	end
	
endmodule:COMMUNICATION_UNIT

/*
	Arkanil
*/

module CHECK_INS (ins_in, clock, wait_for_next_in, signal_out, ins_out, pc_choice_out, cu_enable_out, communication_enable_out);
	
	parameter bus_width = 32;
	
	// ports
	input logic [bus_width-1:0] ins_in;
	input logic clock;
	input logic wait_for_next_in;
	output logic pc_choice_out;
	output logic communication_enable_out;
	output logic cu_enable_out;
	output logic [18:0] signal_out;
	output logic [bus_width-1:0] ins_out;
	
	logic [18:0] temp;
	
	initial begin 
		pc_choice_out = 'b1;
		communication_enable_out = 'b0;
		cu_enable_out = 'b0;
	end
	
	always begin 
		@(posedge clock);
		@(negedge clock);
		#5
		if (!wait_for_next_in) begin
			priority if (ins_in[bus_width-1:bus_width-6]=='b111111) begin
				unique0 if (ins_in[bus_width-7:bus_width-8]=='b10) begin
					// start
					signal_out = ins_in[bus_width-7:bus_width-25];
					pc_choice_out = 'b0;
					communication_enable_out = 'b1;
					#2
					communication_enable_out = 'b0;
				end
				else if (ins_in[bus_width-7:bus_width-8]=='b11||ins_in[bus_width-7:bus_width-8]=='b00) begin
					// stop/end
					cu_enable_out = 'b0;
					signal_out = ins_in[bus_width-7:bus_width-25];
					communication_enable_out = 'b1;
					#2
					communication_enable_out = 'b0;
				end
			end
			else if (ins_in[0]=='b0||ins_in[0]=='b1) begin
				if (!(cu_enable_out=='b1)) cu_enable_out = 'b1;
				ins_out = ins_in;
				if (communication_enable_out=='b1) communication_enable_out = 'b0;
			end
			else begin end
		end
	end
	
endmodule:CHECK_INS

/*
	Arkanil
*/

module INS_FETCH_UNIT (pc_in_0, pc_in_1, wait_for_next_in, clock, freeze_in, freeze_pc_in, npc_out, ins_out, communication_signal_out, cu_enable_out, communication_enable_out);
	
	parameter reg_width = 32, bus_width = 32, pc_increment = 'b1, phases = 5;
	
	import MEMORY::read_ins_address;
	
	// ports
	input logic [bus_width-1:0] pc_in_0;
	input logic [bus_width-1:0] pc_in_1;
	input logic clock;
	input logic wait_for_next_in;
	input logic freeze_in;
	input logic freeze_pc_in;
	
	output logic cu_enable_out;
	output logic communication_enable_out;
	output logic [18:0] communication_signal_out;
	output logic [bus_width-1:0] npc_out;
	output logic [bus_width-1:0] ins_out;
	
	logic pc_choice_signal;
	logic [bus_width-1:0] pc_wire;
	logic [bus_width-1:0] ins_wire;
	logic [bus_width-1:0] im_wire;
	logic [reg_width-1:0] pc;
	logic [reg_width-1:0] npc;
	logic [reg_width-1:0] im;
	wor ins_checker_wait;
	
	MUX #(bus_width) mux (.in_0(pc_in_0), .in_1(pc_in_1), .signal(pc_choice_signal), .out(pc_wire));
	
	CHECK_INS #(bus_width) ins_checker (.ins_in(ins_wire), .clock(clock), .wait_for_next_in(wait_for_next_in|freeze_pc_in),
												.ins_out(im_wire), .signal_out(communication_signal_out), .pc_choice_out(pc_choice_signal), 
												.cu_enable_out(cu_enable_out), .communication_enable_out(communication_enable_out));
	//
	assign ins_out = im;
	assign npc_out = npc;
	
	initial begin 
		
	end
	
	always begin
		@(posedge clock);
		#2
		if ((pc_wire[0]=='b0)||(pc_wire[0]=='b1)) begin
			if (!(wait_for_next_in||freeze_pc_in)) begin
				pc = pc_wire;
				ins_wire = read_ins_address(pc);
				@(negedge clock);
				#2 npc = pc+pc_increment;
			end
		end
	end
	
	always begin
		@(posedge clock);
		@(negedge clock);
      	#6
		if ((im_wire[0]=='b0)||(im_wire[0]=='b1)) begin
			if (!freeze_in) begin
				im <= im_wire;
			end
		end
	end
	
endmodule:INS_FETCH_UNIT

/*
	Arkanil
*/

module CONTROL_UNIT (OpCode_in, enable_in, clock, branch_taken_in, read_data_1_out, read_data_2_out, engage_reg_out, ALUOp_out, BUOp_out, alu_ignore_overflow_out, mem_read_out, mem_write_out, write_back_out, write_special_reg_out,
					// FREEZE INs
					reg_fetch_freeze_in,
					// FREEZE OUTs
					ins_fetch_freeze_out, freeze_pc_out, reg_fetch_freeze_out, sign_extend_freeze_out, alu_control_freeze_out, bu_freeze_out, alu_freeze_out, npc_freeze_out, data_mem_freeze_out, write_back_freeze_out, 
					// MUX Signals
					write_reg_mux_out, sign_extend_mux_out, alu_mux_1_out, alu_mux_2_out, write_back_mux_out
					);
	import REGISTERS::set_special_reg_state;
	
	input logic clock;
	input logic enable_in;
	input logic branch_taken_in;
	input logic reg_fetch_freeze_in;
	input logic [5:0] OpCode_in;
	
	output logic mem_read_out;
	output logic mem_write_out;
	output logic write_back_out;
	output logic ins_fetch_freeze_out;
	output logic freeze_pc_out;
	output logic read_data_1_out;
	output logic read_data_2_out;
	output logic engage_reg_out;
	output logic reg_fetch_freeze_out;
	output logic sign_extend_freeze_out;
	output logic alu_control_freeze_out;
	output logic bu_freeze_out;
	output logic alu_freeze_out;
	output logic npc_freeze_out;
	output logic data_mem_freeze_out;
	output logic write_back_freeze_out;
	output logic write_reg_mux_out;
	output logic write_special_reg_out;
	output logic sign_extend_mux_out;
	output logic alu_mux_1_out;
	output logic alu_mux_2_out;
	output logic alu_ignore_overflow_out;
	output logic write_back_mux_out;
	output logic [3:0] ALUOp_out;
	output logic [2:0] BUOp_out;
	
	logic freeze;
	logic branch_hazard;
	logic read_after_write_hazard;
	
	logic [5:0] OpCode;
	logic [3:0] ALUOp;
	logic [2:0] BUOp;
	logic write_back;
	logic write_special_reg;
	logic mem_read;
	logic mem_write;
	logic alu_mux_1_signal;
	logic alu_mux_2_signal;
	logic alu_ignore_overflow;
	logic write_back_mux_signal;
	
	assign ALUOp_out = ALUOp;
	
	logic branch_q_freeze;
	logic alu_mux_1_q_freeze;
	logic alu_mux_2_q_freeze;
	logic alu_ignore_overflow_q_freeze;
	logic mem_read_q_freeze;
	logic mem_write_q_freeze;
	logic write_back_mux_q_freeze;
	logic write_special_reg_q_freeze;
	logic write_back_q_freeze;
	
	// logic branch_q_halt_data_in;
	// logic alu_mux_1_q_halt_data_in;
	// logic alu_mux_2_q_halt_data_in;
	// logic alu_ignore_overflow_q_halt_data_in;
	// logic mem_read_q_halt_data_in;
	// logic mem_write_q_halt_data_in;
	// logic write_back_mux_q_halt_data_in;
	// logic write_special_reg_q_halt_data_in;
	// logic write_back_q_halt_data_in;
	
	// logic branch_q_halt_data_out;
	// logic alu_mux_1_q_halt_data_out;
	// logic alu_mux_2_q_halt_data_out;
	// logic alu_ignore_overflow_q_halt_data_out;
	// logic mem_read_q_halt_data_out;
	// logic mem_write_q_halt_data_out;
	// logic write_back_mux_q_halt_data_out;
	// logic write_special_reg_q_halt_data_out;
	// logic write_back_q_halt_data_out;
	
	QUEUE #(1, 3) BUOp_q (.data_in(BUOp), .clock(clock), .freeze(branch_q_freeze), /*.halt_data_in(branch_q_halt_data_in), .halt_data_out(branch_q_halt_data_out), */.data_out(BUOp_out));
	QUEUE #(1, 1) alu_mux_1_q (.data_in(alu_mux_1_signal), .clock(clock), .freeze(alu_mux_1_q_freeze), /*.halt_data_in(alu_mux_1_q_halt_data_in), .halt_data_out(alu_mux_1_q_halt_data_out), */.data_out(alu_mux_1_out));
	QUEUE #(1, 1) alu_mux_2_q (.data_in(alu_mux_2_signal), .clock(clock), .freeze(alu_mux_2_q_freeze), /*.halt_data_in(alu_mux_2_q_halt_data_in), .halt_data_out(alu_mux_2_q_halt_data_out), */.data_out(alu_mux_2_out));
	QUEUE #(2, 1) alu_ignore_overflow_q (.data_in(alu_ignore_overflow), .clock(clock), .freeze(alu_ignore_overflow_q_freeze), /*.halt_data_in(alu_ignore_overflow_q_halt_data_in), .halt_data_out(alu_ignore_overflow_q_halt_data_out), */.data_out(alu_ignore_overflow_out));
	QUEUE #(3, 1) mem_read_q (.data_in(mem_read), .clock(clock), .freeze(mem_read_q_freeze), /*.halt_data_in(mem_read_q_halt_data_in), .halt_data_out(mem_read_q_halt_data_out), */.data_out(mem_read_out));
	QUEUE #(3, 1) mem_write_q (.data_in(mem_write), .clock(clock), .freeze(mem_write_q_freeze), /*.halt_data_in(mem_write_q_halt_data_in), .halt_data_out(mem_write_q_halt_data_out), */.data_out(mem_write_out));
	QUEUE #(3, 1) write_back_mux_q (.data_in(write_back_mux_signal), .clock(clock), .freeze(write_back_mux_q_freeze), /*.halt_data_in(write_back_mux_q_halt_data_in), .halt_data_out(write_back_mux_q_halt_data_out), */.data_out(write_back_mux_out));
	QUEUE #(4, 1) write_special_reg_q (.data_in(write_special_reg), .clock(clock), .freeze(write_special_reg_q_freeze), /*.halt_data_in(write_special_reg_q_halt_data_in), .halt_data_out(write_special_reg_q_halt_data_out), */.data_out(write_special_reg_out));
	QUEUE #(4, 1) write_back_q (.data_in(write_back), .clock(clock), .freeze(write_back_q_freeze), /*.halt_data_in(write_back_q_halt_data_in), .halt_data_out(write_back_q_halt_data_out), */.data_out(write_back_out));
	
	function void set_signals (bit [19:0] sig);
		// PHASE 2
		read_data_1_out <= sig[19];
		read_data_2_out <= sig[18];
		unique if (branch_hazard=='b0) engage_reg_out <= sig[17];
		else if (branch_hazard=='b1) engage_reg_out<= 'b0;
		write_reg_mux_out <= sig[16];
		sign_extend_mux_out <= sig[15];
		ALUOp <= sig[14:11];
		// PHASE 3
		BUOp <= sig[10:8];
		alu_mux_1_signal <= sig[7];
		alu_mux_2_signal <= sig[6];
		alu_ignore_overflow <= sig[5];
		// PHASE 4
		mem_read <= sig[4];
		mem_write <= sig[3];
		// PHASE 5
		write_back_mux_signal <= sig[2];
		write_back <= sig[1];
		write_special_reg <= sig[0];
      	if (!branch_hazard) set_special_reg_state <= sig[0];
	endfunction
	
	// INITIAL
	initial begin
		freeze <= 'b1;
		branch_hazard <= 'b0;
		read_after_write_hazard <= 'b0;
		freeze_pc_out <= 'b0;
		ins_fetch_freeze_out <= 'b1;
		alu_control_freeze_out <= 'b1;
		sign_extend_freeze_out <= 'b1;
		reg_fetch_freeze_out <= 'b1;
		bu_freeze_out <= 'b1;
		alu_freeze_out <= 'b1;
		data_mem_freeze_out <= 'b1;
		write_back_freeze_out <= 'b1;
		npc_freeze_out <= 'b0;
	end
	
	// CU FREEZE
	always begin
		@(posedge freeze);
		branch_q_freeze <= 'b1;
		alu_mux_1_q_freeze <= 'b1;
		alu_mux_2_q_freeze <= 'b1;
		alu_ignore_overflow_q_freeze <= 'b1;
		mem_read_q_freeze <= 'b1;
		mem_write_q_freeze <= 'b1;
		write_back_mux_q_freeze <= 'b1;
		write_special_reg_q_freeze <= 'b1;
		write_back_q_freeze <= 'b1;	
	end
	
	always begin
		@(posedge freeze);
		@(negedge freeze);
		branch_q_freeze <= 'b0;
		alu_mux_1_q_freeze <= 'b0;
		alu_mux_2_q_freeze <= 'b0;
		alu_ignore_overflow_q_freeze <= 'b0;
		mem_read_q_freeze <= 'b0;
		mem_write_q_freeze <= 'b0;
		write_back_mux_q_freeze <= 'b0;
		write_special_reg_q_freeze <= 'b0;
		write_back_q_freeze <= 'b0;	
	end
	
	// ENABLE
	always begin
		// @(negedge clock) #5
		@(posedge enable_in);
		
		// PHASE 1
		ins_fetch_freeze_out <= 'b0;
		npc_freeze_out <= 'b0;
		
		// PHASE 2
		#1
		freeze <= 'b0;
		reg_fetch_freeze_out <= 'b0;
		sign_extend_freeze_out <= 'b0;
		alu_control_freeze_out <= 'b0;
		
		// PHASE 3
		@(negedge clock);
		#6
		bu_freeze_out <= 'b0;
		alu_freeze_out <= 'b0;
		
		
		// PHASE 4
		@(negedge clock);
		#6
		data_mem_freeze_out <= 'b0;
		
		// PHASE 5
		@(negedge clock);
		#6
		write_back_freeze_out <= 'b0;
	end
	
	// DISABLE
	always begin
		@(posedge clock);
		// @(negedge clock) #5
		@(negedge enable_in);
		#1
		// PHASE 1
		ins_fetch_freeze_out <= 'b1;
		npc_freeze_out <= 'b1;
		
		// PHASE 2
		freeze <= 'b1;
		reg_fetch_freeze_out <= 'b1;
		sign_extend_freeze_out <= 'b1;
		alu_control_freeze_out <= 'b1;
		
		// PHASE 3
		@(negedge clock);
		#6
		bu_freeze_out <= 'b1;
		alu_freeze_out <= 'b1;
		
		// PHASE 4
		@(negedge clock);
		#6
		data_mem_freeze_out <= 'b1;
		
		// PHASE 5
		@(negedge clock);
		#6
		write_back_freeze_out <= 'b1;
	end
	
	// BRANCH HAZARD
	always begin
		@(posedge branch_taken_in);
		branch_hazard <= 'b1;
		engage_reg_out <= 'b0;
		@(negedge clock);
		@(negedge clock);
		branch_hazard <= 'b0;
	end
	
	always begin
		@(posedge branch_hazard);
		//if (read_after_write_hazard=='b1) 
		read_after_write_hazard <= 'b0;
		// PHASE 3
		#5
		bu_freeze_out <= 'b1;
		alu_freeze_out <= 'b1;
		@(negedge clock);
		// PHASE 4
		#5
		data_mem_freeze_out <= 'b1;
		@(negedge clock);
		//PHASE 5
		#5
		write_back_freeze_out <= 'b1;
	end
	
	always begin
		@(posedge clock);
		@(negedge branch_hazard);
		// PHASE 3
		#5
		bu_freeze_out <= 'b0;
		alu_freeze_out <= 'b0;
		@(negedge clock);
		// PHASE 4
		#5
		data_mem_freeze_out <= 'b0;
		@(negedge clock);
		//PHASE 5
		#5
		write_back_freeze_out <= 'b0;
	end
	
	// READ AFTER WRITE HAZARD
	always begin
		@(posedge reg_fetch_freeze_in);
		if (branch_hazard=='b0) read_after_write_hazard <= 'b1;
		@(negedge reg_fetch_freeze_in);
		read_after_write_hazard <= 'b0;
	end
	
	always begin
		@(posedge read_after_write_hazard);
		reg_fetch_freeze_out <= 'b1;
      	sign_extend_freeze_out <= 'b1;
      	alu_control_freeze_out <= 'b1;
		#3
		freeze_pc_out <= 'b1;
		ins_fetch_freeze_out <= 'b1;
		npc_freeze_out <= 'b1;
		// PHASE 3
		@(negedge clock);
		#3
		bu_freeze_out <= 'b1;
		alu_freeze_out <= 'b1;
		// PHASE 4
		@(negedge clock);
		#3
		data_mem_freeze_out <= 'b1;
		// PHASE 5
		@(negedge clock);
		#3
		write_back_freeze_out <= 'b1;
	end
	
	always begin
		@(posedge clock);
		@(negedge read_after_write_hazard);
		reg_fetch_freeze_out <= 'b0;
      	sign_extend_freeze_out <= 'b0;
      	alu_control_freeze_out <= 'b0;
		freeze_pc_out <= 'b0;
		ins_fetch_freeze_out <= 'b0;
		npc_freeze_out <= 'b0;
		// PHASE 3
		#4
		bu_freeze_out <= 'b0;
		alu_freeze_out <= 'b0;
		// PHASE 4
		@(negedge clock);
		#4
		data_mem_freeze_out <= 'b0;
		// PHASE 5
		@(negedge clock);
		#4
		write_back_freeze_out <= 'b0;
	end
	
	// SENDING SIGNALS
	always begin
		@(posedge clock);
		if (!freeze) begin
			if (OpCode_in[0]=='b0||OpCode_in[0]=='b1) begin
				OpCode = OpCode_in;
				unique case (OpCode)
				// Reg Mem Type
				'b000000: // lw
					set_signals(20'b1_0_1_0_1_0001_000_1_1_0_1_0_0_1_0);
				'b000001: // sw
					set_signals('b1_0_0_0_1_0001_000_1_1_0_0_1_0_0_0);
				// Branch Jump Type
				'b000010: // j
					set_signals('b0_0_0_1_0_0001_001_0_1_0_0_0_1_0_0);
				'b000011: // jr
					set_signals('b0_1_0_1_1_0001_001_0_0_0_0_0_1_0_0);
				'b000100: // beq
					set_signals('b1_1_0_1_1_0001_100_0_1_0_0_0_1_0_0);
				'b000101: // bne
					set_signals('b1_1_0_1_1_0001_101_0_1_0_0_0_1_0_0);
				'b000110: // bgt
					set_signals('b1_1_0_1_1_0001_110_0_1_0_0_0_1_0_0);
				'b000111: // blt
					set_signals('b1_1_0_1_1_0001_111_0_1_0_0_0_1_0_0);
				// Special Reg Type
				'b001000: // mfhi, mflo
					set_signals('b1_1_1_1_1_0000_000_1_0_0_0_0_1_0_0);
				'b001001: // mtlo, mthi
					set_signals('b1_1_1_1_1_0000_000_1_0_0_0_0_1_1_1);
				// Reg Reg Type (detects overflow)
				'b010000:
					set_signals('b1_1_1_1_1_0000_000_1_0_0_0_0_1_1_0);
				// Reg Immediate Type
				'b010001: // addi
					set_signals('b1_0_1_0_1_0001_000_1_1_0_0_0_1_1_0);
				'b010010: // subi
					set_signals('b1_0_1_0_1_0010_000_1_1_0_0_0_1_1_0);
				'b010011: // muli
					set_signals('b1_0_1_0_1_0011_000_1_1_0_0_0_1_1_0);
				'b010100: // divi
					set_signals('b1_0_1_0_1_0100_000_1_1_0_0_0_1_1_0);
				'b010101: // andi
					set_signals('b1_0_1_0_1_0101_000_1_1_0_0_0_1_1_0);
				'b010110: // ori
					set_signals('b1_0_1_0_1_0110_000_1_1_0_0_0_1_1_0);
				'b010111: // nandi
					set_signals('b1_0_1_0_1_0111_000_1_1_0_0_0_1_1_0);
				'b011000: // nori
					set_signals('b1_0_1_0_1_1000_000_1_1_0_0_0_1_1_0);
				'b011001: // xori
					set_signals('b1_0_1_0_1_1001_000_1_1_0_0_0_1_1_0);
				'b011010: // slti
					set_signals('b1_0_1_0_1_1010_000_1_1_0_0_0_1_1_0);
				'b011011: // sgti
					set_signals('b1_0_1_0_1_1011_000_1_1_0_0_0_1_1_0);
				'b011100: // slli
					set_signals('b1_0_1_0_1_1100_000_1_1_0_0_0_1_1_0);
				'b011101: // srli
					set_signals('b1_0_1_0_1_1101_000_1_1_0_0_0_1_1_0);
				'b011110: // slai
					set_signals('b1_0_1_0_1_1110_000_1_1_0_0_0_1_1_0);
				'b011111: // srai
					set_signals('b1_0_1_0_1_1111_000_1_1_0_0_0_1_1_0);
				// Reg Reg Type (ignores overflow)
				'b110000:
					set_signals('b1_1_1_1_1_0000_000_1_0_1_0_0_1_1_0);
				endcase
			end
		end
	end
	
endmodule:CONTROL_UNIT

// Swayam Pal

module REG_FETCH_UNIT(read_data1_in,read_data2_in,read_data3_in,clk,read_data1_out,read_data2_out,write_reg_out,mux_signal,rd1_signal,rd2_signal,freeze_in,freeze_out,engage_reg_in);

import REGISTERS::read_reg_data,REGISTERS::read_reg_state,REGISTERS::set_reg_state;

  input logic[4:0] read_data1_in;
  input logic[4:0] read_data2_in;
  input logic[4:0] read_data3_in;
  input logic clk;
  input logic mux_signal;
  input logic rd1_signal;
  input logic rd2_signal;
  input logic freeze_in;
  input logic engage_reg_in;

  output logic freeze_out;
  output logic[4:0] write_reg_out;
  output logic[31:0] read_data1_out;
  output logic[31:0] read_data2_out;
  
  logic no_use = 'b0,Cq_freeze = 'b0;
  logic[4:0] write_reg_in;
  MUX #(5) mux(.in_0(read_data2_in),.in_1(read_data3_in),.out(write_reg_in),.signal(mux_signal));
  QUEUE #(3,5,0) write_reg_no_q(.data_in(write_reg_in),.data_out(write_reg_out),.clock(clk),/*.halt_data_in(no_use),*/.freeze(Cq_freeze));

  logic[4:0] reg1_in,reg2_in,reg3_in;
  logic[31:0] reg1_out,reg2_out;

  initial begin
    freeze_out = 0;
  end

  always  begin
    @(posedge clk);
    @(negedge clk);
    #4

    if(!freeze_in) begin
      reg1_out = read_reg_data(reg1_in);
      reg2_out = read_reg_data(reg2_in);
      if(engage_reg_in == 'b1) begin
        set_reg_state(write_reg_in);
      end
    end
    
  end
 
  
  always @(posedge clk) begin
    #3
    if(!freeze_in) begin
      reg1_in = read_data1_in;
      reg2_in = read_data2_in;
      reg3_in = read_data3_in;
      if(rd1_signal) begin
        if(read_reg_state(reg1_in)>'b0) begin
          freeze_out = 'b1;
        end
      end
      if(rd2_signal) begin
        if(read_reg_state(reg2_in)>'b0) begin
          freeze_out = 'b1;
        end
      end
      
    end
      

    
  end


  always begin
    
    #1
    if(freeze_out == 'b1) begin
      if((read_reg_state(reg1_in) == 'b0)&&(read_reg_state(reg2_in) == 'b0)) begin
        freeze_out = 'b0;
      end

    end
  end

    
  
  assign read_data1_out = reg1_out;
  assign read_data2_out = reg2_out;
endmodule

// Swayam Pal

module SIGNED_EXTENSION(bit26_ins_in,mux_signal,bit32_ext,freeze_in,clk);

input logic[25:0] bit26_ins_in;
input logic mux_signal;
input logic freeze_in;
input logic clk;
output logic signed [31:0] bit32_ext;


logic [25:0] bit26_ins;
logic[14:0] bit15_ins;
logic bit1_ins;
logic[9:0] bit101_ins;
logic[9:0] bit102_ins;

logic[9:0] output_value_mux;
logic[25:0] output_value_mid;
logic signed [31:0] output_value_final;

always @(posedge clk) begin
    #3
    if(!freeze_in) begin
        bit26_ins = bit26_ins_in;
        bit15_ins = bit26_ins[14:0];
        bit1_ins = bit26_ins[15];
        
      unique0 if(bit1_ins == 'b1) bit101_ins = 'b1111111111;
      else if(bit1_ins == 'b0) bit101_ins = 'b0000000000;

        bit102_ins = bit26_ins[25:16];
    end
end

MUX #(10) mux(.in_0(bit102_ins),.in_1(bit101_ins),.out(output_value_mux),.signal(mux_signal));

 assign output_value_mid[14:0] = bit15_ins;
 assign output_value_mid[15] = bit1_ins;
 assign output_value_mid[25:16] = output_value_mux;

always begin
    @(posedge clk);
    @(negedge clk);
    #4
  if(!freeze_in) begin
    output_value_final[25:0] = output_value_mid;
    output_value_final[31:26] = '{6{output_value_mid[25]}};
  end
  
end

  assign bit32_ext = output_value_final;


endmodule

//Swayam Pal

module CONTROL_UNIT_ALU(funct_field_in,Alu_op_in,clk,Alu_cs_op,freeze_in);
  
  import REGISTERS::set_special_reg_state, REGISTERS::set_reg_state;
  
  input logic[5:0] funct_field_in;
  input logic[3:0] Alu_op_in;
  input logic clk;
  input logic freeze_in;
  output logic[3:0] Alu_cs_op;
  
  reg[3:0] Alu_op,output_signal;
  reg[5:0] funct_field;
  logic set_special_regs_state = 'b0;
  
  always @(posedge clk) begin
    #3
    if(!freeze_in) begin
      Alu_op <= Alu_op_in;
      funct_field <= funct_field_in;
    end
  end
  
  always begin
	@(posedge clk);
	@(negedge clk);
      #4
      if(!freeze_in)begin
        unique if(Alu_op == 'b0000) 
          output_signal = funct_field[3:0];
        else
          output_signal = Alu_op;
		
		if (output_signal=='b0011||output_signal=='b0100) begin // For multiplication & division hi, lo is written
			set_special_regs_state <= 'b1;
		end
      end   
  end
  
  always begin
	@(posedge set_special_regs_state);
	set_special_regs_state <= 'b0;
	@(posedge clk);
	#7
	set_special_reg_state = 'b1;
	#1
	set_reg_state('d30); // lo
	#1
	set_special_reg_state = 'b1;
	#1
	set_reg_state('d31); // hi
  end
  
  assign Alu_cs_op = output_signal;
endmodule

//Manisha

module ARITHMETIC_AND_LOGIC_UNIT(clock, inp1, inp2,isImmediate,notBUOp, immx,npc, ALUControl,overFlow, zero, ALUResult, unsigned_operation, freeze);

input logic clock, freeze;
input logic unsigned_operation;
input logic signed [31:0] inp1,inp2;
input logic [31:0] immx;
input logic [31:0] npc;
input logic isImmediate;
input logic notBUOp;
input logic [3:0] ALUControl;
  
output logic overFlow, zero;
output reg signed [31:0] ALUResult;
  
logic  [31:0] ans;
logic [3:0] ALUControl_input;  
logic signed [31:0] op1,op2;
logic signed [63:0] mult;
  
reg signed[31:0] neg_data2, data1, data2;
logic [31:0] hi = 32'b00000000000000000000000000011111;
logic [31:0] lo = 32'b00000000000000000000000000011110;
logic [31:0] ones = 32'b11111111111111111111111111111111;
  
import REGISTERS::write_hi_reg;
import REGISTERS::write_lo_reg;
 
parameter bus_width = 32;
parameter ADD = 4'b0001;
parameter SUB = 4'b0010;
parameter MULT = 4'b0011;
parameter DIV = 4'b0100;
parameter AND = 4'b0101;
parameter OR = 4'b0110;
parameter NAND = 4'b0111;
parameter NOR = 4'b1000;
parameter XOR = 4'b1001;
parameter SLT = 4'b1010;
parameter SGT = 4'b1011;
parameter SLL = 4'b1100;
parameter SRL = 4'b1101;
parameter SLA = 4'b1110;
parameter SRA = 4'b1111;

  MUX #(bus_width) mux1 (.in_0(npc), .in_1(inp1), .signal(notBUOp), .out(op1));
  MUX #(bus_width) mux2 (.in_0(inp2), .in_1(immx), .signal(isImmediate), .out(op2));


 
//always @(ALUControl, data1, data2)
always @(posedge clock)
begin
#1
  if(!freeze) 
    begin
      ALUControl_input = ALUControl;
      data1 = op1;
      data2 = op2;
      neg_data2 = ~op2+1;
      overFlow = 1'b0;
      zero = 1'b0;
    end
 
end 

	
  always begin  
    @(posedge clock);
    @(negedge clock);
    #1
    if(!freeze)
      begin
        case(ALUControl_input)

            ADD: 
                begin	
                 ALUResult= data1 + data2;
                  if(!unsigned_operation) begin
                   if(data1[31] == data2[31] && ALUResult[31] == ~data1[31])
                      begin
                        $display("OOPS! overflow");
                         overFlow = 1'b1;
                      end
                    else
                    overFlow = 1'b0; 

                  end

                end

            SUB:
                begin
               ALUResult = data1 + neg_data2;
                 if(!unsigned_operation) begin
                  if(data1[31] == data2[31] && ALUResult[31] == ~data1[31])
                      begin
                        $display("OOPS! overflow");
                         overFlow = 1'b1;
                      end
                    else
                    overFlow = 1'b0;
                end
                end
            MULT:
                begin
                mult = data1 * data2;
                  ALUResult = mult[31:0];
                  write_lo_reg(mult[31:0]);
                  write_hi_reg(mult[63:32]);
                  if(!unsigned_operation) begin
                    if(mult[63] == mult[31] && (mult[63:32] == ones || ~mult[63:32] == ones ))
                     overFlow = 1'b0;               
                    else
                      begin
                        $display("OOPS! overflow");
                         overFlow = 1'b1;
                      end                        

                  end
                end
            DIV:
                begin
                  ALUResult = data1/data2;
                  write_lo_reg(data1/data2);
                  write_hi_reg(data1%data2);   
                  if(!unsigned_operation) begin
                    if(data2 == 0)
                      begin
                        $display("OOPS! overflow");
                         overFlow = 1'b1;
                      end              
                    else
                    overFlow = 1'b0;                 
                  end
                end

            AND:
                 ALUResult = data1 & data2;

            OR:
                ALUResult = data1 | data2;

            NAND:
                  ALUResult = ~(data1 & data2);

            NOR:
                  ALUResult = ~(data1 | data2);

            XOR:
                  ALUResult = data1 ^ data2;

            SLT:
                begin
                  if(data1 < data2)
                    ALUResult = 1;
                  else
                    ALUResult = 0;
                end

            SGT:
                begin
                if(data1 > data2)
                ALUResult = 1;
                else
                ALUResult = 0;
                end

            SLL:
                ALUResult = data1 << data2;

            SRL:
                ALUResult = data1 >> data2;

            SLA:
                ALUResult = data1 <<< data2;

            SRA:
                ALUResult = data1 >>> data2;

            endcase
          if(ALUResult==0)
          zero <= 1'b1;
          else
          zero <= 1'b0;
      end    
    
  end 


endmodule


//Swayam Pal

module BRANCH_UNIT(rs_in,rt_in,bu_op_in,branch_signal,freeze_in,clk);
  input logic signed [31:0] rs_in;
  input logic signed [31:0] rt_in;
input logic[2:0] bu_op_in;
input logic freeze_in;
input logic clk;
output logic branch_signal;

  logic signed [31:0] rs,rt;
logic comp_result;
logic[2:0] bu_op;


always @(posedge clk) begin
    #3
    if(!freeze_in) begin
        rs = rs_in;
        rt = rt_in;
        comp_result = 'b0;
      	bu_op = bu_op_in;
        @(negedge clk) ;
        unique0 case(bu_op) 
            
            'b000:comp_result = 'b0;
            'b100:if(rs==rt) comp_result = 'b1;
            'b101:if(rs!=rt) comp_result = 'b1;
            'b110:if(rs>rt) comp_result = 'b1;
            'b111:if(rs<rt) comp_result = 'b1;
            'b001:comp_result = 'b1;
        endcase
    end


end

always begin
    @(posedge clk);
    #2
    comp_result = 'b0;
end

assign branch_signal = comp_result;

endmodule

/*
	Arkanil
*/

module DATA_MEMORY_UNIT (clock, freeze, data_in, address_in, mem_read_in, mem_write_in, data_out);
	
	parameter bus_width = 32, reg_width = 32;
	
	import MEMORY::read_address, MEMORY::write_data;
	
	input logic clock;
	input logic freeze;
  input logic [bus_width-1:0] data_in;
  input logic [bus_width-1:0] address_in;
	input logic mem_read_in;
	input logic mem_write_in;
	
  output logic [bus_width-1:0] data_out;
	
	logic [reg_width-1:0] address_reg, data_in_reg, data_out_reg;
	
	assign data_out = data_out_reg;
	
	always begin
		@(posedge clock);
		if (!freeze) begin
			if (address_in[0]=='b1||address_in[0]=='b0) address_reg <= address_in;
			if (data_in[0]=='b1||data_in[0]=='b0) data_in_reg <= data_in;
		end
		@(negedge clock);
		#3
		unique0 if (mem_read_in=='b1) data_out_reg <= read_address(address_reg);
		else if (mem_write_in=='b1) write_data(address_reg, data_in_reg);
	end
	
endmodule:DATA_MEMORY_UNIT

/*
	Arkanil
*/

module NPC_SECTION (clock, freeze, mux_signal, npc_in, alu_result_in, npc_out);
	
	parameter reg_width = 32, bus_width = 32;
	
	input logic clock;
	input logic freeze;
	input logic mux_signal;
	input logic [bus_width-1:0] npc_in;
	input logic [bus_width-1:0] alu_result_in;
	
	output logic [bus_width-1:0] npc_out;
	
	logic [reg_width-1:0] npc;
	logic [bus_width-1:0] npc_wire;
	
	MUX #(bus_width) mux (.in_0(npc_in), .in_1(alu_result_in), .out(npc_wire), .signal(mux_signal));
	
	assign npc_out = npc;
	
	always @(posedge clock) if (!freeze) npc <= npc_wire;
	
endmodule:NPC_SECTION

/*
	Arkanil
*/

module TEMP_STORE (clock, alu_result_in, write_data_in, alu_result_out, write_data_out);
	
	parameter bus_width = 32, reg_width = 32;
	
  	input logic clock;
	input [bus_width-1:0] alu_result_in;
	input [bus_width-1:0] write_data_in;
	output [bus_width-1:0] alu_result_out;
	output [bus_width-1:0] write_data_out;
	
	reg [reg_width-1:0] alu_result_reg_in, alu_result_reg_out;
	reg [reg_width-1:0] write_data_reg_in, write_data_reg_out;
	
	assign alu_result_out = alu_result_reg_out;
	assign write_data_out = write_data_reg_out;
	
	always begin
		@(posedge clock);
		alu_result_reg_in <= alu_result_in;
		write_data_reg_in <= write_data_in;
		@(negedge clock);
		alu_result_reg_out <= alu_result_reg_in;
		write_data_reg_out <= write_data_reg_in;
	end
	
endmodule:TEMP_STORE

/*
	Arkanil
*/

module WRITE_BACK_UNIT (clock, freeze, mux_signal, write_back_signal, mem_data_in, alu_result_in, write_reg_in, write_special_reg_in);
	
	import REGISTERS::write_reg_data, REGISTERS::write_lo_reg, REGISTERS::write_hi_reg;
	
	parameter bus_width = 32, reg_width = 32;
	
	input logic clock;
	input logic freeze;
	input logic mux_signal;
	input logic write_back_signal;
	input logic write_special_reg_in;
	input logic [bus_width-1:0] mem_data_in;
	input logic [bus_width-1:0] alu_result_in;
	input logic [4:0] write_reg_in;
	
	logic [reg_width-1:0] data;
	logic [bus_width-1:0] data_wire;
	logic [4:0] reg_num;
	
	MUX mux (.in_0(mem_data_in), .in_1(alu_result_in), .signal(mux_signal), .out(data_wire));
	
	always begin
		@(posedge clock);
		#3
		if (!freeze) begin
			data <= data_wire;
			reg_num <= write_reg_in;
		end
	end
	
	always begin
		@(posedge clock);
		@(negedge clock);
		#3
		if (!freeze) begin
			if (write_back_signal) begin
				unique0 if (reg_num=='d31) begin
					if (write_special_reg_in=='b1) write_hi_reg(data);
				end
				else if (reg_num=='d30) begin
					if (write_special_reg_in=='b1) write_lo_reg(data);
				end
				else if (reg_num>'b0&&reg_num<'d30) write_reg_data(reg_num, data);
			end
		end
	end
endmodule:WRITE_BACK_UNIT

/*
	Arkanil
*/

module SINGLE_CORE (clock, initial_pc_in, signal_in, signal_out, end_signal_out);
	
	parameter core_num = 0, bus_width = 32, reg_width = 32;
	
	input logic clock;
	input logic [bus_width-1:0] initial_pc_in;
	input logic [15:0] signal_in;
	output logic [15:0] signal_out;
	
	output logic end_signal_out;
	
	logic [bus_width-1:0] initial_pc, instruction, npc1, npc2, read_data1, read_data2, imm, alu_res1, alu_res2, write_data, mem_data;
	logic [18:0] ins_signal;
	logic [4:0] write_reg;
	logic [3:0] ALUOp, alu_control_input;
	logic [2:0] BUOp;
	logic communication_enable, wait_for_next, cu_enable, rd1_signal, rd2_signal, engage_reg_signal, write_reg_mux_signal, sign_extend_mux_signal, branch_taken, alu_mux_1_signal, alu_mux_2_signal, alu_ignore_overflow, overFlow, zero, mem_read, mem_write, write_back_mux_signal, write_special_reg, write_back_signal;
	
	logic ifu_freeze, pc_freeze, rfu_freeze, rfu_to_cu_freeze, se_freeze, alu_control_freeze, bu_freeze, alu_freeze, npc_freeze, data_mem_freeze, write_back_freeze;
	
	// MULTITHREAD SUPPORT EXTENSION
	COMMUNICATION_UNIT COMU (.clock(clock), .enable_in(communication_enable), .initial_pc_in(initial_pc_in), .ins_signal_in(ins_signal), .signal_in(signal_in), .initial_pc_out(initial_pc), .wait_for_next_out(wait_for_next), .signal_out(signal_out), .end_signal_out(end_signal_out));
	
	// PHASE 1 - INSTRUCTION FETCH UNIT
	INS_FETCH_UNIT IFU (.pc_in_0(npc2), .pc_in_1(initial_pc), .wait_for_next_in(wait_for_next), .clock(clock), .freeze_in(ifu_freeze), .freeze_pc_in(pc_freeze), .npc_out(npc1), .ins_out(instruction), .communication_signal_out(ins_signal), .cu_enable_out(cu_enable), .communication_enable_out(communication_enable));
	
	// PHASE 2 - INSTRUCTION DECODE & REGISTER FETCH UNIT
	CONTROL_UNIT CU (.OpCode_in(instruction[bus_width-1:bus_width-6]), .enable_in(cu_enable), .clock(clock), .branch_taken_in(branch_taken), .read_data_1_out(rd1_signal), .read_data_2_out(rd2_signal), .engage_reg_out(engage_reg_signal), .ALUOp_out(ALUOp), .BUOp_out(BUOp), .alu_ignore_overflow_out(alu_ignore_overflow), .mem_read_out(mem_read), .mem_write_out(mem_write), .write_back_out(write_back_signal), .write_special_reg_out(write_special_reg),
					// FREEZE INs
					.reg_fetch_freeze_in(rfu_to_cu_freeze),
					// FREEZE OUTs
					.ins_fetch_freeze_out(ifu_freeze), .freeze_pc_out(pc_freeze), .reg_fetch_freeze_out(rfu_freeze), .sign_extend_freeze_out(se_freeze), .alu_control_freeze_out(alu_control_freeze), .bu_freeze_out(bu_freeze), .alu_freeze_out(alu_freeze), .npc_freeze_out(npc_freeze), .data_mem_freeze_out(data_mem_freeze), .write_back_freeze_out(write_back_freeze), 
					// MUX Signals
					.write_reg_mux_out(write_reg_mux_signal), .sign_extend_mux_out(sign_extend_mux_signal), .alu_mux_1_out(alu_mux_1_signal), .alu_mux_2_out(alu_mux_2_signal), .write_back_mux_out(write_back_mux_signal)
					);
	REG_FETCH_UNIT RFU (.read_data1_in(instruction[bus_width-7:bus_width-11]), .read_data2_in(instruction[bus_width-12:bus_width-16]), .read_data3_in(instruction[bus_width-17:bus_width-21]), .clk(clock), .read_data1_out(read_data1), .read_data2_out(read_data2), .write_reg_out(write_reg), .mux_signal(write_reg_mux_signal), .rd1_signal(rd1_signal), .rd2_signal(rd2_signal), .freeze_in(rfu_freeze), .freeze_out(rfu_to_cu_freeze), .engage_reg_in(engage_reg_signal));
  SIGNED_EXTENSION SE (.bit26_ins_in(instruction[bus_width-7:0]), .mux_signal(sign_extend_mux_signal), .bit32_ext(imm), .freeze_in(se_freeze), .clk(clock));
	CONTROL_UNIT_ALU CU_ALU(.funct_field_in(instruction[bus_width-27:bus_width-32]), .Alu_op_in(ALUOp), .clk(clock), .Alu_cs_op(alu_control_input), .freeze_in(alu_control_freeze));
	
	// PHASE 3 - EXECUTION UNIT
	BRANCH_UNIT BU (.rs_in(read_data1), .rt_in(read_data2), .bu_op_in(BUOp), .branch_signal(branch_taken), .freeze_in(bu_freeze), .clk(clock));
	ARITHMETIC_AND_LOGIC_UNIT ALU (.clock(clock), .inp1(read_data1), .inp2(read_data2), .isImmediate(alu_mux_2_signal), .notBUOp(alu_mux_1_signal), .immx(imm), .npc(npc1), .ALUControl(alu_control_input), .overFlow(overFlow), .zero(zero), .ALUResult(alu_res1), .unsigned_operation(alu_ignore_overflow), .freeze(alu_freeze));
	
	// PHASE 4 - MEMORY ACCESS & NPC UNIT
	NPC_SECTION NPC_S (.clock(clock), .freeze(npc_freeze), .mux_signal(branch_taken), .npc_in(npc1), .alu_result_in(alu_res1), .npc_out(npc2));	
	DATA_MEMORY_UNIT DMU (.clock(clock), .freeze(data_mem_freeze), .data_in(write_data), .address_in(alu_res1), .mem_read_in(mem_read), .mem_write_in(mem_write), .data_out(mem_data));
  TEMP_STORE TS (.alu_result_in(alu_res1), .write_data_in(read_data2), .alu_result_out(alu_res2), .write_data_out(write_data), .clock(clock));
	
	// PHASE 5 - WRITE BACK UNIT
	WRITE_BACK_UNIT WBU (.clock(clock), .freeze(write_back_freeze), .mux_signal(write_back_mux_signal), .write_back_signal(write_back_signal), .mem_data_in(mem_data), .alu_result_in(alu_res2), .write_reg_in(write_reg), .write_special_reg_in(write_special_reg));
	
endmodule:SINGLE_CORE
