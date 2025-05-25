module datapath (
    input clk,
    input reset_n,

    // Control Signals from Control Unit
    input        pc_write_enable,
    input [1:0]  pc_source_sel,
    input        ir_write_enable,
    input        rf_write_enable,
    input [2:0]  rf_write_dest_sel_addr,
    input [1:0]  rf_write_data_sel,
    input [2:0]  alu_op_sel,
    input        alu_b_src_sel,
    // input        imm_sign_extend_sel, // Removed, immediate is always 16-bit from IR[15:0]

    // Inputs from Memory / To Memory
    input  [31:0] instruction_in,   // From Instruction Memory (Changed to 32-bit)
    output [7:0]  pc_out_addr,      // To Instruction Memory address port

    // Outputs to Control Unit
    output [3:0]  opcode_out,
    output [2:0]  ir_field_target_reg_out, // IR[27:25] (Rx, Rd)
    // output [2:0]  ir_field_src1_reg_out,   // IR[24:22] (Ry, Rs1) - CU may not need this directly
    // output [2:0]  ir_field_src2_reg_out,   // IR[21:19] (Rz, Rs2) - CU may not need this
    output        zero_flag_out,
    output        negative_flag_out,

    output [15:0] r0_debug_out,
    output [15:0] r1_debug_out,
    output [31:0] ir_debug_out // For observing the full IR
);

    // PC Logic
    reg  [15:0] pc_reg;
    wire [15:0] pc_incremented;
    wire [15:0] branch_target_addr;
    wire [15:0] pc_next_val;

    // IR Logic
    reg  [31:0] ir_reg; // Changed to 32-bit
    wire [2:0]  decoded_target_reg_field; // IR[27:25] (Rx/Rd)
    wire [2:0]  decoded_src1_reg_field;   // IR[24:22] (Ry/Rs1)
    // wire [2:0]  decoded_src2_reg_field;   // IR[21:19] (Rz/Rs2) - not used by current ops for RF addressing
    wire [15:0] decoded_imm16_field;    // IR[15:0]

    // Register File
    wire [15:0] rf_read_data_a;
    wire [15:0] rf_read_data_b;
    wire [15:0] rf_write_data_internal;
    wire [2:0]  rf_read_addr_a_internal;
    wire [2:0]  rf_read_addr_b_internal;


    // Immediate Value (always 16-bit from IR)
    wire [15:0] immediate_val_from_ir;

    // ALU
    wire [15:0] alu_in_a_internal;
    wire [15:0] alu_in_b_internal;
    wire [15:0] alu_result_internal;

    localparam LR_ADDR = 3'b111; // R7 is Link Register
    wire [15:0] pc_val_for_lr_write;


    assign pc_out_addr = pc_reg[7:0];
    assign pc_incremented = pc_reg + 1;
    assign immediate_val_from_ir = decoded_imm16_field; // This is the 16-bit value from IR[15:0]
    // Branch target uses the 16-bit immediate field as a signed offset
    assign branch_target_addr = pc_reg + $signed(immediate_val_from_ir);


    assign pc_val_for_lr_write = pc_reg;

    mux4to1 #(16) pc_mux (
        .sel(pc_source_sel),
        .in0(pc_incremented),
        .in1(branch_target_addr),
        .in2(rf_read_data_a), // For RET (LR content on port A)
        .in3(branch_target_addr), // CALL target same as branch
        .out(pc_next_val)
    );

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) pc_reg <= 16'b0;
        else if (pc_write_enable) pc_reg <= pc_next_val;
    end

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) ir_reg <= 32'b0;
        else if (ir_write_enable) ir_reg <= instruction_in;
    end
    assign ir_debug_out = ir_reg;

    // IR Decoding
    assign opcode_out             = ir_reg[31:28];
    assign decoded_target_reg_field = ir_reg[27:25]; // Rx or Rd
    assign decoded_src1_reg_field   = ir_reg[24:22]; // Ry or Rs1
    // assign decoded_src2_reg_field   = ir_reg[21:19]; // Rz or Rs2
    assign decoded_imm16_field    = ir_reg[15:0];

    // Outputs to Control Unit
    assign ir_field_target_reg_out = decoded_target_reg_field; // To CU as rd_addr_in

    // Register File Addressing Logic
    // For RET, Port A reads LR. For ADD/XOR/CMP, Port A reads Rx (decoded_target_reg_field).
    // For MOV, Port A is not critical for the data path of Ry -> Rx if ALU PASS_B uses alu_in_b.
    // If MOV Rx, Ry and Rx is also an ALU input A, then Rx should be on port A.
    // For 2-operand Rx <- Rx op Ry, Rx is read on Port A.
    // For MOV Rx <- Ry, Ry is read on Port B. Rx (target) is not read as an operand.
    // The PC source mux selects rf_read_data_a for RET.
    // The rf_write_dest_sel_addr comes from CU, usually based on ir_field_target_reg_out or LR_ADDR.

    // Simplified: Port A reads target_reg for 2-op instructions, or LR for RET.
    // Port B reads src1_reg for 2-op instructions and MOV.
    assign rf_read_addr_a_internal = (pc_source_sel == 2'b10) ? LR_ADDR : decoded_target_reg_field; // For RET, read LR; else for ADD/XOR/CMP, read Rx
    assign rf_read_addr_b_internal = decoded_src1_reg_field; // For Ry in ADD/XOR/CMP/MOV

    reg_file reg_file_inst (
        .clk(clk),
        .reset_n(reset_n),
        .read_addr_a(rf_read_addr_a_internal),
        .read_data_a(rf_read_data_a),
        .read_addr_b(rf_read_addr_b_internal),
        .read_data_b(rf_read_data_b),
        .write_enable(rf_write_enable),
        .write_addr(rf_write_dest_sel_addr), // From CU
        .write_data(rf_write_data_internal)
    );

    assign alu_in_a_internal = rf_read_data_a; // Rx for 2-operand, or garbage for MOV if not careful
    assign alu_in_b_internal = alu_b_src_sel ? immediate_val_from_ir : rf_read_data_b; // Imm or Ry

    alu alu_inst (
        .alu_in_a(alu_in_a_internal),
        .alu_in_b(alu_in_b_internal),
        .alu_op_sel(alu_op_sel),
        .alu_result(alu_result_internal),
        .zero_flag(zero_flag_out),
        .negative_flag(negative_flag_out)
    );

    mux4to1 #(16) rf_wdata_mux (
        .sel(rf_write_data_sel),
        .in0(alu_result_internal),   // For ADD, XOR, MOV (via PASS_B)
        .in1(immediate_val_from_ir), // For LOAD
        .in2(pc_val_for_lr_write),   // For CALL (PC+1 into LR)
        .in3(16'hXXXX),              // Unused
        .out(rf_write_data_internal)
    );
    
    assign r0_debug_out = reg_file_inst.registers[0];
    assign r1_debug_out = reg_file_inst.registers[1];

endmodule
