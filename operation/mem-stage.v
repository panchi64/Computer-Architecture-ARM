module mem_stage (
    // Clock and control
    input wire clk,
    input wire reset,
    
    // Control signals
    input wire E,              // Memory enable
    input wire RW,             // Read/Write control
    input wire Size,           // Byte/Word selection
    input wire mem_to_reg,     // MUX select for output
    
    // Data inputs
    input wire [31:0] AD,      // Address from ALU
    input wire [31:0] IN,      // Data to write
    
    // Output
    output wire [31:0] Out     // Final stage output
);

    // Internal wire for memory output
    wire [31:0] mem_out;

    // Data memory instance
    data_memory dmem (
        .DO(mem_out),          // Data output
        .DI(IN),              // Data input
        .A(AD[7:0]),         // Address (8-bit)
        .Size(Size),         // Size control
        .RW(RW),             // Read/Write control
        .E(E)                // Enable signal
    );

    // Output multiplexer (select between memory output and ALU result)
    assign Out = mem_to_reg ? mem_out : AD;

endmodule