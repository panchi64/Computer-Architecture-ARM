module cu_mux (
    // Input control signals
    input wire reg_write_enable_in,   // Register write enable input
    input wire mem_write_enable_in,   // Memory write enable input
    input wire mem_read_enable_in,    // Memory read enable input
    input wire mem_to_reg_select_in,  // Memory to register select input
    input wire alu_src_in,            // ALU source select input
    input wire status_bit_in,         // Status bits input
    input wire [3:0] alu_control_in,  // ALU control input
    input wire pc_src_select_in,      // PC source select input
    input wire mem_size_in,           // Memory size input
    input wire mux_select,            // Multiplexer select bit input
    
    // Output control signals - fixed variable names
    output reg reg_write_enable_out,   // Register write enable output
    output reg mem_write_enable_out,   // Memory write enable output
    output reg mem_read_enable_out,    // Memory read enable output
    output reg mem_to_reg_select_out,  // Memory to register select output
    output reg alu_src_select_out,     // ALU source select output
    output reg status_bit_out,         // Status bit output
    output reg [3:0] alu_control_out,  // ALU control output
    output reg pc_src_select_out,       // PC source select output
    output reg mem_size_out            // NEW: Memory size output
);

    initial begin
        reg_write_enable_out = 0;
        mem_write_enable_out = 0;
        mem_read_enable_out = 0;
        mem_to_reg_select_out = 0;
        alu_src_select_out = 0;
        status_bit_out = 0;
        alu_control_out = 4'b0000;
        pc_src_select_out = 0;
        mem_size_out = 0;
    end

    always @(*) begin
        if (!mux_select) begin
            // If S_bit, pass through all control signals
            reg_write_enable_out = reg_write_enable_in;
            mem_write_enable_out = mem_write_enable_in;
            mem_read_enable_out = mem_read_enable_in;
            mem_to_reg_select_out = mem_to_reg_select_in;
            alu_src_select_out = alu_src_in;
            status_bit_out = status_bit_in;
            alu_control_out = alu_control_in;
            pc_src_select_out = pc_src_select_in;
            mem_size_out = mem_size_in;
        end else begin
            // If no S_bit, clear all control signals
            reg_write_enable_out = 0;
            mem_write_enable_out = 0;
            mem_read_enable_out = 0;
            mem_to_reg_select_out = 0;
            alu_src_select_out = 0;
            status_bit_out = 0;
            alu_control_out = 4'b0000;
            pc_src_select_out = 0;
            mem_size_out = 0;
        end
    end

endmodule