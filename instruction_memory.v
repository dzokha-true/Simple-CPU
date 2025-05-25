module instruction_memory (
    input  [7:0]  address,    // 8-bit address for 256 words
    output [31:0] instruction // Changed to 32-bit output
);
    // Memory size: 256 words x 32 bits
    reg [31:0] mem [0:255];

    // ... (initial block with program) ...

    // Asynchronous read
    assign instruction = mem[address];
endmodule
