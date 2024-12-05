module id_stage (
    input wire clk,
    input wire reset,
    
    // Inputs from IF/ID register
    input wire [31:0] instruction,         // Current instruction
    input wire [31:0] pc_plus_4_in,       // PC+4 from IF stage
    
    // Forwarding inputs
    input wire [31:0] ex_result,          // Result from EX stage
    input wire [31:0] mem_result,         // Result from MEM stage
    input wire [31:0] wb_result,          // Result from WB stage
    
    // Write-back inputs
    input wire [31:0] write_data,         // Data to write to register file
    input wire [3:0] write_reg,           // Register to write to
    input wire write_enable,              // Register write enable
    
    // Hazard detection inputs
    input wire [3:0] ex_destination_reg,  // Destination register in EX stage
    input wire [3:0] mem_destination_reg, // Destination register in MEM stage
    input wire [3:0] wb_destination_reg,  // Destination register in WB stage
    input wire ex_mem_read,               // Memory read in EX stage
    
    // Control outputs
    output wire reg_write_enable,         // Register write enable
    output wire mem_enable,               // Memory enable
    output wire mem_rw,                   // Memory read/write
    output wire mem_to_reg_select,        // Select between ALU and memory
    output wire alu_source_select,        // Select between register and immediate
    output wire [3:0] alu_operation,      // ALU operation control
    output wire status_bit,               // Status bit
    output wire mem_size,                 // Memory access size
    output wire [1:0] addressing_mode,    // Addressing mode
    
    // Data outputs
    output wire [31:0] reg_data_a,        // Register A data
    output wire [31:0] reg_data_b,        // Register B data
    output wire [31:0] reg_data_c,        // Register C data
    output wire [31:0] extended_immediate,// Extended immediate value
    output wire [3:0] destination_reg,    // Destination register
    
    // Pipeline control
    output wire stall_pipeline,           // Pipeline stall signal
    output wire flush_pipeline            // Pipeline flush signal
);

    // Extract register addresses from instruction
    wire [3:0] ra = instruction[19:16];   // First source register (Rn)
    wire [3:0] rb = instruction[15:12];   // Destination register (Rd)
    wire [3:0] rc = instruction[3:0];     // Second source register (Rm)
    
    // Forwarding control signals
    wire [1:0] forward_a, forward_b, forward_c;
    
    // Register file outputs before forwarding
    wire [31:0] rf_data_a, rf_data_b, rf_data_c;
    
    // Control Unit
    control_unit cu (
        .instruction(instruction),
        .reg_write_enable(reg_write_enable),
        .mem_enable(mem_enable),
        .mem_rw(mem_rw),
        .mem_to_reg_select(mem_to_reg_select),
        .alu_source_select(alu_source_select),
        .status_bit(status_bit),
        .alu_operation(alu_operation),
        .mem_size(mem_size),
        .addressing_mode(addressing_mode)
    );

    // Register File
    register_file rf (
        .PW(write_data),
        .RW(write_reg),
        .LE(write_enable),
        .CLK(clk),
        .RC(rc),
        .RB(rb),
        .RA(ra),
        .PROGCOUNT(pc_plus_4_in),
        .PC(rf_data_c),
        .PB(rf_data_b),
        .PA(rf_data_a)
    );

    // Hazard Detection Unit
    HazardUnit hazard_unit (
        .ISA(forward_a),
        .ISB(forward_b),
        .ISC(forward_c),
        .stall_pipeline(stall_pipeline),
        .flush_pipeline(flush_pipeline),
        .RW_EX(ex_destination_reg),
        .RW_MEM(mem_destination_reg),
        .RW_WB(wb_destination_reg),
        .RA_ID(ra),
        .RB_ID(rb),
        .RC_ID(rc),
        .enable_LD_EX(ex_mem_read),
        .enable_RF_EX(reg_write_enable),
        .enable_RF_MEM(mem_enable),
        .enable_RF_WB(write_enable),
        .branch_taken(1'b0),  // Not handling branches in this example
        .branch_ID(1'b0)      // Not handling branches in this example
    );

    // Forwarding muxes
    id_forwarding_mux fwd_mux_a (
        .reg_data(rf_data_a),
        .ex_forwarded_data(ex_result),
        .mem_forwarded_data(mem_result),
        .wb_forwarded_data(wb_result),
        .forward_select(forward_a),
        .selected_data(reg_data_a)
    );

    id_forwarding_mux fwd_mux_b (
        .reg_data(rf_data_b),
        .ex_forwarded_data(ex_result),
        .mem_forwarded_data(mem_result),
        .wb_forwarded_data(wb_result),
        .forward_select(forward_b),
        .selected_data(reg_data_b)
    );

    id_forwarding_mux fwd_mux_c (
        .reg_data(rf_data_c),
        .ex_forwarded_data(ex_result),
        .mem_forwarded_data(mem_result),
        .wb_forwarded_data(wb_result),
        .forward_select(forward_c),
        .selected_data(reg_data_c)
    );

    // Shifter/Sign Extender
    ShifterSignExtender shifter (
        .Rm(rf_data_c),
        .I(instruction[11:0]),
        .AM(addressing_mode),
        .N(extended_immediate)
    );

    // Assign destination register
    assign destination_reg = rb;

endmodule