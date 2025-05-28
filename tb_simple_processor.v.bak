`timescale 1ns / 1ps

module tb_simple_processor;

    // Testbench signals
    reg clk;
    reg reset;
    reg start;
    reg write;
    reg [22:0] program_in;

    // Cycle counter (can be useful for correlating with waveforms)
    integer cycle_count = 0;

    // Instantiate the Unit Under Test (UUT)
    simple_processor DUT (
        .clk(clk),
        .reset(reset),
        .start(start),
        .write(write),
        .program_in(program_in)
    );

    // Clock generation
    localparam CLK_PERIOD = 10; // Clock period of 10ns
    always begin
        clk = 0; #(CLK_PERIOD/2);
        clk = 1; #(CLK_PERIOD/2);
    end

    // Increment cycle counter on positive clock edge
    always @(posedge clk) begin
        if (!reset) begin // Optionally, only count when not in reset
            cycle_count = cycle_count + 1;
        end else begin
            cycle_count = 0; // Reset counter during reset
        end
    end

    // Stimulus and simulation control
    initial begin
        // Initialize inputs
        reset = 1; // Assert reset
        start = 0;
        write = 0;
        program_in = 23'h000000;

        // Apply reset for a few clock cycles
        #(CLK_PERIOD * 2);
        reset = 0; // De-assert reset
        #(CLK_PERIOD);

        // --- Scenario 1: Load and run a hypothetical first instruction ---
        program_in = 23'h00000; // Example instruction value
        write = 1; // Assert write
        #(CLK_PERIOD); // Hold write for one clock cycle
        write = 0;

        start = 1; // Assert start to begin processing

        // Let the processor run for some cycles
        #(CLK_PERIOD * 10);
        start = 0; // De-assert start

        #(CLK_PERIOD * 2);

        // --- Scenario 2: Load and run a hypothetical second instruction ---
        program_in = 23'hAAAAAA; // Another example instruction
        write = 1; // Assert write
        #(CLK_PERIOD);
        write = 0;

        start = 1; // Assert start again

        // Let it run for some more cycles
        #(CLK_PERIOD * 10);

        // --- End of Test ---
        $finish;
    end

endmodule
