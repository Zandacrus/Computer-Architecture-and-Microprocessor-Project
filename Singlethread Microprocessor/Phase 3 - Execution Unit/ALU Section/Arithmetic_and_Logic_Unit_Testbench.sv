//Manisha

module ALU_TB ();
	
 logic freeze;
 logic unsigned_operation;
  logic signed [31:0] inp1, inp2;
 logic [3:0] ALUControl;
 logic [31:0] immx;
 logic isImmediate;
 logic notBUOp;
 logic [31:0] npc;
 logic overFlow, zero;
 logic signed [31:0] ALUResult;

 logic [31:0] ans;

 logic signed [31:0] data1,data2;
  
 reg clock=0;
  int i=0;
  
parameter ADD = 4'b0001;
parameter SUB = 4'b0010;
parameter MUL = 4'b0011;
parameter DIV = 4'b0100;
parameter AND = 4'b0101;
parameter OR = 4'b0110;
parameter NAND = 4'b0111;
parameter NOR = 4'b1000;
parameter XOR = 4'b1001;
parameter SLT = 4'b1010;
parameter SGT = 4'b1011;
parameter SLL = 4'b1100;
parameter SRL = 4'b1101;
parameter SLA = 4'b1110;
parameter SRA = 4'b1111;
  
  
  ARITHMETIC_AND_LOGIC_UNIT alu(.clock(clock),.inp1(inp1), .inp2(inp2), .isImmediate(isImmediate), .notBUOp(notBUOp), .immx(immx), .npc(npc), .ALUControl(ALUControl),  .overFlow(overFlow), .zero(zero), .ALUResult(ALUResult),.unsigned_operation(unsigned_operation), .freeze(freeze));
	

   always #10 clock = ~clock;
 initial begin
   notBUOp=1;
   isImmediate = 0;
   unsigned_operation = 'b0;
   freeze=0;
 end
  always begin
    @(posedge clock);
    if(i<4) begin
          
     if(i==0)begin
       inp1=4'b0000;
       inp2=4'b0100;
     end
     else if (i==1)begin
       inp1=4'b0010;
       inp2=4'b0101;
       end
     else if(i==2) begin
       inp1=32'b1000;
       inp2=32'b1100;
     end
     else begin
       inp1=32'b10000000000000000000000000000000;
       inp2=32'b10000000000000000000000000000000;
     end
    i=i+1;    
    
    
      for(ALUControl = 4'b0000; ALUControl<4'b1111; ALUControl=ALUControl+4'b001)
     begin
       @(negedge clock) ; 
       #2
      if(ALUControl==ADD)
        display("ADD " );

      else if(ALUControl==SUB)
        display("SUB ");
           
          
      else if(ALUControl==MUL) 
        display("MUL ");
      
      else if(ALUControl==DIV) 
        display("DIV " );
                 
      else if(ALUControl==AND)        
        display("AND " );
      
      else if(ALUControl==OR) 
        display("OR " );
      
      else if(ALUControl==NAND) 
        display("NAND ");
      
      else if(ALUControl==NOR)
        display("NOR " );
      
      else if(ALUControl==XOR)
        display("XOR " ); 
      
      else if(ALUControl==SLT)
        display("SLT " );      
            
      else if(ALUControl==SGT)
        display("SGT " );
            
      else if(ALUControl==SLL)
        display("SLL" );
      
      else if(ALUControl==SRL)
        display("SRL " ); 
            
      else if(ALUControl==SLA)
        display("SLA " );
            
      else if(ALUControl==SRA)
        display("SRA " );      
       
     end
      ALUControl = 4'b1111;
      @(negedge clock);
      
      display("SRA");
    
end
    
  end
  task display(string s);
    $display("%s op1 %b,op2 %b, ALUOP %b,  ALUResult %b, overFlow %b, zero %b",s, alu.op1, alu.op2, alu.ALUControl, alu.ALUResult, alu.overFlow, alu.zero );
    endtask;
    
       
endmodule
