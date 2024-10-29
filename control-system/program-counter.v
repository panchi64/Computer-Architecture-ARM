module program_counter(
    input wire clk,
    input wire reset,
    input wire enable,           // Enable signal
    input wire [31:0] pc_next,   // Input from adder
    output reg [31:0] pc_current // Current PC value
);

    // Rising edge triggered with synchronous reset
    always @(posedge clk) begin
        if (reset)
            pc_current <= 32'b0;    // Reset to address 0
        else if (enable)            // Only update when enabled
            pc_current <= pc_next;  // Update to next instruction address
    end

endmodule