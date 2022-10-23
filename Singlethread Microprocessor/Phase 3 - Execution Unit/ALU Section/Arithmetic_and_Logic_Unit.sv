//Manisha

module ARITHMETIC_AND_LOGIC_UNIT(clock, inp1, inp2,isImmediate,notBUOp, immx,npc, ALUControl,overFlow, zero, ALUResult, unsigned_operation, freeze);

input logic clock, freeze;
input logic unsigned_operation;
input logic signed [31:0] inp1,inp2;
input logic [31:0] immx;
input logic [31:0] npc;
input logic isImmediate;
input logic notBUOp;
input logic [3:0] ALUControl;
  
output logic overFlow, zero;
output reg signed [31:0] ALUResult;
  
logic  [31:0] ans;
logic [3:0] ALUControl_input;  
logic signed [31:0] op1,op2;
logic signed [63:0] mult;
  
reg signed[31:0] neg_data2, data1, data2;
logic [31:0] hi = 32'b00000000000000000000000000011111;
logic [31:0] lo = 32'b00000000000000000000000000011110;
logic [31:0] ones = 32'b11111111111111111111111111111111;
  
import REGISTERS::write_hi_reg;
import REGISTERS::write_lo_reg;
 
parameter bus_width = 32;
parameter ADD = 4'b0001;
parameter SUB = 4'b0010;
parameter MULT = 4'b0011;
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

  MUX #(bus_width) mux1 (.in_0(npc), .in_1(inp1), .signal(notBUOp), .out(op1));
  MUX #(bus_width) mux2 (.in_0(inp2), .in_1(immx), .signal(isImmediate), .out(op2));


 
//always @(ALUControl, data1, data2)
always @(posedge clock)
begin
#1
  if(!freeze) 
    begin
      ALUControl_input = ALUControl;
      data1 = op1;
      data2 = op2;
      neg_data2 = ~op2+1;
      overFlow = 1'b0;
      zero = 1'b0;
    end
 
end 

	
  always begin  
    @(posedge clock);
    @(negedge clock);
    
    if(!freeze)
      begin
        case(ALUControl_input)

            ADD: 
                begin	
                 ALUResult= data1 + data2;
                  if(!unsigned_operation) begin
                   if(data1[31] == data2[31] && ALUResult[31] == ~data1[31])
                      begin
                        $display("OOPS! overflow");
                         overFlow = 1'b1;
                      end
                    else
                    overFlow = 1'b0; 

                  end

                end

            SUB:
                begin
               ALUResult = data1 + neg_data2;
                 if(!unsigned_operation) begin
                  if(data1[31] == data2[31] && ALUResult[31] == ~data1[31])
                      begin
                        $display("OOPS! overflow");
                         overFlow = 1'b1;
                      end
                    else
                    overFlow = 1'b0;
                end
                end
            MULT:
                begin
                mult = data1 * data2;
                  write_lo_reg(mult[31:0]);
                  write_hi_reg(mult[63:32]);
                  if(!unsigned_operation) begin
                    if(mult[63] == mult[31] && (mult[63:32] == ones || ~mult[63:32] == ones ))
                     overFlow = 1'b0;               
                    else
                      begin
                        $display("OOPS! overflow");
                         overFlow = 1'b1;
                      end                        

                  end
                end
            DIV:
                begin
                  ALUResult = data1/data2;
                  write_lo_reg(data1/data2);
                  write_hi_reg(data1%data2);   
                  if(!unsigned_operation) begin
                    if(data2 == 0)
                      begin
                        $display("OOPS! overflow");
                         overFlow = 1'b1;
                      end              
                    else
                    overFlow = 1'b0;                 
                  end
                end

            AND:
                 ALUResult = data1 & data2;

            OR:
                ALUResult = data1 | data2;

            NAND:
                  ALUResult = ~(data1 & data2);

            NOR:
                  ALUResult = ~(data1 | data2);

            XOR:
                  ALUResult = data1 ^ data2;

            SLT:
                begin
                  if(data1 < data2)
                    ALUResult = 1;
                  else
                    ALUResult = 0;
                end

            SGT:
                begin
                if(data1 > data2)
                ALUResult = 1;
                else
                ALUResult = 0;
                end

            SLL:
                ALUResult = data1 << data2;

            SRL:
                ALUResult = data1 >> data2;

            SLA:
                ALUResult = data1 <<< data2;

            SRA:
                ALUResult = data1 >>> data2;

            endcase
          if(ALUResult==0)
          zero <= 1'b1;
          else
          zero <= 1'b0;
      end    
    
  end 


endmodule