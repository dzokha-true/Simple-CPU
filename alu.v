module alu (
    input  [15:0] alu_in_a,
    input  [15:0] alu_in_b,
    input  [2:0]  alu_op_sel, // 00:ADD, 01:XOR, 10:SUB, 11:PASS_B
    output reg [15:0] alu_result,
    output reg        zero_flag,
    output reg        negative_flag
);

    localparam ALU_ADD    = 3'b000;
    localparam ALU_XOR    = 3'b001;
    localparam ALU_SUB    = 3'b010;
    localparam ALU_AND    = 3'b011;   
    localparam ALU_PASS_B = 3'b111;


    always @(*) begin
        case (alu_op_sel)
            ALU_ADD:    alu_result = alu_in_a + alu_in_b;
            ALU_XOR:    alu_result = alu_in_a ^ alu_in_b;
            ALU_SUB:    alu_result = alu_in_a - alu_in_b; // For CMP
            ALU_PASS_B: alu_result = alu_in_b;           // For LOAD immediate (if routed via ALU) or MOV
            default:    alu_result = 16'hXXXX;
        endcase

        if (alu_result == 16'b0) begin
            zero_flag = 1'b1;
        end else begin
            zero_flag = 1'b0;
        end
        negative_flag = alu_result[15]; // MSB
    end
endmodule
