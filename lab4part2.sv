// top-level module

module part2 
#(parameter CLOCK_FREQUENCY = 500)(
    input logic ClockIn,
    input logic Reset,
    input logic [1:0] Speed,                 // controls division rate (refer to ratedivider) 
    output logic [3:0] CounterValue          // syntax in lab: output logic [WIDTH - 3:0] ?
);
    logic Enable;

    // Instantiate RateDivider
    RateDivider #(CLOCK_FREQUENCY) ratedivider(
        .ClockIn(ClockIn),
        .Reset(Reset),
        .Speed(Speed),
        .Enable(Enable)
    );

    // Instantiate DisplayCounter
    DisplayCounter displaycounter(
        .Clock(ClockIn),
        .Reset(Reset),
        .EnableDC(Enable),
        .CounterValue(CounterValue)
    );

endmodule

module RateDivider #(parameter CLOCK_FREQUENCY = 500)(         
    input logic ClockIn,
    input logic Reset,              // active high reset
    input logic [1:0] Speed,        // 2-bit input for selecting division rate
    output logic Enable
);

    logic S;
    logic [S:0] RateDividerCount;
    logic N;                        // N = clock frequency / pulse frequency

    always_comb
    begin
        case(Speed)
            2'b00: N = 1;
            2'b01: N = CLOCK_FREQUENCY/1;    
            2'b10: N = CLOCK_FREQUENCY/0.5;  
            2'b11: N = CLOCK_FREQUENCY/0.25;   
            default: N = 1;
        endcase
    end

    assign S = $clog2(N) - 1;
    assign RateDividerCount = '1;

    always_ff @(posedge ClockIn)
        if(Reset)
            RateDividerCount <= '1;
            Enable <= 0;
        else if(RateDividerCount == '0)
            RateDividerCount <= '1;
            Enable <= 1;
        else
            RateDividerCount <= RateDividerCount - 1;
            Enable <= 0;

endmodule

// lab: counter must count down to 0 and generate an enable pulse when it reaches 0 
// how to make it count down to 0, because i think it currently it resets to 0 when it counts up to count_limit-1


module DisplayCounter(
    input logic Clock,
    input logic Reset,                        // active high reset
    input logic EnableDC,                     // enables counter to increment
    output logic [3:0] CounterValue           // 4-bit, represents current counter value
);
    always_ff @(posedge Clock)
        if (Reset)
            CounterValue <= 4'b0000;              // countervalue = 0 when reset is high
        else if (EnableDC)             
            CounterValue <= CounterValue + 1;     // countervalue increments by 1

endmodule



