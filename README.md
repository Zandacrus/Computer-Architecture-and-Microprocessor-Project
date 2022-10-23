# Computer-Architecture-and-Microprocessor-Project

Team mates: Amandeep Singh, Arkanil Paul, Manisha, Pavan Karthik, Swayam Pal, Tejaswini.

	
  
  
  Operation		                                          Assembly Code
		
	$d <-- $s + $t 		                                  add $d, $s, $t;
			
	$s <-- $s + $t 		                                  add $s, $t;
			
	$d <-- $s + $t (ignores overflow)		          addu $d, $s, $t;
			
	$s <-- $s + $t (ignores overflow)		          addu $s, $t;
			
	$d <-- $s - $t 		                                  sub $d, $s, $t;
			
	$s <-- $s - $t 		                                  sub $s, $t;
			
	$d <-- $s - $t (ignores overflow)		          subu $d, $s, $t;
			
	$s <-- $s - $t (ignores overflow)		          subu $s, $t;
			
	$d <-- $s * $t 		                                  mul $d, $s, $t;
			
	$s <-- $s * $t 		                                  mul $s, $t;
			
	$d <-- $s * $t (ignores overflow)		          mulu $d, $s, $t;
			
	$s <-- $s * $t (ignores overflow)		          mulu $s, $t;
			
	$d <-- $s / $t 		                                  div $d, $s, $t;
			
	$s <-- $s / $t 		                                  div $s, $t;
			
	$d <-- $s / $t (ignores overflow)		          divu $d, $s, $t;
			
	$s <-- $s / $t (ignores overflow)		          divu $s, $t;
			
	$d <-- $s & $t 		                                  and $d, $s, $t;
			
	$s <-- $s & $t 		                                  and $s, $t;
			  
	$d <-- $s | $t 		                                  or $d, $s, $t;
			
	$s <-- $s | $t 		                                  or $s, $t;
			
	$d <-- ~($s & $t)		                          nand $d, $s, $t;
			
	$s <-- ~($s & $t)		                          nand $s, $t;
			
	$d <-- ~($s | $t)		                          nor $d, $s, $t;
			
	$s <-- ~($s | $t)		                          nor $s, $t;
			
	$d <-- $s ^ $t		                                  xor $d, $s, $t;
			
	$s <-- $s ^ $t		                                  xor $s, $t;
			
	$d <-- 1 if $s < $t else 0 [with sign]		          slt $d, $s, $t;
			
	$s <-- 1 if $s < $t else 0 [with sign]		          slt $s, $t;
			
	$d <-- 1 if $s > $t else 0 [with sign]		          sgt $d, $s, $t;
			
	$s <-- 1 if $s > $t else 0 [with sign]		          sgt $s, $t;
			  
	$d <-- ($s << $t) [signbit not preserved]		  sll $d, $s, $t;
			
	$s <-- ($s << $t) [signbit not preserved]		  sll $s, $t;
			
	$d <-- ($s >> $t) [signbit not preserved]		  srl $d, $s, $t;
			
	$s <-- ($s >> $t) [signbit not preserved]		  srl $s, $t;
			
	$d <-- ($s << $t) [signbit preserved]		          sla $d, $s, $t;
			
	$s <-- ($s << $t) [signbit preserved]		          sla $s, $t;
			
	$d <-- ($s >> $t) [signbit preserved]		          sra $d, $s, $t;
			
	$s <-- ($s >> $t) [signbit preserved]		          sra $s, $t;
		
	$d <-- $s + imm		                                  addi $d, $s, imm;
			
	$s <-- $s + imm		                                  addi $s, imm;
			
	$d <-- $s - imm		                                  subi $d, $s, imm;
			
	$s <-- $s - imm		                                  subi $s, imm;
			
	$d <-- $s * imm		                                  muli $d, $s, imm;
			
	$s <-- $s * imm		                                  muli $s, imm;
			  
	$d <-- $s / imm		                                  divi $d, $s, imm;
			
	$s <-- $s / imm		                                  divi $s, imm;
			
	$d <-- $s & imm		                                  andi $d, $s, imm;
			
	$s <-- $s & imm		                                  andi $s, imm;
			  
	$d <-- $s | imm		                                  ori $d, $s, imm;
			
	$s <-- $s | imm		                                  ori $s, imm;
			
	$d <-- ~($s & imm)		                          nandi $d, $s, imm;
			
	$s <-- ~($s & imm)		                          nandi $s, imm;
			
	$d <-- ~($s | imm)		                          nori $d, $s, imm;
			
	$s <-- ~($s | imm)		                          nori $s, imm;
			
	$d <-- $s ^ imm		                                  xori $d, $s, imm;
			
	$s <-- $s ^ imm		                                  xori $s, imm;
			
	$d <-- 1 if $s < imm else 0 [with sign]		          slti $d, $s, imm;
			
	$s <-- 1 if $s < imm else 0 [with sign]		          slti $s, imm;
			
	$d <-- 1 if $s > imm else 0 [with sign]		          sgti $d, $s, imm;
			
	$s <-- 1 if $s > imm else 0 [with sign]		          sgti $s, imm;
			
	$d <-- ($s << imm) [signbit not preserved]		  slli $d, $s, imm;
			
	$s <-- ($s << imm) [signbit not preserved]		  slli $s, imm;
			
	$d <-- ($s >> imm) [signbit not preserved]		  srli $d, $s, imm;
			
	$s <-- ($s >> imm) [signbit not preserved]		  srli $s, imm;
			
	$d <-- ($s << imm) [signbit preserved]		          slai $d, $s, imm;
			
	$s <-- ($s << imm) [signbit preserved]		          slai $s, imm;
			
	$d <-- ($s >> imm) [signbit preserved]		          srai $d, $s, imm;
			
	$s <-- ($s >> imm) [signbit preserved]		          srai $s, imm;
		
	pc <-- npc + imm if $s == $t		                  beq $s, $t, label;
			
	pc <-- npc + imm if $s != $t		                  bne $s, $t, label;
			
	pc <-- npc + imm if $s > $t		                  bgt $s, $t, label;
			  
	pc <-- npc + imm if $s < $t		                  blt $s, $t, label;
			
	pc <-- npc + imm		                          j imm;
			
	pc <-- npc + $t		                                  jr $t;
		
	$d <-- mem [$s + imm]		                          lw $d, imm($s);
			
	mem [$s + imm] <-- $d		                          sw $d, imm($s);
			
	$d <-- hi		                                   mfhi $d;
			
	$d <-- lo		                                   mflo $d;
			
	hi <-- $s		                                   mthi $s;
			
	lo <-- $s		                                   mtlo $s;
