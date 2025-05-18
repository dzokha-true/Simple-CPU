module datapath (
    input clk,
    input rst_n,

    // Control signals from control_unit
    input reg_write_enable_ctrl,
    input [1:0] alu_op_select_ctrl,
    input alu_operand_b_select_ctrl,

    // Instruction fields
    input [1:0] rx_addr_instr,      // Destination register index
    input [1:0] ry_addr_instr,      // Source register Ry index
    input [7:0] immediate_instr,    // Immediate value from instruction

    // For HEX display
    input [1:0] display_reg_select, // Which register to display
    output [7:0] hex_display_data,   // Data for HEX0

    // For debugging (optional)
    output [7:0] r0_debug,
    output [7:0] r1_debug,
    output [7:0] r2_debug,
    output [7:0] r3_debug
);

    // Wires for internal connections
    wire [7:0] reg_operand_a_val; // Value from Rx (used as Operand A for ADD/XOR)
    wire [7:0] reg_operand_b_val; // Value from Ry
    wire [7:0] alu_operand_b_mux_out;
    wire [7:0] alu_result_out;

    // Instantiate Register File
    reg_file u_reg_file (
        .clk(clk),
        .rst_n(rst_n),
        .write_enable(reg_write_enable_ctrl),
        .write_addr_rx(rx_addr_instr),
        .read_addr_operand_a(rx_addr_instr),   // For ADD/XOR, Operand A is current Rx value
                                               // For LOAD/MOV, Operand A in ALU is not used if ALU op is PASS_B
        .read_addr_operand_b(ry_addr_instr),
        .write_data_in(alu_result_out),        // Result from ALU is written back

        .read_data_operand_a(reg_operand_a_val),
        .read_data_operand_b(reg_operand_b_val)
    );

    // MUX for ALU Operand B: Selects between Ry's value or Immediate value
    assign alu_operand_b_mux_out = (alu_operand_b_select_ctrl == 1'b1) ? immediate_instr : reg_operand_b_val;

    // Instantiate ALU
    alu u_alu (
        .operand_a(reg_operand_a_val),        // Operand A is always from Rx (read port A of reg_file)
        .operand_b(alu_operand_b_mux_out), // Operand B is from MUX (Ry or Immediate)
        .alu_op_select(alu_op_select_ctrl),
        .result(alu_result_out)
    );

    // HEX Display MUX (displays selected register content)
    // To do this properly, we need to read all 4 registers for display purposes.
    // A simpler reg_file could have more read ports, or we read one at a time.
    // For now, let's use the debug outputs from a slightly modified reg_file if needed,
    // or just grab them from the instantiated reg_file's internal registers (not good practice for synthesis but okay for sim).
    // A cleaner way: The reg_file itself could have a dedicated display_read_port.
    // Let's assume reg_file has debug outputs for simplicity here.
    assign r0_debug = u_reg_file.registers[0];
    assign r1_debug = u_reg_file.registers[1];
    assign r2_debug = u_reg_file.registers[2];
    assign r3_debug = u_reg_file.registers[3];
    
    assign hex_display_data = (display_reg_select == 2'b00) ? r0_debug :
                              (display_reg_select == 2'b01) ? r1_debug :
                              (display_reg_select == 2'b10) ? r2_debug :
                              (display_reg_select == 2'b11) ? r3_debug :
                              8'h00; // Default

endmodule
