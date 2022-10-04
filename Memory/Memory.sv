/*
	Arkanil
*/

package MEMORY;
	reg [(256*1024)-1:0][31:0] memory; // 1 MB 
	
	function logic [31:0] read_address (logic [31:0] address);
		return memory[address];
	endfunction
	
	function void write_data (logic [31:0] address, logic [31:0] data);
		memory[address] = data;
	endfunction
	
endpackage
