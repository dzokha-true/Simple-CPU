`timescale 1ns / 1ps

module tb_cpu_top;

    reg clk;
    reg reset_n;

    wire [7:0]  current_pc_debug;
    wire [31:0] current_instr_debug; // Changed to 32-bit
    wire [15:0] r0_val_debug;
    wire [15:0] r1_val_debug;
    wire [15:0] r7_lr_val_debug;

    cpu_top uut (
        .clk(clk),
        .reset_n(reset_n),
        .current_pc_debug(current_pc_debug),
        .current_instr_debug(current_instr_debug),
        .r0_val_debug(r0_val_debug),
        .r1_val_debug(r1_val_debug),
        .r7_lr_val_debug(r7_lr_val_debug)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        reset_n = 0; #20; reset_n = 1;
        #500; // Increased time to allow program to run further

        $display("Simulation End at t=%0t", $time);
        $display("PC = %h", current_pc_debug);
        $display("R0 = %h (%d)", r0_val_debug, r0_val_debug);
        $display("R1 = %h (%d)", r1_val_debug, r1_val_debug);
        $display("R3 = %h", uut.datapath_inst.reg_file_inst.registers[3]);
        $display("R4 = %h", uut.datapath_inst.reg_file_inst.registers[4]);
        $display("R5 = %h", uut.datapath_inst.reg_file_inst.registers[5]);
        $display("R7(LR) = %h", r7_lr_val_debug);
        
        // Expected values from the new program in instruction_memory.v:
        // R0 = 5000 (0x1388) + 1000 (0x03E8) = 6000 (0x1770)
        // R1 = 1000 (0x03E8)
        // R3 = 0xABCD
        // R4 = 0xFFEE (after CALL/RET)
        // R5 = 0xBEEF (in subroutine)
        // R7 (LR) = PC of (LOAD R4) = 7 (after CALL to addr 10, PC_CALL=6, LR=(6+1)=7)
        // PC at end: 8 (stuck in JMP to self)

        if (current_pc_debug === 8'h08 &&
            r0_val_debug    === 16'h1770 && // 6000
            r1_val_debug    === 16'h03E8 && // 1000
            uut.datapath_inst.reg_file_inst.registers[3] === 16'hABCD &&
            uut.datapath_inst.reg_file_inst.registers[4] === 16'hFFEE &&
            uut.datapath_inst.reg_file_inst.registers[5] === 16'hBEEF &&
            r7_lr_val_debug === 16'h0007) begin
            $display("PASS: Expected register values match.");
        end else begin
            $display("FAIL: Register values mismatch.");
            $display("Expected PC=08, R0=1770, R1=03E8, R3=ABCD, R4=FFEE, R5=BEEF, LR(R7)=07");
        end

        $finish;
    end

    initial begin
        $monitor("T=%0t PC=%h IR=%h | R0=%h R1=%h R2=%h R3=%h R4=%h R5=%h R6=%h R7(LR)=%h | Z=%b",
                 $time, current_pc_debug, current_instr_debug,
                 r0_val_debug, r1_val_debug,
                 uut.datapath_inst.reg_file_inst.registers[2],
                 uut.datapath_inst.reg_file_inst.registers[3],
                 uut.datapath_inst.reg_file_inst.registers[4],
                 uut.datapath_inst.reg_file_inst.registers[5],
                 uut.datapath_inst.reg_file_inst.registers[6],
                 r7_lr_val_debug,
                 uut.datapath_inst.zero_flag_out
        );
    end
endmodule
