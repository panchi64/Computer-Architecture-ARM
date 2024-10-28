module if_id_reg(
    input wire clk,
    input wire reset,
    input wire enable,                   // Load enable signal
    input wire [31:0] instruction_in,    // Instruction from memory
    output reg [31:0] instruction_out    // Instruction to ID stage
);

    always @(posedge clk) begin
        if (reset)
            instruction_out <= 32'b0;           // Clear instruction on reset
        else if (enable)                             // Only load when enabled
            instruction_out <= instruction_in;  // Latch new instruction
    end

endmodule