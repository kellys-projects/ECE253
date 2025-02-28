`timescale 1ns / 1ns // `timescale time_unit/time_precision

//SW[2:0] data inputs
//SW[9] select signals

//LEDR[0] output display

module mux(input logic [9:0] SW, output logic[9:0] LEDR);
    mux2to1 u0(
        .x(SW[0]),
        .y(SW[1]),
        .s(SW[9]),
        .m(LEDR[0])
        );
endmodule

module mux2to1(input logic x, input logic y, input logic s,output logic m);
    // x: select 0
    // y: select 1
    // s: select signal
    //m: output
  
    //assign m = s & y | ~s & x;
    // OR
    assign m = s ? y : x;

endmodule
