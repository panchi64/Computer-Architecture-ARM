module HazardUnit (
    output reg [1:0] ISA,        // Forwarding signal for source operand A
    output reg [1:0] ISB,        // Forwarding signal for source operand B
    output reg [1:0] ISC,        // Forwarding signal for source operand C
    output reg stall_pipeline,  // Signal to stall the pipeline (for load-use hazards)
    input [3:0] RW_EX,          // Destination register in EX stage
    input [3:0] RW_MEM,         // Destination register in MEM stage
    input [3:0] RW_WB,          // Destination register in WB stage
    input [3:0] RA_ID,          // Source register A in ID stage
    input [3:0] RB_ID,          // Source register B in ID stage
    input [3:0] RC_ID,          // Source register C in ID stage
    input enable_LD_EX,         // Indicates if instruction in EX is a LOAD
    input enable_RF_EX,         // Enables forwarding from EX stage
    input enable_RF_MEM,        // Enables forwarding from MEM stage
    input enable_RF_WB          // Enables forwarding from WB stage
);

    always @(*) begin
        // Default values
        ISA = 2'b00; // No forwarding for RA
        ISB = 2'b00; // No forwarding for RB
        ISC = 2'b00; // No forwarding for RC
        stall_pipeline = 1'b0; // No stall

        // Load-use hazard detection: Stall pipeline if EX is a LOAD
        if (enable_LD_EX && (RW_EX == RA_ID || RW_EX == RB_ID || RW_EX == RC_ID)) begin
            stall_pipeline = 1'b1; // Stall the pipeline
        end else begin
            // Data forwarding logic
            // Forwarding from WB stage
            if (enable_RF_WB) begin
                if (RW_WB == RA_ID) ISA = 2'b11; // Forward to RA
                if (RW_WB == RB_ID) ISB = 2'b11; // Forward to RB
                if (RW_WB == RC_ID) ISC = 2'b11; // Forward to RC
            end
            
            // Forwarding from MEM stage
            if (enable_RF_MEM) begin
                if (RW_MEM == RA_ID) ISA = 2'b10; // Forward to RA
                if (RW_MEM == RB_ID) ISB = 2'b10; // Forward to RB
                if (RW_MEM == RC_ID) ISC = 2'b10; // Forward to RC
            end

            // Forwarding from EX stage
            if (enable_RF_EX) begin
                if (RW_EX == RA_ID) ISA = 2'b01; // Forward to RA
                if (RW_EX == RB_ID) ISB = 2'b01; // Forward to RB
                if (RW_EX == RC_ID) ISC = 2'b01; // Forward to RC
            end
        end
    end
endmodule
