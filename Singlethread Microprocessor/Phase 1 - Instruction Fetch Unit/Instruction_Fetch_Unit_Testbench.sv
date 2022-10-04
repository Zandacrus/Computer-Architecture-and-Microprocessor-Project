/*
	Arkanil
*/

module INS_FETCH_UNIT_TB ();
	
	import MEMORY::write_data;
	
	logic [31:0] pc_in_0;
	logic [31:0] pc_in_1;
	logic [18:0] communication_signal;
	logic 		 communication_enable;
	logic 		 wait_for_next;
	logic 		 pc_choice;
	logic 		 clock;
	logic 		 reset;
	logic 		 freeze;
	logic 		 cu_enable;
	logic [31:0] instruction;
	logic [31:0] npc;
	
	logic [31:0] initial_pc;
	logic [31:0] clock_cycles;
	
	logic [9:0][31:0] ins_set;
	
	INS_FETCH_UNIT ins_fetcher (.pc_in_0(pc_in_0), .pc_in_1(pc_in_1), .wait_for_next_in(wait_for_next), .clock(clock), .reset(reset), 
								.freeze(freeze), .pc_choice_signal_1(pc_choice), .npc_out(npc), .communication_enable_out(communication_enable), 
								.communication_signal_out(communication_signal), .cu_enable_out(cu_enable), .ins_out(instruction));
	
	//
	
	always #10 clock = ~clock;
	
	always (@posedge clock) clock_cycles += 'b1;;
	
	assign pc_in_1 = initial_pc;
	
	initial $monitor({	"[%0t ns, clock_cycle = %d] pc_in_0 = %b, pc_in_1 = %b, wait_for_next_in = %b, clock = %b, reset = %b,\n",
						"freeze = %b, pc_choice_signal_1 = %b, npc_out = %b, communication_enable_out = %b,\n",
						"communication_signal_out = %b, cu_enable_out = %b, ins_out = %b"}, 
						$time, clock_cycles, ins_fetcher.pc_in_0, ins_fetcher.pc_in_1, ins_fetcher.wait_for_next_in, ins_fetcher.clock, ins_fetcher.reset, 
						ins_fetcher.freeze, ins_fetcher.pc_choice_signal_1, ins_fetcher.npc_out, ins_fetcher.communication_enable_out, 
						ins_fetcher.communication_signal_out, ins_fetcher.cu_enable_out, ins_fetcher.ins_out);
	//
	
	initial begin
		ins_set = '{
			'b111111_10_,
			'b,
			'b,
			'b,
			'b,
			'b,
			'b,
			'b,
			'b,
			'b,
		};
		
		
	end
	
	always begin // From Control Unit
		if (cu_enable=='b0) begin
			@(posedge cu_enable);
			freeze = 'b0;
		end
	end
	
	always begin // From Control Unit
		if (cu_enable=='b1) begin
			@(negedge cu_enable);
			freeze = 'b1;
		end
	end
	
	always begin // From Communication Unit
		#1
		unique0 if (communication_signal[18:17]=='b10) begin // Start
			$display("[%0t ns, clock_cycle = %d] Start signal recieved.");
			
			unique if (communication_signal[16]=='b1) begin
				$display("[%0t ns, clock_cycle = %d] Process dependency signal - %b", $time, clock_cycles, communication_signal[15:0]);
				wait_for_next_in = 'b1;
				#100 
				$display("[%0t ns, clock_cycle = %d] Starting...", $time, clock_cycles);
				wait_for_next_in = 'b0;
			end
			else if (communication_signal[16]=='b0) begin
				wait_for_next = 'b0;
				$display("[%0t ns, clock_cycle = %d] Process is independent dependent.", $time, clock_cycles);
			end
		end
		else if (communication_signal[18:17]=='b11) begin  // Stop
			$display("[%0t ns, clock_cycle = %d] Stop signal recieved.", $time, clock_cycles);
		end
		else if (communication_signal[18:17]=='b00) begin // End
			$display("[%0t ns, clock_cycle = %d] End signal recieved.", $time, clock_cycles);
			wait_for_next = 'b1;
			$finish;
		end
	end
	
	always @(posedge clock) pc_in_0 = npc; // From Memory Stage
	
	initial begin 
		clock_cycles = 'b0;
	// From Control Unit
		clock = 'b0;
		freeze = 'b1;
	// From Communication Unit
		wait_for_next = 'b0;
		pc_choice = 'b1;
		
		#
		
	end
	
endmodule:INS_FETCH_UNIT_TB