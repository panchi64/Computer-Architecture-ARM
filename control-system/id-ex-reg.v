module id_ex_reg (
    input wire clk,                      // Clock input
    input wire reset,                    // Reset signal
    
    // Control signals input
    input wire reg_write_enable_in,      // Register write enable
    input wire mem_write_enable_in,      // Memory write enable
    input wire mem_to_reg_select_in,     // Memory to register select
    input wire alu_src_select_in,        // ALU source select
    input wire [1:0] alu_control_in,     // ALU operation control
    input wire [31:0] ext_imm_in,        // Extended immediate value
    
    // Control signals output
    output reg reg_write_enable_out,     // Register write enable
    output reg mem_write_enable_out,     // Memory write enable
    output reg mem_to_reg_select_out,    // Memory to register select
    output reg alu_src_select_out,       // ALU source select
    output reg [1:0] alu_control_out,    // ALU operation control
    output reg [31:0] ext_imm_out        // Extended immediate value
);

    always @(posedge clk) begin
        if (reset) begin
            // Reset all control signals
            reg_write_enable_out <= 0;
            mem_write_enable_out <= 0;
            mem_to_reg_select_out <= 0;
            alu_src_select_out <= 0;
            alu_control_out <= 2'b0;
            ext_imm_out <= 32'b0;
        end
        else begin
            // Update control signals
            reg_write_enable_out <= reg_write_enable_in;
            mem_write_enable_out <= mem_write_enable_in;
            mem_to_reg_select_out <= mem_to_reg_select_in;
            alu_src_select_out <= alu_src_select_in;
            alu_control_out <= alu_control_in;
            ext_imm_out <= ext_imm_in;
        end
    end

endmodule