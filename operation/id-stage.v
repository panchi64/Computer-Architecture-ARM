module id_stage (
    input wire clk,
    input wire reset,
    
    // Inputs from IF/ID register
    input wire [31:0] instruction,         // Current instruction
    input wire [31:0] pc_plus_4_in,       // Next PC from IF stage
    input wire [31:0] current_pc_in,      // Current PC from IF stage
    
    // Forwarding inputs
    input wire [31:0] ex_result,          // Result from EX stage
    input wire [31:0] mem_result,         // Result from MEM stage
    input wire [31:0] wb_result,          // Result from WB stage
    
    // Write-back inputs
    input wire [31:0] write_data,         // Data to write to register file (PW)
    input wire [3:0] write_reg,           // Register to write to (RW)
    input wire write_enable,              // Register write enable (LE)
    
    // Hazard detection inputs
    input wire [3:0] ex_destination_reg,  
    input wire [3:0] mem_destination_reg, 
    input wire [3:0] wb_destination_reg,  
    input wire ex_mem_read,               
    
    // Control signals (matching diagram)
    output wire [3:0] D_ALU_op,                 // ALU operation control
    output wire D_load_instr,             // Load instruction indicator
    output wire D_RF_enable,              // Register file enable
    output wire D_mem_size,               // Memory access size
    output wire D_mem_readwrite,          // Memory read/write control
    output wire D_mem_enable,             // Memory enable
    output wire [1:0] D_am,               // Addressing mode
    output wire D_B_instr,                // Branch instruction indicator
    output wire D_BL_instr,               // Branch with link instruction
    output wire store_cc,                 // Store condition codes
    
    // Data path outputs (matching diagram)
    output wire [31:0] PA,                // Register A data output
    output wire [31:0] PB,                // Register B data output
    output wire [31:0] PD,                // Register D data output
    output wire [31:0] N,                 // Shifter/Sign extender output
    output wire B,                        // Branch signal
    output wire [3:0] CC,                 // Condition codes
    
    // Pipeline control
    output wire stall_pipeline,           // Pipeline stall signal
    output wire flush_pipeline            // Pipeline flush signal
);

    // Internal signals
    wire [3:0] RA = instruction[19:16];   // Source register A
    wire [3:0] RB = instruction[15:12];   // Source register B
    wire [3:0] RD = instruction[3:0];     // Destination register
    wire [1:0] forward_a, forward_b, forward_d;
    wire [31:0] rf_data_a, rf_data_b, rf_data_d;
    wire [3:0] condition = instruction[31:28];  // Condition field
    
    // Control Unit (expanded to match diagram signals)
    control_unit cu (
        .instruction(instruction),
        .reg_write_enable(D_RF_enable),
        .mem_enable(D_mem_enable),
        .mem_rw(D_mem_readwrite),
        .mem_size(D_mem_size),
        .alu_operation(D_ALU_op),
        .pc_source_select(D_B_instr),
        .status_bit(store_cc),
        .addressing_mode(D_am)
    );

    // Register File (matching diagram connections)
    register_file rf (
        .PW(write_data),            
        .RW(write_reg),             
        .LE(write_enable),          
        .CLK(clk),
        .RC(instruction[3:0]),      // Register C read address
        .RB(instruction[15:12]),    // Register B read address
        .RA(instruction[19:16]),    // Register A read address
        .PROGCOUNT(pc_plus_4_in),   // Program counter value
        .PC(PD),                    // Register C data output
        .PB(PB),                    // Register B data output
        .PA(PA)                     // Register A data output
    );

    // Hazard/Forwarding Unit (expanded for branch handling)
    HazardUnit hazard_unit (
        .ISA(forward_a),
        .ISB(forward_b),
        .ISC(forward_d),
        .stall_pipeline(stall_pipeline),
        .flush_pipeline(flush_pipeline),
        .RW_EX(ex_destination_reg),
        .RW_MEM(mem_destination_reg),
        .RW_WB(wb_destination_reg),
        .RA_ID(RA),
        .RB_ID(RB),
        .RC_ID(RD),
        .enable_LD_EX(ex_mem_read),
        .enable_RF_EX(D_RF_enable),
        .enable_RF_MEM(D_mem_enable),
        .enable_RF_WB(write_enable),
        .branch_taken(B),
        .branch_ID(D_B_instr || D_BL_instr)
    );

    // Forwarding muxes (matching diagram)
    id_forwarding_mux mux_a (
        .reg_data(rf_data_a),
        .ex_forwarded_data(ex_result),
        .mem_forwarded_data(mem_result),
        .wb_forwarded_data(wb_result),
        .forward_select(forward_a),
        .selected_data(PA)
    );

    id_forwarding_mux mux_b (
        .reg_data(rf_data_b),
        .ex_forwarded_data(ex_result),
        .mem_forwarded_data(mem_result),
        .wb_forwarded_data(wb_result),
        .forward_select(forward_b),
        .selected_data(PB)
    );

    id_forwarding_mux mux_d (
        .reg_data(rf_data_d),
        .ex_forwarded_data(ex_result),
        .mem_forwarded_data(mem_result),
        .wb_forwarded_data(wb_result),
        .forward_select(forward_d),
        .selected_data(PD)
    );

    // Shifter/Sign Extender (matching diagram)
    ShifterSignExtender shifter (
        .Rm(PD),                     // Using forwarded PD value
        .I(instruction[11:0]),
        .AM(D_am),
        .N(N)
    );

    // Condition Handler (new addition from diagram)
    condition_check cond_check (
        .cond(condition),
        .flags(CC),                  // Current condition codes
        .condition_passed(B)         // Branch taken signal
    );

endmodule