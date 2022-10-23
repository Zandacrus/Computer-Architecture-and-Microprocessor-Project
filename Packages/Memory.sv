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
