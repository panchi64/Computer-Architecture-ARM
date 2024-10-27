module if_id_register(
    input wire clk,
    input wire reset,
    input wire E,              // Load enable signal
    input wire [31:0] instr_in,    // Instruction from memory
    output reg [31:0] instr_out    // Instruction to ID stage
);

    // Rising edge triggered with synchronous reset
    always @(posedge clk) begin
        if (reset)
            instr_out <= 32'b0;    // Clear instruction on reset
        else if (E)               // Only load when enabled
            instr_out <= instr_in; // Latch new instruction
    end

endmodule