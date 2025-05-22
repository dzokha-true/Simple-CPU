module simple_processor (
    input clk,
    input rst_n, 
	 input[31:0] data
);

    // Instruction Format: OpCode [31:28 | Address [27:24] | Ra [23:20] | Rb [19:16] | Data [15:0] |
    // Opcodes
    localparam OP_LOAD = 4'b0000;
    localparam OP_MOV  = 4'b0001;
    localparam OP_XOR  = 4'b0010;
    localparam OP_ADD  = 4'b0011;
    // localparam OP_LDPC = 4'b0100; // For later
    // localparam OP_BRANCH = 4'b0101; // For later

    // Program Counters
    reg [7:0] pc; // Assuming up to 256 instructions for now (8-bit address)
    wire [7:0] next_pc;

    // Instruction Register
    reg [31:0] ir; // Holds the current instruction

    // Decoded instruction fields
    wire [31:28] opcode
	 wire [27:24] address    
    wire [23:20] ra; //rx_address
    wire [19:16] rb; //ry_address
    wire [15:0] data; //

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

    // Initialize Instruction Memory 
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
	 
endmodule


        4'h1: segments = 7'b1111001; // 1
        // ... (complete as above) ...
        4'hF: segments = 7'b0001110; // F
        default: segments = 7'b1111111; // Off
    endcase
end
endmodule
*/
