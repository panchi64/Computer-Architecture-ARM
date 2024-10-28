module program_counter(
    input wire clk,
    input wire reset,
    input wire enable,          // Enable signal mentioned in the requirements
    input wire [7:0] pc_next,   // Input from adder for potential branch
    output reg [7:0] pc_current // Current PC value
);

    // Rising edge triggered with synchronous reset
    always @(posedge clk) begin
        if (reset)
            pc <= 8'b0;        // Reset to address 0
        else if (E)           // Only update when enabled
            pc <= next_pc;    // Update to next instruction address
    end

endmodule