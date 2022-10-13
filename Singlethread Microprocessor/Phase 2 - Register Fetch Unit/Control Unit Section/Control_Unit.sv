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
	//
	
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
	QUEUE #(1, 1) alu_ignore_overflow_q (.data_in(alu_ignore_overflow), .clock(clock), .freeze(alu_ignore_overflow_q_freeze), /*.halt_data_in(alu_ignore_overflow_q_halt_data_in), .halt_data_out(alu_ignore_overflow_q_halt_data_out), */.data_out(alu_ignore_overflow_out));
	QUEUE #(2, 1) mem_read_q (.data_in(mem_read), .clock(clock), .freeze(mem_read_q_freeze), /*.halt_data_in(mem_read_q_halt_data_in), .halt_data_out(mem_read_q_halt_data_out), */.data_out(mem_read_out));
	QUEUE #(2, 1) mem_write_q (.data_in(mem_write), .clock(clock), .freeze(mem_write_q_freeze), /*.halt_data_in(mem_write_q_halt_data_in), .halt_data_out(mem_write_q_halt_data_out), */.data_out(mem_write_out));
	QUEUE #(3, 1) write_back_mux_q (.data_in(write_back_mux_signal), .clock(clock), .freeze(write_back_mux_q_freeze), /*.halt_data_in(write_back_mux_q_halt_data_in), .halt_data_out(write_back_mux_q_halt_data_out), */.data_out(write_back_mux_out));
	QUEUE #(3, 1) write_special_reg_q (.data_in(write_special_reg), .clock(clock), .freeze(write_special_reg_q_freeze), /*.halt_data_in(write_special_reg_q_halt_data_in), .halt_data_out(write_special_reg_q_halt_data_out), */.data_out(write_special_reg_out));
	QUEUE #(3, 1) write_back_q (.data_in(write_back), .clock(clock), .freeze(write_back_q_freeze), /*.halt_data_in(write_back_q_halt_data_in), .halt_data_out(write_back_q_halt_data_out), */.data_out(write_back_out));
	
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
		write_special_reg <= sig[1];
		write_back <= sig[0];
	endfunction
	
	// INITIAL
	initial begin
		freeze <= 'b1;
		branch_hazard <= 'b0;
		read_after_write_hazard <= 'b0;
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
		freeze <= 'b0;
		reg_fetch_freeze_out <= 'b0;
		sign_extend_freeze_out <= 'b0;
		alu_control_freeze_out <= 'b0;
		
		// PHASE 3
		@(negedge clock);
		bu_freeze_out <= 'b0;
		alu_freeze_out <= 'b0;
		
		
		// PHASE 4
		@(negedge clock);
		data_mem_freeze_out <= 'b0;
		
		// PHASE 5
		@(negedge clock);
		write_back_freeze_out <= 'b0;
	end
	
	// DISABLE
	always begin
		@(posedge clock);
		// @(negedge clock) #5
		@(negedge enable_in);
		
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
		bu_freeze_out <= 'b1;
		alu_freeze_out <= 'b1;
		
		// PHASE 4
		@(negedge clock);
		data_mem_freeze_out <= 'b1;
		
		// PHASE 5
		@(negedge clock);
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
