module mem_stage (
    // Clock and control
    input wire clk,
    input wire reset,
    
    // Control signals from EX/MEM pipeline register
    input wire mem_enable,
    input wire mem_rw,        // 0 = read, 1 = write
    input wire mem_size,      // 0 = byte, 1 = word
    input wire mem_to_reg_select,
    
    // Data inputs
    input wire [31:0] alu_result,     // Address from ALU
    input wire [31:0] write_data,     // Data to write to memory
    
    // Forwarding inputs
    input wire [1:0] forward_select,  // Forwarding control
    input wire [31:0] ex_forwarded_data,
    input wire [31:0] mem_forwarded_data,
    input wire [31:0] wb_forwarded_data,
    
    // Outputs
    output wire [31:0] mem_result,    // Data read from memory
    output wire [31:0] final_result   // Selected result (mem or ALU)
);

    // Internal wires
    wire [31:0] selected_write_data;
    wire [31:0] memory_read_data;

    // Forwarding multiplexer for write data
    id_forwarding_mux write_data_mux (
        .reg_data(write_data),
        .ex_forwarded_data(ex_forwarded_data),
        .mem_forwarded_data(mem_forwarded_data),
        .wb_forwarded_data(wb_forwarded_data),
        .forward_select(forward_select),
        .selected_data(selected_write_data)
    );

    // Data memory instance
    data_memory dmem (
        .DO(memory_read_data),         // Data output
        .DI(selected_write_data),      // Data input
        .A(alu_result[7:0]),          // Address (8-bit)
        .Size(mem_size),              // Size control
        .RW(mem_rw),                  // Read/Write control
        .E(mem_enable)                // Enable signal
    );

    // Assign memory result
    assign mem_result = memory_read_data;

    // Final result multiplexer
    assign final_result = mem_to_reg_select ? memory_read_data : alu_result;

endmodule