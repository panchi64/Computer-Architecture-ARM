module wb_stage (
    // Control Signals
    input wire mem_to_reg_select,        // Selects between ALU result and memory data
    input wire reg_write_enable,         // Enable writing to register file
    
    // Data Inputs
    input wire [31:0] alu_result,       // Result from ALU
    input wire [31:0] mem_data,         // Data read from memory
    input wire [3:0] write_reg_addr,    // Register address to write to
    
    // Outputs
    output wire [31:0] write_data,      // Data to be written to register file
    output wire [3:0] write_reg_addr_out, // Register address output
    output wire reg_write_enable_out     // Register write enable output
);

    // Multiplexer to select between ALU result and memory data
    assign write_data = mem_to_reg_select ? mem_data : alu_result;
    
    // Pass through signals
    assign write_reg_addr_out = write_reg_addr;
    assign reg_write_enable_out = reg_write_enable;

endmodule