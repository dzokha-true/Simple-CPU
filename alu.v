module alu (
    input [7:0] operand_a,
    input [7:0] operand_b,
    input [1:0] alu_op_select, // Control signal for operation
    output reg [7:0] result
);

    // ALU Operation Select Codes
    parameter ALU_OP_PASS_B = 2'b00;
    parameter ALU_OP_ADD    = 2'b01;
    parameter ALU_OP_XOR    = 2'b10;
    // parameter ALU_OP_UNUSED = 2'b11; // Future use

    always @(*) begin // Combinational
        case (alu_op_select)
            ALU_OP_PASS_B: result = operand_b;
            ALU_OP_ADD:    result = operand_a + operand_b;
            ALU_OP_XOR:    result = operand_a ^ operand_b;
            default:       result = 8'h00; // Default or error case
        endcase
    end

endmodule
