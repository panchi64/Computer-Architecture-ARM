module control_unit (
    input wire [31:0] instruction,          // Input instruction to decode
    
    // Control signals outputs
    output reg        reg_write_enable,     // Register file write enable
    output reg        mem_enable,           // Memory enable
    output reg        mem_rw,               // Memory read/write
    output reg        mem_to_reg_select,    // Select between ALU result and memory data
    output reg        alu_source_select,    // Select between register and immediate
    output reg        status_bit,           // Status bit for condition flags
    output reg [3:0]  alu_operation,        // ALU operation control
    output reg        pc_source_select,     // Program counter source selection for branches
    output reg        mem_size,             // Memory access size (1: word, 0: byte)
    output reg [1:0]  addressing_mode      // Output for addressing mode
);

    // Instruction field extraction
    wire [3:0] condition_code = instruction[31:28];  // Condition field
    wire [1:0] operation_type = instruction[27:26];  // Determines instruction type
    wire immediate_flag = instruction[25];           // Immediate operand flag
    wire [3:0] opcode = instruction[24:21];          // Operation code
    wire s_bit = instruction[20];                    // Status bit flag
    wire shift_amount_type = instruction[4];         // Shift amount type (0: immediate, 1: register)
    
    // Instruction type parameters
    localparam DATA_PROCESSING = 2'b00;
    localparam LOAD_STORE = 2'b01;
    localparam BRANCH = 2'b10;

    // Addressing Mode parameters
    localparam AM_IMMEDIATE      = 2'b00;   // Immediate operand/offset
    localparam AM_REGISTER       = 2'b01;   // Register offset (Load/Store)
    localparam AM_SHIFT_IMM     = 2'b10;    // Shift by immediate (Data Processing)
    localparam AM_SHIFT_REG     = 2'b11;    // Shift by register (Data Processing)

    // ALU Operation Mapping
    localparam ALU_ADD     = 4'b0000;  // A + B
    localparam ALU_ADDC    = 4'b0001;  // A + B + CIN
    localparam ALU_SUB     = 4'b0010;  // A - B
    localparam ALU_SUBC    = 4'b0011;  // A - B - CIN
    localparam ALU_RSUB    = 4'b0100;  // B - A
    localparam ALU_RSUBC   = 4'b0101;  // B - A - CIN
    localparam ALU_AND     = 4'b0110;  // A and B
    localparam ALU_OR      = 4'b0111;  // A or B
    localparam ALU_XOR     = 4'b1000;  // A xor B
    localparam ALU_MOVA    = 4'b1001;  // A
    localparam ALU_MOVB    = 4'b1010;  // B
    localparam ALU_NOTB    = 4'b1011;  // not B
    localparam ALU_ANDNB   = 4'b1100;  // A and (not B)

    // Control Unit Opcode Mapping
    localparam CU_AND = 4'b0000;
    localparam CU_EOR = 4'b0001;
    localparam CU_SUB = 4'b0010;
    localparam CU_RSB = 4'b0011;
    localparam CU_ADD = 4'b0100;
    localparam CU_ADC = 4'b0101;
    localparam CU_SBC = 4'b0110;
    localparam CU_RSC = 4'b0111;
    localparam CU_TST = 4'b1000;
    localparam CU_TEQ = 4'b1001;
    localparam CU_CMP = 4'b1010;
    localparam CU_CMN = 4'b1011;
    localparam CU_ORR = 4'b1100;
    localparam CU_MOV = 4'b1101;
    localparam CU_BIC = 4'b1110;
    localparam CU_MVN = 4'b1111;

    initial begin
        reg_write_enable = 0;
        mem_enable = 0;
        mem_rw = 0;
        mem_to_reg_select = 0;
        alu_source_select = 0;
        status_bit = 0;
        alu_operation = 4'b0000;
        pc_source_select = 0;
        mem_size = 0;
    end

    // Function to map Control Unit opcode to ALU operation
    function [3:0] map_alu_op;
        input [3:0] cu_opcode;
        begin
            case (cu_opcode)
                CU_AND: map_alu_op = ALU_AND;       // AND -> A and B
                CU_EOR: map_alu_op = ALU_XOR;       // EOR -> A xor B
                CU_SUB: map_alu_op = ALU_SUB;       // SUB -> A - B
                CU_RSB: map_alu_op = ALU_RSUB;      // RSB -> B - A
                CU_ADD: map_alu_op = ALU_ADD;       // ADD -> A + B
                CU_ADC: map_alu_op = ALU_ADDC;      // ADC -> A + B + CIN
                CU_SBC: map_alu_op = ALU_SUBC;      // SBC -> A - B - CIN
                CU_RSC: map_alu_op = ALU_RSUBC;     // RSC -> B - A - CIN
                CU_TST: map_alu_op = ALU_AND;       // TST -> A and B (flags only)
                CU_TEQ: map_alu_op = ALU_XOR;       // TEQ -> A xor B (flags only)
                CU_CMP: map_alu_op = ALU_SUB;       // CMP -> A - B (flags only)
                CU_CMN: map_alu_op = ALU_ADD;       // CMN -> A + B (flags only)
                CU_ORR: map_alu_op = ALU_OR;        // ORR -> A or B
                CU_MOV: map_alu_op = ALU_MOVB;      // MOV -> B
                CU_BIC: map_alu_op = ALU_ANDNB;     // BIC -> A and (not B)
                CU_MVN: map_alu_op = ALU_NOTB;      // MVN -> not B
                default: map_alu_op = ALU_ADD;
            endcase
        end
    endfunction

    always @(*) begin
        // Default values
        reg_write_enable = 0;
        mem_enable = 0;
        mem_rw = 0;
        mem_to_reg_select = 0;
        alu_source_select = 0;
        status_bit = 0;
        alu_operation = 4'b0000;
        pc_source_select = 0;
        mem_size = 0;
        addressing_mode = AM_IMMEDIATE;


        case (operation_type)
            DATA_PROCESSING: begin
                reg_write_enable = 1;
                alu_operation = map_alu_op(opcode); // Map CU opcode to ALU operation
                status_bit = s_bit;
                alu_source_select = immediate_flag;

                // Determine addressing mode for Data Processing
                if (immediate_flag)
                    addressing_mode = AM_IMMEDIATE;      // Immediate operand
                else if (!shift_amount_type)
                    addressing_mode = AM_SHIFT_IMM;      // Shift by immediate
                else
                    addressing_mode = AM_SHIFT_REG;      // Shift by register
                
                // Handle test instructions (no register write)
                case (opcode)
                    CU_TST, CU_TEQ, CU_CMP, CU_CMN: reg_write_enable = 0;
                endcase
            end

            LOAD_STORE: begin
                mem_enable = 1;              
                mem_to_reg_select = 1;
                alu_source_select = 1;              // Use immediate offset

                // Determine addressing mode for Load/Store
                if (!immediate_flag)
                    addressing_mode = AM_IMMEDIATE; // Immediate offset
                else
                    addressing_mode = AM_REGISTER;  // Register offset
                
                if (mem_enable) begin
                    case (instruction[20])          // Load/Store bit
                        1'b1: begin  // LDRB
                            reg_write_enable = 1;
                            mem_rw = 0;             // Read operation
                            mem_to_reg_select = 1;
                            mem_size = 1'b0;        // Set to 0 for byte access
                        end
                        1'b0: begin  // STR
                            mem_rw = 1;             // Write operation
                            mem_to_reg_select = 0;
                            mem_size = 1'b0;        // Set to 0 for word access
                        end
                    endcase
                end
            end

            BRANCH: begin
                pc_source_select = 1;
                alu_operation = ALU_ADD;            // Use ADD for branch target calculation
            end
        endcase
        
        // Override for NOP (detected by all zeros)
        if (instruction == 32'b0) begin
            reg_write_enable = 0;
            mem_enable = 0;
            mem_rw = 0;
            mem_to_reg_select = 0;
            alu_source_select = 0;
            status_bit = 0;
            alu_operation = 4'b0000;
            pc_source_select = 0;
            mem_size = 0;
            addressing_mode = 2'b00;
        end
    end

endmodule
