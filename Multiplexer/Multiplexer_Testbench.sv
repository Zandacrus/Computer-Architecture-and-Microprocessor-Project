/*
	Arkanil
*/

module MUX_TB ();
	
	logic [31:0] in_0, in_1, out;
	logic control;
	
	MUX mux (.in_0(in_0), .in_1(in_1), .out(out), .signal(control));
	
	initial begin
		$monitor({	"[%0t ns] tb_in_0 = %b, tb_in_1 = %b, tb_out = %b, control = %b,", 
					"\n", 
					"mux_in_0 = %b, mux_in_1 = %b, mux_out = %b, mux_signal = %b"
					}, 
					$time, in_0, in_1, out, control, mux.in_0, mux.in_1, mux.out, mux.signal
				);
		
		#10
		control <= 'b0;
		in_0 <= 'b01110101011101010111010101110101;
		in_1 <= 'b11001101110011011100110111001101;
		
		#10
		control <= 'b1;
		in_0 <= 'b01110101011101010111010101110101;
		in_1 <= 'b11001101110011011100110111001101;
		
		#10
		control <= 'b0;
		in_0 <= 'b00000000000001010111010101110101;
		in_1 <= 'b11001101110011011100110111001101;
		
		#10 $finish;
	end
	
endmodule:MUX_TB