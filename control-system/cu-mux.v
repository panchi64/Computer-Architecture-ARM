module cu_mux (
    // Input control signals
    input wire reg_write_enable_in,   // Register write enable input
    input wire mem_write_enable_in,   // Memory write enable input
    input wire mem_to_reg_select_in,  // Memory to register select input
    input wire alu_src_in,            // ALU source select input
    input wire status_bit_in,         // Status bits input
    input wire [1:0] alu_control_in,  // ALU control input
    input wire pc_src_select_in,      // PC source select input
    input wire mux_select,            // Multiplexer select bit input
    
    // Output control signals - fixed variable names
    output reg reg_write_enable_out,   // Register write enable output
    output reg mem_write_enable_out,   // Memory write enable output
    output reg mem_to_reg_select_out,  // Memory to register select output
    output reg alu_src_select_out,     // ALU source select output
    output reg [1:0] status_bits_out,  // Status bits output
    output reg [1:0] alu_control_out,  // ALU control output
    output reg pc_src_select_out       // PC source select output
);

    always @(*) begin
        if (mux_select) begin
            // If S_bit, pass through all control signals
            reg_write_enable_out = reg_write_enable_in;
            mem_write_enable_out = mem_write_enable_in;
            mem_to_reg_select_out = mem_to_reg_select_in;
            alu_src_select_out = alu_src_in;
            status_bits_out = status_bit_in;
            alu_control_out = alu_control_in;
            pc_src_select_out = pc_src_select_in;
        end else begin
            // If no S_bit, clear all control signals
            reg_write_enable_out = 0;
            mem_write_enable_out = 0;
            mem_to_reg_select_out = 0;
            alu_src_select_out = 0;
            status_bits_out = 0;
            alu_control_out = 2'b00;
            pc_src_select_out = 0;
        end
    end

endmodule