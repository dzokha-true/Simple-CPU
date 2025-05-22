module reg_file (
    input clk,
    input rst_n,
    input write_enable,          // Enable writing to register Rx
    input [1:0] write_addr_rx,   // Address of Rx (destination)
    input [1:0] read_addr_operand_a, // Address for operand A (often Rx for read-modify-write)
    input [1:0] read_addr_operand_b, // Address for operand B (often Ry)
    input [7:0] write_data_in,   // Data to write into Rx

    output [7:0] read_data_operand_a, // Data from operand A's register
    output [7:0] read_data_operand_b  // Data from operand B's register
);

    reg [7:0] registers[0:3]; // 4 registers, 8-bits each

    integer i;

    assign read_data_operand_a = registers[read_addr_operand_a];
    assign read_data_operand_b = registers[read_addr_operand_b];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < 4; i = i + 1) begin
                registers[i] <= 8'b0;
            end
        end else begin
            if (write_enable) begin
                registers[write_addr_rx] <= write_data_in;
            end
        end
    end

endmodule
