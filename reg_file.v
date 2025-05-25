module reg_file (
    input clk,
    input reset_n, // Active low reset

    // Read Port A
    input  [2:0]  read_addr_a,
    output [15:0] read_data_a,

    // Read Port B
    input  [2:0]  read_addr_b,
    output [15:0] read_data_b,

    // Write Port
    input        write_enable,
    input  [2:0] write_addr,
    input  [15:0] write_data
);

    reg [15:0] registers [0:7];
    integer i;

    // Asynchronous read (combinational)
    assign read_data_a = registers[read_addr_a];
    assign read_data_b = registers[read_addr_b];

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            for (i = 0; i < 8; i = i + 1) begin
                registers[i] <= 16'b0;
            end
        end else begin
            if (write_enable) begin
                // Ensure write_addr is within bounds if necessary, though 3 bits naturally limits it.
                registers[write_addr] <= write_data;
            end
        end
    end
endmodule
