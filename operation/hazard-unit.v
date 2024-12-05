module HazardUnit (
    // Forwarding control outputs
    output reg [1:0] ISA,        // Forwarding signal for source operand A
    output reg [1:0] ISB,        // Forwarding signal for source operand B
    output reg [1:0] ISC,        // Forwarding signal for source operand C
    
    // Pipeline control outputs
    output reg stall_pipeline,   // Signal to stall the pipeline
    output reg flush_pipeline,   // Signal to flush the pipeline on branch taken
    
    // Register addresses
    input [3:0] RW_EX,          // Destination register in EX stage
    input [3:0] RW_MEM,         // Destination register in MEM stage
    input [3:0] RW_WB,          // Destination register in WB stage
    input [3:0] RA_ID,          // Source register A in ID stage
    input [3:0] RB_ID,          // Source register B in ID stage
    input [3:0] RC_ID,          // Source register C in ID stage
    
    // Control signals
    input enable_LD_EX,         // Load instruction in EX stage
    input enable_RF_EX,         // Register file write in EX stage
    input enable_RF_MEM,        // Register file write in MEM stage
    input enable_RF_WB,         // Register file write in WB stage
    input branch_taken,         // Indicates if branch is taken
    input branch_ID             // Branch instruction in ID stage
);

    // Forwarding logic with explicit priority
    always @(*) begin
        // Default: no forwarding
        ISA = 2'b00;
        ISB = 2'b00;
        ISC = 2'b00;
        
        // Source A forwarding
        if (enable_RF_EX && RW_EX != 4'b0 && RW_EX == RA_ID)
            ISA = 2'b01;    // Forward from EX stage
        else if (enable_RF_MEM && RW_MEM != 4'b0 && RW_MEM == RA_ID)
            ISA = 2'b10;    // Forward from MEM stage
        else if (enable_RF_WB && RW_WB != 4'b0 && RW_WB == RA_ID)
            ISA = 2'b11;    // Forward from WB stage
            
        // Source B forwarding
        if (enable_RF_EX && RW_EX != 4'b0 && RW_EX == RB_ID)
            ISB = 2'b01;
        else if (enable_RF_MEM && RW_MEM != 4'b0 && RW_MEM == RB_ID)
            ISB = 2'b10;
        else if (enable_RF_WB && RW_WB != 4'b0 && RW_WB == RB_ID)
            ISB = 2'b11;
            
        // Source C forwarding
        if (enable_RF_EX && RW_EX != 4'b0 && RW_EX == RC_ID)
            ISC = 2'b01;
        else if (enable_RF_MEM && RW_MEM != 4'b0 && RW_MEM == RC_ID)
            ISC = 2'b10;
        else if (enable_RF_WB && RW_WB != 4'b0 && RW_WB == RC_ID)
            ISC = 2'b11;
    end

    // Load-use hazard detection
    always @(*) begin
        stall_pipeline = 1'b0;
        
        // Stall if load instruction in EX stage and its destination register
        // is needed by instruction in ID stage
        if (enable_LD_EX && RW_EX != 4'b0 && 
            (RW_EX == RA_ID || RW_EX == RB_ID || RW_EX == RC_ID)) begin
            stall_pipeline = 1'b1;
        end
    end

    // Branch handling
    always @(*) begin
        flush_pipeline = 1'b0;
        
        // Flush pipeline on branch taken
        if (branch_ID && branch_taken) begin
            flush_pipeline = 1'b1;
        end
    end

endmodule