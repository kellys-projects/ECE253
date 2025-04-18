// instantiating 4 instances
// [0:3] Q = 4-bit signals for the outputs of four flip flops

module part1(input logic clock, reset, ParallelLoadn, RotateRight, ASRight, input logic [3:0] Data_IN, output logic [3:0] Q);
   
    sub_circuit u0(
        .clock(clock),
        .reset(reset),
        .loadn(ParallelLoadn),
        .LoadLeft(RotateRight),
        .D(Data_IN[0]),
        .right(Q[3]),
        .left(Q[1]),
        .Q(Q[0])
    );

    sub_circuit u1(
        .clock(clock),
        .reset(reset),
        .loadn(ParallelLoadn),
        .LoadLeft(RotateRight),
        .D(Data_IN[1]),
        .right(Q[0]),
        .left(Q[2]),
        .Q(Q[1])
    );

    sub_circuit u2(
        .clock(clock),
        .reset(reset),
        .loadn(ParallelLoadn),
        .LoadLeft(RotateRight),
        .D(Data_IN[2]),
        .right(Q[1]),
        .left(Q[3]),
        .Q(Q[2])
    );

    sub_circuit_final u3(
        .clock(clock),
        .reset(reset),
        .loadn(ParallelLoadn),
        .LoadLeft(RotateRight),
        .ASRight(ASRight),
        .D(Data_IN[3]),
        .right(Q[2]),
        .left(Q[0]),
        .left_alt(Q[3]),
        .Q(Q[3])
    );

endmodule

// module for the sub-circuit

module sub_circuit_final(input logic clock, reset, loadn, LoadLeft, ASRight, D, right, left, left_alt, output logic Q);

    always_ff @(posedge clock) 
        if(reset)
            Q <= 0;
        else if(!loadn) 
            Q <= D;
        else if(LoadLeft)
            if(ASRight) 
                Q <= left_alt; 
            else 
                Q <= left; 
        else 
            Q <= right; 
        
endmodule

module sub_circuit(input logic clock, reset, loadn, LoadLeft, D, right, left, output logic Q);

    always_ff @(posedge clock) 
        if(reset)
            Q <= 0;
        else if(!loadn) 
            Q <= D;
        else if(LoadLeft)
            Q <= left; 
        else 
            Q <= right; 
        
endmodule
