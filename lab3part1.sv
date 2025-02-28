module part1(input logic [3:0] a, b, input logic c_in, output logic [3:0] s, c_out);    FA fa1(a[0], b[0], c_in, s[0], c_out[0]);
    FA fa2(a[1], b[1], c_out[0], s[1], c_out[1]);
    FA fa3(a[2], b[2], c_out[1], s[2], c_out[2]);
    FA fa4(a[3], b[3], c_out[2], s[3], c_out[3]);endmodule      
module FA(input logic a, b, c_in, output logic s, c_out);
    assign s = a^b^c_in;
    assign c_out = (a & b) | (c_in & a) | (c_in & b);
endmodule