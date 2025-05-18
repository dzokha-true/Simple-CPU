module simple_processor (
    input clk,
    input rst_n, // Active low reset

    // For HEX display on FPGA
    input [3:0] SW, // Use SW[1:0] to select register for display
    output [6:0] HEX0_D, // For 7-segment display (raw segments)
    // If direct hex value output:
    output [7:0] processor_hex_out // For direct value to HEX display driver
);

    // Instruction Format: | Opcode [15:12] | Rx [11:10] | Ry [9:8] | Immediate [7:0] |
    // Opcodes
    localparam OP_LOAD = 4'b0000;
    localparam OP_MOV  = 4'b0001;
    localparam OP_ADD  = 4'b0010;
    localparam OP_XOR  = 4'b0011;
    // localparam OP_LDPC = 4'b0100; // For later
    // localparam OP_BRANCH = 4'b0101; // For later

    // Program Counter
    reg [7:0] pc; // Assuming up to 256 instructions for now (8-bit address)
    wire [7:0] next_pc;

    // Instruction Register
    reg [15:0] ir; // Holds the current instruction

    // Instruction Memory (RAM block)
    parameter MEM_DEPTH = 64; // Example: 64 instructions
    reg [15:0] instruction_memory[0:MEM_DEPTH-1];

    // Decoded instruction fields
    wire [3:0] opcode;
    wire [1:0] rx_addr;
    wire [1:0] ry_addr;
    wire [7:0] immediate_val;

    // Control signals
    wire reg_write_enable_sig;
    wire [1:0] alu_op_select_sig;
    wire alu_operand_b_select_sig;

    // Datapath outputs for display
    wire [7:0] hex_display_val_internal;
    wire [7:0] r0_val, r1_val, r2_val, r3_val; // Debug

    // Assign instruction fields from IR
    assign opcode        = ir[15:12];
    assign rx_addr       = ir[11:10];
    assign ry_addr       = ir[9:8];
    assign immediate_val = ir[7:0];

    // Instantiate Control Unit
    control_unit u_control_unit (
        .opcode(opcode),
        .reg_write_enable(reg_write_enable_sig),
        .alu_op_select(alu_op_select_sig),
        .alu_operand_b_select(alu_operand_b_select_sig)
    );

    // Instantiate Datapath
    datapath u_datapath (
        .clk(clk),
        .rst_n(rst_n),
        .reg_write_enable_ctrl(reg_write_enable_sig),
        .alu_op_select_ctrl(alu_op_select_sig),
        .alu_operand_b_select_ctrl(alu_operand_b_select_sig),
        .rx_addr_instr(rx_addr),
        .ry_addr_instr(ry_addr),
        .immediate_instr(immediate_val),
        .display_reg_select(SW[1:0]), // Use lower 2 switches
        .hex_display_data(hex_display_val_internal),
        .r0_debug(r0_val),
        .r1_debug(r1_val),
        .r2_debug(r2_val),
        .r3_debug(r3_val)
    );

    // Program Counter Logic
    // For now, PC simply increments. Branching will modify this.
    assign next_pc = pc + 1; // Assuming each instruction is 1 unit of address

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc <= 8'b0;
            ir <= 16'b0; // NOP (or default)
        end else begin
            // FETCH: Load instruction from memory pointed to by PC
            ir <= instruction_memory[pc];
            // EXECUTE happens combinationally through control and datapath
            // WRITEBACK happens in datapath's register file on same clock edge
            
            // UPDATE PC for next instruction
            pc <= next_pc;
        end
    end

    // Initialize Instruction Memory (Hardcode a simple program)
    initial begin
        // Program:
        // 0: LOAD R0, 5        (0000_00_xx_00000101) ; Rx=00, D=5
        // 1: LOAD R1, 10       (0000_01_xx_00001010) ; Rx=01, D=10
        // 2: ADD R0, R1        (0010_00_01_xxxxxxxx) ; Rx=00, Ry=01. R0 = R0+R1 = 5+10=15
        // 3: MOV R2, R0        (0001_10_00_xxxxxxxx) ; Rx=10(R2), Ry=00(R0). R2 = R0 = 15
        // 4: LOAD R3, 0xAA     (0000_11_xx_10101010) ; Rx=11(R3), D=0xAA
        // 5: XOR R2, R3        (0011_10_11_xxxxxxxx) ; Rx=10(R2), Ry=11(R3). R2 = R2^R3 = 15^0xAA
        // 6: NOP (implicit by going beyond or using an unassigned opcode)

        // Clear memory first (optional, good practice)
        integer j;
        for (j = 0; j < MEM_DEPTH; j = j + 1) begin
            instruction_memory[j] = 16'h0000; // Default to NOP or some safe instruction
        end

        // {Opcode, Rx, Ry, Immediate}
        instruction_memory[0] = {OP_LOAD, 2'b00, 2'b00, 8'd5};   // LOAD R0, 5
        instruction_memory[1] = {OP_LOAD, 2'b01, 2'b00, 8'd10};  // LOAD R1, 10
        instruction_memory[2] = {OP_ADD,  2'b00, 2'b01, 8'h00};  // ADD R0, R1 (R0=R0+R1)
        instruction_memory[3] = {OP_MOV,  2'b10, 2'b00, 8'h00};  // MOV R2, R0
        instruction_memory[4] = {OP_LOAD, 2'b11, 2'b00, 8'hAA};  // LOAD R3, 0xAA
        instruction_memory[5] = {OP_XOR,  2'b10, 2'b11, 8'h00};  // XOR R2, R3 (R2=R2^R3)
        // ... further instructions can be NOPs (e.g. 4'b1111 as opcode if control treats it as NOP)
        // or simply let pc run off into memory containing 0s if not initialized.
        // For safety, an explicit NOP opcode is better. Our default case in control_unit acts as NOP.
        instruction_memory[6] = 16'hFFFF; // Example of an undecoded instruction becoming NOP
    end

    // HEX Display output
    assign processor_hex_out = hex_display_val_internal;

    // 7-Segment Display Driver (Simple one, you might have a different one for your board)
    // This converts a 4-bit nibble to 7-segment. We need two for 8-bit data.
    seven_segment_hex LSB_HEX (
        .hex_digit(hex_display_val_internal[3:0]),
        .segments(HEX0_D_lower_4_bits) // Assign to part of HEX0_D if splitting
    );
    seven_segment_hex MSB_HEX (
        .hex_digit(hex_display_val_internal[7:4]),
        .segments(HEX0_D_upper_4_bits) // Assign to part of HEX0_D if splitting
    );
    // For a single HEX0 display, you'd typically cycle between nibbles or only show one.
    // For simplicity, let's assume HEX0_D expects the direct 8-bit value and converts it,
    // or we just output the lower 4 bits to one 7-seg.
    // The problem says "HEX(0) to display the contents", suggesting a single hex display group.
    // Let's assume it can show 2 hex digits (8 bits).
    // A common approach is to have a sub-module that converts 8-bit binary to two 4-bit BCD/HEX digits,
    // then drives two 7-segment displays, or a multi-digit display.
    // If HEX0_D is just one 7-segment display, we'd do something like:
    // seven_segment_hex hex_driver (.hex_digit(hex_display_val_internal[3:0]), .segments(HEX0_D)); // Shows LSB
    // The prompt "HEX(0) displays the hex value" implies it can show more than one digit.
    // Let's assume `processor_hex_out` is wired to a component that handles the 8-bit to multi-digit HEX display.
    // For the Altera DE-series boards, HEX0..HEX5 are typically groups of 7 segments.
    // We'll make a dummy 7-segment converter for simulation.

    // This is a placeholder. You'd use your board's specific 7-segment driver.
    // For now, we'll just output the raw 8-bit value.
    // To drive a 7-segment display like on DE0-CV (common anode):
    // 0=gfedcba, low is ON.
    reg [6:0] HEX0_D_internal; // For a single 7-segment display
    always @(*) begin
        case (hex_display_val_internal[3:0]) // Display lower nibble
            4'h0: HEX0_D_internal = 7'b1000000; // 0
            4'h1: HEX0_D_internal = 7'b1111001; // 1
            4'h2: HEX0_D_internal = 7'b0100100; // 2
            4'h3: HEX0_D_internal = 7'b0110000; // 3
            4'h4: HEX0_D_internal = 7'b0011001; // 4
            4'h5: HEX0_D_internal = 7'b0010010; // 5
            4'h6: HEX0_D_internal = 7'b0000010; // 6
            4'h7: HEX0_D_internal = 7'b1111000; // 7
            4'h8: HEX0_D_internal = 7'b0000000; // 8
            4'h9: HEX0_D_internal = 7'b0010000; // 9
            4'hA: HEX0_D_internal = 7'b0001000; // A
            4'hB: HEX0_D_internal = 7'b0000011; // b
            4'hC: HEX0_D_internal = 7'b1000110; // C
            4'hD: HEX0_D_internal = 7'b0100001; // d
            4'hE: HEX0_D_internal = 7'b0000110; // E
            4'hF: HEX0_D_internal = 7'b0001110; // F
            default: HEX0_D_internal = 7'b1111111; // Off or error
        endcase
    end
    assign HEX0_D = HEX0_D_internal; // Drive the actual 7-segment output

endmodule

// Dummy seven_segment_hex module for completeness if you used LSB_HEX/MSB_HEX above
/*
module seven_segment_hex (
    input [3:0] hex_digit,
    output reg [6:0] segments // gfedcba (0 is on for common anode)
);
always @(*) begin
    case (hex_digit)
        4'h0: segments = 7'b1000000; // 0
        4'h1: segments = 7'b1111001; // 1
        // ... (complete as above) ...
        4'hF: segments = 7'b0001110; // F
        default: segments = 7'b1111111; // Off
    endcase
end
endmodule
*/
