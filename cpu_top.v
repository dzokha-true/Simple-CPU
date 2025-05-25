module cpu_top (
    input clk,
    input reset_n,

    output [7:0]  current_pc_debug,
    output [31:0] current_instr_debug, // Changed to 32-bit
    output [15:0] r0_val_debug,
    output [15:0] r1_val_debug,
    output [15:0] r7_lr_val_debug
);

    wire [31:0] instruction_from_mem; // Changed to 32-bit
    wire [7:0]  pc_to_mem_addr;

    wire [3:0]  opcode_to_cu;
    wire [2:0]  ir_target_reg_to_cu; // Renamed for clarity from rd_addr_to_cu
    wire        zero_flag_to_cu;
    wire        negative_flag_to_cu;

    wire        dp_pc_write_enable;
    wire [1:0]  dp_pc_source_sel;
    wire        dp_ir_write_enable;
    wire        dp_rf_write_enable;
    wire [2:0]  dp_rf_write_dest_sel_addr;
    wire [1:0]  dp_rf_write_data_sel;
    wire [1:0]  dp_alu_op_sel;
    wire        dp_alu_b_src_sel;
    // wire        dp_imm_sign_extend_sel; // Removed
    
    wire [15:0] dp_r0_debug_out;
    wire [15:0] dp_r1_debug_out;
    wire [31:0] dp_ir_debug_out;


    instruction_memory instr_mem_inst (
        .address(pc_to_mem_addr),
        .instruction(instruction_from_mem)
    );

    datapath datapath_inst (
        .clk(clk),
        .reset_n(reset_n),
        .pc_write_enable(dp_pc_write_enable),
        .pc_source_sel(dp_pc_source_sel),
        .ir_write_enable(dp_ir_write_enable),
        .rf_write_enable(dp_rf_write_enable),
        .rf_write_dest_sel_addr(dp_rf_write_dest_sel_addr),
        .rf_write_data_sel(dp_rf_write_data_sel),
        .alu_op_sel(dp_alu_op_sel),
        .alu_b_src_sel(dp_alu_b_src_sel),
        // .imm_sign_extend_sel(dp_imm_sign_extend_sel), // Removed
        .instruction_in(instruction_from_mem),
        .pc_out_addr(pc_to_mem_addr),
        .opcode_out(opcode_to_cu),
        .ir_field_target_reg_out(ir_target_reg_to_cu),
        .zero_flag_out(zero_flag_to_cu),
        .negative_flag_out(negative_flag_to_cu),
        .r0_debug_out(dp_r0_debug_out),
        .r1_debug_out(dp_r1_debug_out),
        .ir_debug_out(dp_ir_debug_out)
    );

    control_unit control_unit_inst (
        .clk(clk),
        .reset_n(reset_n),
        .opcode_in(opcode_to_cu),
        .rd_addr_in(ir_target_reg_to_cu), // This is IR[27:25]
        .zero_flag_in(zero_flag_to_cu),
        .pc_write_enable(dp_pc_write_enable),
        .pc_source_sel(dp_pc_source_sel),
        .ir_write_enable(dp_ir_write_enable),
        .rf_write_enable(dp_rf_write_enable),
        .rf_write_dest_sel_addr(dp_rf_write_dest_sel_addr),
        .rf_write_data_sel(dp_rf_write_data_sel),
        .alu_op_sel(dp_alu_op_sel),
        .alu_b_src_sel(dp_alu_b_src_sel)
        // .imm_sign_extend_sel(dp_imm_sign_extend_sel) // Removed
    );

    assign current_pc_debug = pc_to_mem_addr;
    // Show IR in EXECUTE state, otherwise it's fetching garbage before IR latch
    assign current_instr_debug = (control_unit_inst.current_state == control_unit_inst.S_EXECUTE) ? dp_ir_debug_out : 32'hDEADBEEF;
    assign r0_val_debug = dp_r0_debug_out;
    assign r1_val_debug = dp_r1_debug_out;
    assign r7_lr_val_debug = datapath_inst.reg_file_inst.registers[7];

endmodule
