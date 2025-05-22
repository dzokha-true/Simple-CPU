module control_unit (
    input [3:0] opcode,         // Opcode from instruction

    output reg reg_write_enable,
    output reg [1:0] alu_op_select,
    output reg alu_operand_b_select // 0: Reg Ry, 1: Immediate
);

    // Opcodes (match global definition)
    parameter OP_LOAD = 4'b0000;
    parameter OP_MOV  = 4'b0001;
    parameter OP_ADD  = 4'b0010;
    parameter OP_XOR  = 4'b0011;

    // ALU Operation Select Codes (match ALU module)
    parameter ALU_OP_PASS_B = 2'b00;
    parameter ALU_OP_ADD    = 2'b01;
    parameter ALU_OP_XOR    = 2'b10;

    always @(*) begin // Combinational decode
        // Default values (important for unspecified opcodes/NOP behavior)
        reg_write_enable     = 1'b0;
        alu_op_select        = ALU_OP_PASS_B; // Default to a safe operation
        alu_operand_b_select = 1'b0;         // Default to register source

        case (opcode)
            OP_LOAD: begin
                reg_write_enable     = 1'b1;
                alu_op_select        = ALU_OP_PASS_B;
                alu_operand_b_select = 1'b1; // Select immediate
            end
            OP_MOV: begin
                reg_write_enable     = 1'b1;
                alu_op_select        = ALU_OP_PASS_B;
                alu_operand_b_select = 1'b0; // Select Ry
            end
            OP_ADD: begin
                reg_write_enable     = 1'b1;
                alu_op_select        = ALU_OP_ADD;
                alu_operand_b_select = 1'b0; // Select Ry
            end
            OP_XOR: begin
                reg_write_enable     = 1'b1;
                alu_op_select        = ALU_OP_XOR;
                alu_operand_b_select = 1'b0; // Select Ry
            end
            default: begin // Handles unused opcodes as NOPs
                reg_write_enable     = 1'b0;
                alu_op_select        = ALU_OP_PASS_B; // Or some other default
                alu_operand_b_select = 1'b0;
            end
        endcase
    end

endmodule
