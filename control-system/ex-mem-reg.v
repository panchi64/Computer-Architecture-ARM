module ex_mem_reg (
    input wire clk,                  // Clock input
    input wire reset,                // Reset signal
    
    // Control signals input
    input wire reg_write_enable_in,  // Register write enable
    input wire mem_write_enable_in,  // Memory write enable
    
    // Control signals output
    output reg reg_write_enable_out,        // Register write enable
    output reg mem_write_enable_out,        // Memory write enable
);

    // On every clock edge or reset
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset control signals
            reg_write_enable_out <= 0;
            mem_write_enable_out <= 0;
        end
        else begin
            // Update control signals
            reg_write_enable_out <= reg_write_enable_in;
            mem_write_enable_out <= mem_write_enable_in;
        end
    end

endmodule