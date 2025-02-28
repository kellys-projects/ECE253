module part2 (input logic [3:0] A, B, input logic [1:0] Function, output logic [7:0] ALUout);
     logic s, x, y, z, c_in, c_out;
     function0_RCA u0 (A, B, c_in, c_out, s);
     function1_or8 u1 (A, B, x);
     function2_and8 u2 (A, B, y);
     function3_concatenate8 u3 (A, B, z);
     mux4to1 u4 (s, x, y, z, ALUout);
endmodule


module function0_RCA (input logic A, B, c_in,                     
                      output logic s, c_out);
     assign s = A ^ B ^ c_in;
     assign c_out = (A & B) | (c_in & A) | (c_in & B);
endmodule



module function1_or8 (input logic [3:0] A, B,
                      output logic x);
     assign x = (|A) | (|B)



module function2_and8 (input logic [3:0] A, B,
                       output logic y);
     assign y = (&A) & (&B);
endmodule



module function3_concatenate8 (input logic [3:0] A, B,
                               output logic [7:0] z);
     assign z = {A, B};
endmodule


module mux4to1 (input logic [3:0] s, x, y, z,
                input logic [1:0] function,
                output logic [7:0] ALUout);
     always_comb
     begin
          case (function)
               2'b00: ALUout = s;
               2'b01: ALUout = x;
               2'b10: ALUout = y;
               2'b11: ALUout = z;
          endcase
     end
endmodule
