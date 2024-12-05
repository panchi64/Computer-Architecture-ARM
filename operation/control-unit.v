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
    output reg [1:0]  addressing_mode       // Output for addressing mode
);

// Instruction field extraction
wire [3:0] condition_code = instruction[31:28];  // Condition field
wire [1:0] operation_type = instruction[27:26];  // Determines instruction type
wire immediate_flag = instruction[25];           // I bit: 0=immediate/immediate offset, 1=register
wire [3:0] opcode = instruction[24:21];          // Operation code
wire u_bit = instruction[23];                    // Add/Subtract offset
wire b_bit = instruction[22];                    // Byte/Word operation
wire l_bit = instruction[20];                    // Load=1/Store=0 for load/store OR Status bit for data proc
wire [3:0] rn = instruction[19:16];              // Base register
wire [3:0] rd = instruction[15:12];              // Destination register
wire [7:0] shift_amount = instruction[11:4];     // Shift amount
wire [1:0] shift_type = instruction[6:5];        // Type of shift to apply

// Instruction type parameters
localparam DATA_PROCESSING = 2'b00;
localparam LOAD_STORE = 2'b01;
localparam BRANCH = 2'b10;

// Addressing Mode parameters
localparam AM_IMMEDIATE    = 2'b00;    // Immediate operand
localparam AM_SCALED_REG   = 2'b11;    // Scaled register
localparam AM_IMM_OFFSET   = 2'b10;    // Immediate offset for load/store
localparam AM_REG_OFFSET   = 2'b01;    // Register offset for load/store

// ALU Operation Mapping/Translations
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

// Control Unit Opcode Mapping/Translations
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
    addressing_mode = AM_IMMEDIATE;  // Default to data processing immediate

    case (operation_type)
        DATA_PROCESSING: begin
            reg_write_enable = 1;
            alu_operation = map_alu_op(opcode);
            status_bit = l_bit;  // bit 20 is S bit for data processing
            
            if (immediate_flag) begin
                addressing_mode = AM_IMMEDIATE;      // I=1: Immediate operand
            end else begin
                                                     // I=0: Second operand is a register
                if (shift_amount)                   // If any shift amount bits are set
                    addressing_mode = AM_SCALED_REG; // Register with shift
                else
                    addressing_mode = AM_REG_OFFSET; // Register without shift
            end
            
            case (opcode)
                CU_TST, CU_TEQ, CU_CMP, CU_CMN: reg_write_enable = 0;
            endcase
        end

    LOAD_STORE: begin
        mem_enable = 1;
        alu_source_select = 1;
        mem_size = !b_bit;       // 0=byte (LDRB), 1=word (STR)
        
        if (l_bit) begin         // Load
            reg_write_enable = 1;
            mem_rw = 0;          
            mem_to_reg_select = 1;
            addressing_mode = AM_SCALED_REG;  // LDRB uses scaled register offset (11)
        end else begin           // Store
            mem_rw = 1;          
            addressing_mode = AM_IMM_OFFSET;  // STR uses immediate offset (10)
        end
    end

        BRANCH: begin
            pc_source_select = 1;
            alu_operation = ALU_ADD;     // For branch target calculation
        end
    endcase
    
    // NOP handling
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
