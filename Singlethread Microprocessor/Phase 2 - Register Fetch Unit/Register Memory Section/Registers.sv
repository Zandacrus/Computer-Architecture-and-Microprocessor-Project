/*
	Arkanil
*/

package REGISTERS;
	reg [31:0][31:0] registers; // 32 registers each of 32 bit
	reg [31:0][2:0] state = '{96{'b0}}; // state[i] represents whether register i is busy(>0) or not (0) 
	// max possible value of state[i] is 5 since it is a 5 stage pipelined architecture
	
	function logic [31:0] read_reg_data (logic [31:0] reg_num);
		return registers[reg_num];
	endfunction
	
	function logic read_reg_state (logic [31:0] reg_num);
		return state[reg_num];
	endfunction
	
	function set_reg_state(logic [31:0] reg_num);
		state[reg_num] += 'b1;
	endfunction
	
	function void write_reg_data (logic [31:0] reg_num, logic [31:0] data);
		registers[reg_num] = data;
		state[reg_num] -= 'b1;
	endfunction
	
endpackage