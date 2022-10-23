/*
	Arkanil
*/

module SINGLE_CORE_TB ();
	
	import REGISTERS::display_regs, REGISTERS::set_special_reg_state, MEMORY::write_ins_data;
	
	parameter ins_set_size = 12;
	
	logic clock, end_signal_out;
	logic [31:0] initial_pc;
	logic [ins_set_size-1:0][31:0] ins_set;
	logic [15:0] signal_in, signal_out;
	int clock_cycle;
	
	SINGLE_CORE single_core (.clock(clock), .initial_pc_in(initial_pc), .signal_in(signal_in), .signal_out(signal_out), .end_signal_out(end_signal_out));
	
	always #10 clock = ~clock;
	
	always begin
		@(posedge clock);
		clock_cycle+=1;
		$display("[%0t ns, clock_cycle = %0d]", $time, clock_cycle);
		display_regs();
	end
	
	initial begin
		
		clock <= 'b0;
		initial_pc <= 'd14;
		// Factorial of 4
		ins_set = '{
		'b11111110000000000000000000000000,
		'b01000100000000010000000000000100,
		'b01000100000000100000000000000001,
		'b01000100000001000000000000000001,
		'b01000100001000110000000000000001,
		'b00010000010000110000000000000100,
		'b01000000100000100010000000000011,
		'b01000100010000100000000000000001,
		'b00001011111111111111111111111011,
		'b01000100000000000000000000000000,
		'b01000100000000000000000000000000,
		'b11111100000000000000000000000000
		};
		
		/*
		ins_set = '{
		{6'b111111, 2'b10, 1'b0, 16'b0, 7'b0},		// start (independent)
		{6'b010001, 5'd0, 5'd1, 16'd4},				// addi $1, $0, 4;
		{6'b010001, 5'd0, 5'd2, 16'd1},				// addi $2, $0, 1;
		{6'b010001, 5'd0, 5'd4, 16'd1},				// addi $4, $0, 1;
		{6'b010001, 5'd1, 5'd3, 16'd1},				// addi $3, $1, 1;
													// :loop:
		{6'b000100, 5'd2, 5'd3, 16'd4},				// beq $2, $3, end; (end = 4)
		{6'b010000, 5'd4, 5'd2, 5'd4, 5'b0, 6'd3},	// mul $4, $2;
		{6'b010001, 5'd2, 5'd2, 16'd1},				// addi $2, 1;
		{6'b000010, -26'd5},						// j loop; (loop = -5)
		{6'b010001, 5'd0, 5'd0, 16'd0},				// addi $0, 0;
		{6'b010001, 5'd0, 5'd0, 16'd0},				// addi $0, 0;
													// :end:
		{6'b111111, 2'b00, 1'b0, 16'b0, 7'b0}		// end
		};
		*/
		/*
		ins_set = '{
		{6'b111111, 2'b10, 1'b0, 16'b0, 7'b0},		// start (independent)
		{6'b010001, 5'd0, 5'd1, 16'd4},				// addi $1, $0, 4;
		{6'b010001, 5'd0, 5'd2, 16'd1},				// addi $2, $0, 1;
		{6'b010001, 5'd0, 5'd4, 16'd1},				// addi $4, $0, 1;
		{6'b010001, 5'd0, 5'd0, 16'd0},				// addi $0, 0;
		{6'b010001, 5'd1, 5'd3, 16'd1},				// addi $3, $1, 1;
		{6'b010001, 5'd0, 5'd0, 16'd0},				// addi $0, 0;
		{6'b010001, 5'd0, 5'd0, 16'd0},				// addi $0, 0;
		{6'b010001, 5'd0, 5'd0, 16'd0},				// addi $0, 0;
													// :loop:
		{6'b000100, 5'd2, 5'd3, 16'd4},				// beq $2, $3, end; (end = 4)
		{6'b010000, 5'd4, 5'd2, 5'd4, 5'b0, 6'd3},	// mul $4, $2;
		{6'b010001, 5'd2, 5'd2, 16'd1},				// addi $2, 1;
		{6'b000010, -26'd5},						// j loop; (loop = -5)
		{6'b010001, 5'd0, 5'd0, 16'd0},				// addi $0, 0;
		{6'b010001, 5'd0, 5'd0, 16'd0},				// addi $0, 0;
													// :end:
		{6'b111111, 2'b00, 1'b0, 16'b0, 7'b0}		// end
		};
		*/
		/*
		ins_set = '{
		{6'b111111, 2'b10, 1'b0, 16'b0, 7'b0},		// start (independent)
		{6'b010001, 5'd0, 5'd6, -16'd36},			// addi $6, $0, -36;
		{6'b010001, 5'd0, 5'd7, 16'd49},			// addi $7, $0, 49;
		{6'b011001, 5'd0, 5'd8, 16'd24},			// xori $8, $0, 24;
		{6'b010001, 5'd0, 5'd9, 16'd27},			// addi $9, $0, 27;
		{6'b010010, 5'd6, 5'd6, -16'd27},			// subi $6, -27;
		{6'b010111, 5'd7, 5'd7, 16'd27},			// nandi $7, 27;
		{6'b010000, 5'd0, 5'd8, 5'd10, 5'b0, 6'd2},	// sub $10, $0, $8;
		{6'b010000, 5'd7, 5'd9, 5'd11, 5'b0, 6'd10},// slt $11, $7, $9;
		{6'b010000, 5'd8, 5'd6, 5'd12, 5'b0, 6'd3},	// mul $12, $8, $6;
		{6'b010100, 5'd9, 5'd9, 16'd4},				// divi $9, 4;
		{6'b011100, 5'd9, 5'd13, 16'd2},			// slli $13, $9, 2;
		{6'b111111, 2'b00, 1'b0, 16'b0, 7'b0}		// end
		};
		*/
		/*
		ins_set = '{
		{6'b111111, 2'b10, 1'b0, 16'b0, 7'b0},		// start (independent)
		{6'b010001, 5'd0, 5'd6, -16'd36},			// addi $6, $0, -36;
		{6'b010001, 5'd0, 5'd7, 16'd49},			// addi $7, $0, 49;
		{6'b010010, 5'd7, 5'd7, 16'd6},				// subi $7, 6;
		{6'b010000, 5'd6, 5'd7, 5'd5, 5'b0, 6'd1},	// add $5, $6, $7;
		{6'b010001, 5'd0, 5'd12, 16'd7},			// addi $12, $0, 7;
		{6'b010001, 5'd0, 5'd13, -16'd7},			// addi $13, $0, -7;
		{6'b010000, 5'd12, 5'd13, 5'd14, 5'b0, 6'd3},// mul $14, $12, $13;
		{6'b010000, 5'd5, 5'd12, 5'd21, 5'b0, 6'd4},// div $21, $5, $12;
		{6'b010000, 5'd5, 5'd13, 5'd22, 5'b0, 6'd4},// div $22, $5, $13;
		{6'b010000, 5'd21, 5'd22, 5'd23, 5'b0, 6'd1},// add $23, $21, $22;
		{6'b111111, 2'b00, 1'b0, 16'b0, 7'b0}		// end
		};
		*/
		#1
		for (int i=ins_set_size-1; i>=0; i--) write_ins_data(initial_pc+(ins_set_size-1-i), ins_set[i]);
		
		$monitor({	"[ %0t ns, clock_cycle = %0d] ",
					"\nIFU => pc_in_0 = %0d, pc_in_1 = %0d, wait_for_next_in = %b, freeze_in = %b, ins_wire = %b, freeze_pc_in = %b, npc_out = %0d, ins_out = %b, cu_enable_out = %b, communication_enable_out = %b",
					"\nRFU => read_data1_in = %0d, read_data2_in = %0d, read_data3_in = %0d, read_data1_out = %0d, read_data2_out = %0d, write_reg_out = %0d, mux_signal = %b, rd1_signal = %b, rd2_signal = %b, freeze_in = %b, freeze_out = %b, engage_reg_in = %b",
					"\nSE => freeze_in = %b, bit26_ins_in = %b, mux_signal = %b, bit32_ext = %0d (%b)",
					"\nCU_ALU => freeze_in = %b, funct_field_in = %b, Alu_op_in = %b, Alu_cs_op = %b",
					"\nBU => rs_in = %0d, rt_in = %0d, bu_op_in = %b, branch_signal = %b, freeze_in = %b",
					"\nALU => freeze = %b, op1 = %0d, op2 = %0d, inp1 = %0d, inp2 = %0d, isImmediate = %b, notBUOp = %b, immx = %0d, npc = %0d, ALUControl = %b, overFlow = %b, zero = %b, ALUResult = %0d, unsigned_operation = %b",
					"\nDMU => freeze = %b, data_in = %0d, address_in = %b, mem_read_in = %b, mem_write_in = %b, data_out = %0d",
					"\nWBU => freeze = %b, mux_signal = %b, write_back_signal = %b, mem_data_in = %0d, alu_result_in = %0d, write_reg_in = %0d, write_special_reg_in = %b",
					"\nset_special_reg_state = %b"
				}, $time, clock_cycle, single_core.IFU.pc_in_0, single_core.IFU.pc_in_1, single_core.IFU.wait_for_next_in, single_core.IFU.freeze_in, single_core.IFU.ins_wire, single_core.IFU.freeze_pc_in, single_core.IFU.npc_out, single_core.IFU.ins_out, single_core.IFU.cu_enable_out, single_core.IFU.communication_enable_out,
					single_core.RFU.read_data1_in, single_core.RFU.read_data2_in, single_core.RFU.read_data3_in, single_core.RFU.read_data1_out, single_core.RFU.read_data2_out, single_core.RFU.write_reg_out, single_core.RFU.mux_signal, single_core.RFU.rd1_signal, single_core.RFU.rd2_signal, single_core.RFU.freeze_in, single_core.RFU.freeze_out, single_core.RFU.engage_reg_in,
					single_core.SE.freeze_in, single_core.SE.bit26_ins_in, single_core.SE.mux_signal, single_core.SE.bit32_ext, single_core.SE.bit32_ext,
					single_core.CU_ALU.freeze_in, single_core.CU_ALU.funct_field_in, single_core.CU_ALU.Alu_op_in, single_core.CU_ALU.Alu_cs_op,
					single_core.BU.rs_in, single_core.BU.rt_in, single_core.BU.bu_op_in, single_core.BU.branch_signal, single_core.BU.freeze_in, 
					single_core.ALU.freeze, single_core.ALU.op1, single_core.ALU.op2, single_core.ALU.inp1, single_core.ALU.inp2, single_core.ALU.isImmediate, single_core.ALU.notBUOp, single_core.ALU.immx, single_core.ALU.npc, single_core.ALU.ALUControl, single_core.ALU.overFlow, single_core.ALU.zero, single_core.ALU.ALUResult, single_core.ALU.unsigned_operation,
					single_core.DMU.freeze, single_core.DMU.data_in, single_core.DMU.address_in, single_core.DMU.mem_read_in, single_core.DMU.mem_write_in, single_core.DMU.data_out,
					single_core.WBU.freeze, single_core.WBU.mux_signal, single_core.WBU.write_back_signal, single_core.WBU.mem_data_in, single_core.WBU.alu_result_in, single_core.WBU.write_reg_in, single_core.WBU.write_special_reg_in,
					set_special_reg_state);
	end
	
	always begin
		@(negedge end_signal_out);
		@(posedge end_signal_out);
		$display("[%0t ns, clock_cycle = %0d]", $time, clock_cycle);
		display_regs();
		$finish;
	end
	
	initial begin
      	//$dumpfile("dump.vcd"); $dumpvars;
      	//#1000 $finish;
    end
	
	always begin
		@(posedge single_core.CU.read_after_write_hazard);
		#1 $display("\nRead After Write Hazard Detected...\nStalling this clock cycle...");
		@(posedge clock);
		if (single_core.CU.read_after_write_hazard) begin
			#1 $display("Stalling this clock cycle...");
			@(posedge clock);
			if (single_core.CU.read_after_write_hazard) begin
				#1 $display("Stalling this clock cycle...");
			end
		end
		#1 $display("Read After Write Hazard cleared. Continuing...");
	end
	
	always begin
		@(posedge single_core.CU.branch_hazard);
		#1 $display("\nControl Hazard Detected...\n");
		if (single_core.CU.read_after_write_hazard) $display("Suppressing Read After Write Hazard...");
		@(posedge clock);
		#1 $display("Flushing PHASE 1 Units...");
		@(posedge clock);
		#1 $display("Flushing PHASE 2 Units...");
		@(posedge clock);
		#1 $display("Flushing PHASE 3 Units...");
		@(posedge clock);
		#1 $display("Control Hazard cleared. Continuing...");
	end
	
endmodule:SINGLE_CORE_TB