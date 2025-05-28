module alu (a, b, alu_op_select, result);
    input [15:0] a;
    input [15:0] b;
    input [2:0] alu_op_select; // Control signal for operation
    output reg [15:0] result;

    // ALU Operation Select Codes
    parameter ALU_OP_PASS   = 3'b000;
    parameter ALU_OP_ADD    = 3'b010;
    parameter ALU_OP_XOR    = 3'b011;
	 parameter ALU_OP_OR     = 3'b100;
	 parameter ALU_OP_AND    = 3'b101;
	 
	 
    // parameter ALU_OP_UNUSED = 2'b11; // Future use

    always @(*) begin // Combinational
        case (alu_op_select)
            ALU_OP_PASS_B: result = operand_b;
            ALU_OP_ADD:    result = operand_a + operand_b;
            ALU_OP_XOR:    result = operand_a ^ operand_b;
				ALU_OP_OR:     result = operand_a | operand_b;
				ALU_OP_AND:    result = operand_a & operand_b;
				
            default:       result = 8'h00; // Default or error case
        endcase
    end

endmodule
