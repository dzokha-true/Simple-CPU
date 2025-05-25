module control_unit (
    input clk,
    input reset_n,

    input [3:0] opcode_in,
    input [2:0] rd_addr_in, // From Datapath's ir_field_target_reg_out (IR[27:25])
    input       zero_flag_in,

    output reg       pc_write_enable,
    output reg [1:0] pc_source_sel,
    output reg       ir_write_enable,
    output reg       rf_write_enable,
    output reg [2:0] rf_write_dest_sel_addr, 
    output reg [1:0] rf_write_data_sel,
    output reg [1:0] alu_op_sel,
    output reg       alu_b_src_sel
    // output reg       imm_sign_extend_sel // Removed
);

    localparam S_FETCH   = 1'b0;
    localparam S_EXECUTE = 1'b1;
    reg current_state, next_state;

    localparam OP_LOAD  = 4'b0000;
    localparam OP_MOV   = 4'b0001;
    localparam OP_ADD   = 4'b0010;
    localparam OP_XOR   = 4'b0011;
    localparam OP_CMP   = 4'b0100;
    localparam OP_BZ    = 4'b0101;
    localparam OP_BNZ   = 4'b0110;
    localparam OP_JMP   = 4'b0111;
    localparam OP_CALL  = 4'b1000;
    localparam OP_RET   = 4'b1001;
    localparam OP_AND   = 4'b1010;

    localparam ALU_ADD_CU    = 3'b000;
    localparam ALU_XOR_CU    = 3'b001;
    localparam ALU_SUB_CU    = 3'b010;
    localparam ALU_AND_CU    = 3'b011;
    localparam ALU_PASS_B_CU = 3'b111;
    
    localparam LR_ADDR_CONST = 3'b111;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) current_state <= S_FETCH;
        else current_state <= next_state;
    end

    always @(*) begin
        pc_write_enable      = 1'b0;
        pc_source_sel        = 2'b00; // PC+1
        ir_write_enable      = 1'b0;
        rf_write_enable      = 1'b0;
        rf_write_dest_sel_addr= rd_addr_in; // Default to Rd from IR
        rf_write_data_sel    = 2'b00; // ALU Result
        alu_op_sel           = 2'b00; // Default ADD
        alu_b_src_sel        = 1'b0; // Default RegFile_Out_B
        // imm_sign_extend_sel  = 1'b0; // Default Zero Extend - Removed

        next_state = current_state;

        case (current_state)
            S_FETCH: begin
                ir_write_enable = 1'b1;
                pc_write_enable = 1'b1;
                pc_source_sel   = 2'b00; // PC+1
                next_state      = S_EXECUTE;
            end

            S_EXECUTE: begin
                next_state = S_FETCH;
                pc_write_enable = 1'b1;
                pc_source_sel   = 2'b00; // Default PC+1

                case (opcode_in)
                    OP_LOAD: begin // Rx <- D16
                        rf_write_enable   = 1'b1;
                        rf_write_data_sel = 2'b01; // Select immediate_val_from_ir directly
                        // ALU settings don't strictly matter for data path to RF if imm is direct
                        // but good practice to set them sanely if other parts might peek
                        alu_b_src_sel     = 1'b1;  // Point ALU B to immediate
                        alu_op_sel        = 2'b11; // PASS_B (though result not used for RF write here)
                    end
                    OP_MOV: begin // Rx <- Ry
                        rf_write_enable   = 1'b1;
                        rf_write_data_sel = 2'b00; // ALU Result
                        alu_op_sel        = 2'b11; // PASS_B (pass Ry data from alu_in_b)
                        alu_b_src_sel     = 1'b0;  // Ry from reg_file_out_b to alu_in_b
                    end
                    OP_ADD: begin // Rx <- Rx + Ry
                        rf_write_enable   = 1'b1;
                        rf_write_data_sel = 2'b00; // ALU Result
                        alu_op_sel        = 2'b00; // ADD
                        alu_b_src_sel     = 1'b0;  // Ry from reg_file_out_b
                    end
                    OP_XOR: begin // Rx <- Rx xor Ry
                        rf_write_enable   = 1'b1;
                        rf_write_data_sel = 2'b00; // ALU Result
                        alu_op_sel        = 2'b01; // XOR
                        alu_b_src_sel     = 1'b0;  // Ry from reg_file_out_b
                    end
                    OP_AND: begin 
                        rf_write_enable   = 1'b1;
                        rf_write_data_sel = 2'b00;      // ALU Result
                        alu_op_sel        = ALU_AND_CU; // AND
                        alu_b_src_sel     = 1'b0;       // Ry from reg_file_out_b
                    end
                    OP_CMP: begin                   // Rx - Ry, sets flags
                        rf_write_enable   = 1'b0;   // No write to register
                        alu_op_sel        = 2'b10;  // SUB
                        alu_b_src_sel     = 1'b0;   // Ry from reg_file_out_b
                    end
                    OP_BZ: begin
                        // imm_sign_extend_sel = 1'b1; // Removed (offset is 16-bit signed)
                        if (zero_flag_in) begin
                            pc_source_sel = 2'b01; // BranchAddr
                        end
                    end
                    OP_BNZ: begin
                        // imm_sign_extend_sel = 1'b1; // Removed
                        if (!zero_flag_in) begin
                            pc_source_sel = 2'b01; // BranchAddr
                        end
                    end
                    OP_JMP: begin
                        // imm_sign_extend_sel = 1'b1; // Removed
                        pc_source_sel     = 2'b01; // BranchAddr
                    end
                    OP_CALL: begin
                        // imm_sign_extend_sel = 1'b1; // Removed
                        rf_write_enable      = 1'b1;
                        rf_write_dest_sel_addr= LR_ADDR_CONST; // R7
                        rf_write_data_sel    = 2'b10; // PC_val_for_LR
                        pc_source_sel        = 2'b01; // BranchAddr (Call target)
                    end
                    OP_RET: begin
                        pc_source_sel     = 2'b10; // LR_Content from RF Port A
                    end
                    default: begin /* NOP or undefined */ end
                endcase
            end
            default: next_state = S_FETCH;
        endcase
    end
endmodule
