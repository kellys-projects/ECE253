module part3(input logic Clock, Reset_b, input logic [3:0] Data, input logic [1:0] Function, output logic [7:0] ALU_reg_out);
    logic [3:0] A;
    logic [3:0] B;
    logic [7:0] Q;

    assign A = Data;
    assign B = Q[3:0];

    reg8 u0(ALU_reg_out, Clock, Reset_b, Q);

    always_comb
    begin
        case(Function)
            2'b00: ALU_reg_out = A + B;
            2'b01: ALU_reg_out = A * B;
            2'b10: ALU_reg_out = B << A;
            2'b11: ALU_reg_out = Q;
            default: ALU_reg_out = 8'b00000000;
        endcase
    end
endmodule

module reg8(input logic [7:0] ALUout, input logic clk, reset_b, output logic [7:0] q);
    always_ff @(posedge clk)
    begin
        if (reset_b == 1) q <= 8'b00000000;
        else q <= ALUout;
    end
endmodule
