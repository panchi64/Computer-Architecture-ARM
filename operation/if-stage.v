module if_stage(
    input wire clk,
    input wire reset,
    input wire stall,                    // Stall signal from hazard unit
    input wire branch_taken,             // Branch taken signal
    input wire [31:0] branch_target,     // Branch target address
    
    output wire [31:0] instruction,      // Current instruction
    output wire [31:0] pc_plus_4,        // PC+4 value
    output wire [31:0] current_pc        // Current PC value (for monitoring)
);

    // Internal wires
    wire [31:0] next_pc;

    // Program Counter
    program_counter pc(
        .clk(clk),
        .reset(reset),
        .enable(~stall),           // Disable PC update when stalled
        .pc_next(next_pc),
        .pc_current(current_pc)
    );

    // PC Incrementer
    pc_incrementer pc_inc(
        .pc_current(current_pc),
        .pc_plus_4(pc_plus_4)
    );

    // Instruction Memory
    instruction_memory imem(
        .address(current_pc[7:0]),  // Using 8-bit address as per spec
        .instruction(instruction)
    );

    // PC Multiplexer (for branch handling)
    assign next_pc = branch_taken ? branch_target : pc_plus_4;

endmodule