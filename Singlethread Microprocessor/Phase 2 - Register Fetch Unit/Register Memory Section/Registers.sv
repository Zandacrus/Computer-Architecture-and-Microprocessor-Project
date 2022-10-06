/*
	Arkanil
*/

package REGISTERS;
	reg [28:0][31:0] registers; // 29 registers each of 32 bit
	reg [2:0][31:0] special_registers = '{3{32'b0}}; // 3 special registers each of 32 bit (zero(0), lo(1), hi(2))
	reg [28:0][2:0] state = '{29{3'b0}}; // state[i] represents whether register i is busy(>0) or not (0) 
	// max possible value of state[i] is 5 since it is a 5 stage pipelined architecture
	
	function logic [31:0] read_reg_data (logic [4:0] reg_num);
		unique0 if (reg_num=='b0) return special_registers['b0]; // reg_num = 0 -> zero reg
		else if (reg_num>'d29) return special_registers[(reg_num-'d29)]; // reg_num = 30 -> lo reg, reg_num = 31 -> hi reg
		else return registers[(reg_num-'b1)];
	endfunction
	
	function logic [2:0] read_reg_state (logic [4:0] reg_num);
		if ((reg_num>'b0)&&(reg_num<'d30)) return state[(reg_num-'b1)];
		else return 'b0;
	endfunction
	
	function void set_reg_state(logic [4:0] reg_num);
		if ((reg_num>'b0)&&(reg_num<'d30)) state[(reg_num-'b1)] += 'b1;
	endfunction
	
	function void write_reg_data (logic [4:0] reg_num, logic [31:0] data);
		if ((reg_num>'b0)&&(reg_num<'d30)) begin
			registers[(reg_num-'b1)] = data;
			state[(reg_num-'b1)] -= 'b1;
		end
	endfunction
	
	function void write_lo_reg (logic [31:0] data);
		special_registers['d1] = data;
	endfunction
	
	function void write_hi_reg (logic [31:0] data);
		special_registers['d2] = data;
	endfunction
	
	
	
endpackage