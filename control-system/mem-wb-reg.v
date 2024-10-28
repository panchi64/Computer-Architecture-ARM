module mem_wb_reg (
    input wire clk,                     // Clock input
    input wire reset,                   // Reset signal
    
    // Control signals input
    input wire reg_write_enable_in,     // Register write enable
    input wire mem_to_reg_select_in,    // Memory to register select
    
    // Control signals output
    output reg reg_write_enable_out,    // Register write enable
    output reg mem_to_reg_select_out    // Memory to register select
);

    always @(posedge clk) begin
        if (reset) begin
            // Reset control signals
            reg_write_enable_out <= 0;
            mem_to_reg_select_out <= 0;
        end
        else begin
            // Update control signals
            reg_write_enable_out <= reg_write_enable_in;
            mem_to_reg_select_out <= mem_to_reg_select_in;
            
        end
    end

endmodule