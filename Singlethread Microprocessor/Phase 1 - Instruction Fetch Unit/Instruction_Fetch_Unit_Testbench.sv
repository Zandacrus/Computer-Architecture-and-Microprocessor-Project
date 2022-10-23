/*
	Arkanil
*/

module INS_FETCH_UNIT_TB ();
	
	import MEMORY::write_ins_data;
	
	logic [31:0] pc_in_0;
	logic [31:0] pc_in_1;
	logic [18:0] communication_signal;
	logic 		 communication_enable;
	logic 		 wait_for_next;
	logic 		 clock;
	logic 		 freeze_out;
	logic 		 freeze_pc_out;
	logic 		 cu_enable;
	logic [31:0] instruction;
	logic [31:0] npc;
	
	logic [31:0] initial_pc;
	logic [31:0] clock_cycles;
	
	logic [16:0][31:0] ins_set;
	
	INS_FETCH_UNIT ins_fetcher (.pc_in_0(pc_in_0), .pc_in_1(pc_in_1), .wait_for_next_in(wait_for_next), .clock(clock),
								.freeze_in(freeze_out), .freeze_pc_in(freeze_pc_out), .npc_out(npc), .communication_enable_out(communication_enable), 
								.communication_signal_out(communication_signal), .cu_enable_out(cu_enable), .ins_out(instruction));
	
	//
	
	always #10 clock = ~clock;
	
	always @(posedge clock) clock_cycles += 'b1;
	
	assign pc_in_1 = initial_pc;
	
	initial $monitor({	"[%0t ns, clock_cycle = %0d] pc_in_0 = %b, pc_in_1 = %b, pc_choice = %b, pc = %0d,\n",
						"ins_wire = %b, wait_for_next_in = %b, clock = %b, freeze_in = %b, freeze_pc_in = %b, npc_out = %0d,\n",
						"communication_enable_out = %b, communication_signal_out = %b, cu_enable_out = %b, ins_out = %b\n"}, 
						$time, clock_cycles, ins_fetcher.pc_in_0, ins_fetcher.pc_in_1,  ins_fetcher.pc_choice_signal, ins_fetcher.pc, 
						ins_fetcher.ins_wire, ins_fetcher.wait_for_next_in, ins_fetcher.clock, ins_fetcher.freeze_in, ins_fetcher.freeze_pc_in, ins_fetcher.npc_out, 
						ins_fetcher.communication_enable_out, ins_fetcher.communication_signal_out, ins_fetcher.cu_enable_out, ins_fetcher.ins_out);
	//
		
	always begin // From Control Unit
		#1
		if (cu_enable=='b0) begin
			@(posedge cu_enable);
			freeze_out = 'b0;
		end
	end
	
	always begin // From Control Unit
		#1
		if (cu_enable=='b1) begin
			@(negedge cu_enable);
			freeze_out = 'b1;
		end
	end
	
	always begin // From Communication Unit
		#1
		if (communication_enable=='b1) begin
			unique0 if (communication_signal[18:17]=='b10) begin // Start
				$display("[%0t ns, clock_cycle = %0d] Start signal recieved.", $time, clock_cycles);
				
				unique if (communication_signal[16]=='b1) begin
					$display("[%0t ns, clock_cycle = %0d] Process dependency signal -> %b", $time, clock_cycles, communication_signal[15:0]);
					wait_for_next = 'b1;
					#90
					@(posedge clock);
					$display("[%0t ns, clock_cycle = %0d] Starting...", $time, clock_cycles);
					wait_for_next = 'b0;
					@(posedge clock);
				end
				else if (communication_signal[16]=='b0) begin
					wait_for_next = 'b0;
					$display("[%0t ns, clock_cycle = %0d] Process is independent.", $time, clock_cycles);
					@(posedge clock);
				end
			end
			else if (communication_signal[18:17]=='b11) begin  // Stop
				wait_for_next = 'b1;
				@(posedge clock);
				$display("Waiting...");
				@(posedge clock);
				$display("Waiting...");
				@(posedge clock);
				$display("Waiting...");
				@(posedge clock);
				$display("Waiting...");
				@(posedge clock);
				$display("Waiting Over");
				wait_for_next = 'b0;
				$display("[%0t ns, clock_cycle = %0d] Stop signal recieved.", $time, clock_cycles);
				$display("[ %0t ns, clock_cycle = %0d] Signals sent -> %b", $time, clock_cycles, communication_signal[15:0]);
			end
			else if (communication_signal[18:17]=='b00) begin // End
				$display("[%0t ns, clock_cycle = %0d] End signal recieved.", $time, clock_cycles);
				wait_for_next = 'b1;
				$display("[ %0t ns, clock_cycle = %0d] Execution Finished.\nWaiting for simulation to finish...", $time, clock_cycles);
				#60
				$finish;
			end
		end
	end
	
	always @(posedge clock) pc_in_0 = npc; // From Memory Stage
	
	initial begin 
		clock_cycles = 'b0;
	// From Control Unit
		clock = 'b0;
		freeze_out = 'b1;
		freeze_pc_out = 'b0;
	// From Communication Unit
		wait_for_next = 'b0;
	// Writing instructions to memory
		ins_set = '{
			'b111111_10_0_0000_0000_0000_0000_0000000, // start (independent)
			'b011000_01010_01010_00000_00000_111000,
			'b001010_01010_01010_00000_00000_111000,
			'b000000_01010_01010_00000_00000_111000,
			'b101010_01010_01010_00000_00000_111000,
			'b000000_01010_01010_00000_00000_111000,
			'b010101_01010_01010_00000_00000_111000,
			'b011100_01010_01010_00000_00000_111000,
			'b111111_11_0_0000_0000_0000_0000_0000000, // stop
			'b111111_10_1_0010_0001_1110_0110_0000000, // start (dependent)
			'b001010_01010_01010_00000_00000_111000,
			'b001010_01010_01010_00000_00000_111000,
			'b001010_01010_01010_00000_00000_111000,
			'b001010_01010_01010_00000_00000_111000,
			'b001010_01010_01010_00000_00000_111000,
			'b111111_11_0_0000_0000_0000_0000_0000000, // stop
			'b111111_00_0_0000_0000_0000_0000_0000000 // end
		};
		
		initial_pc = 'd14;
		
		for (int i=16; i>=0; i--) write_ins_data(initial_pc+(16-i), ins_set[i]);
		// From Control Unit (In case of Read after Write hazard)
		repeat(9) @(posedge clock);
		#2
		freeze_pc_out = 'b1;
		freeze_out = 'b1;
		repeat(3) @(negedge clock);
		#1
		freeze_pc_out = 'b0;
		freeze_out = 'b0;
	end
	
endmodule:INS_FETCH_UNIT_TB