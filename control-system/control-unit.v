module control_unit (
    input wire [31:0] instruction,          // Input instruction to decode
    
    // Control signals outputs
    output reg        reg_write_enable,     // Register file write enable
    output reg        mem_write_enable,     // Memory write enable
    output reg        mem_to_reg_select,    // Select between ALU result and memory data
    output reg        alu_source_select,    // Select between register and immediate
    output reg        status_bit,          // Status bits for condition flags
    output reg [1:0]  alu_operation,        // ALU operation control
    output reg        pc_source_select      // Program counter source selection for branches
);

    // Instruction field extraction
    wire [3:0] condition_code = instruction[31:28];  // Condition field
    wire [1:0] operation_type = instruction[27:26];  // Determines instruction type
    wire immediate_flag = instruction[25];           // Immediate operand flag
    wire [4:0] opcode = instruction[24:20];          // Operation code
    wire s_bit = instruction[20];                    // Status bit flag
    
    // Instruction type parameters
    localparam DATA_PROCESSING = 2'b00;
    localparam LOAD_STORE = 2'b01;
    localparam BRANCH = 2'b10;
    
    // ALU operations
    localparam ALU_AND = 2'b00;
    localparam ALU_ADD = 2'b01;
    localparam ALU_SUB = 2'b10;
    localparam ALU_LSL = 2'b11;  // Logical shift left

    initial begin
        reg_write_enable = 0;
        mem_write_enable = 0;
        mem_to_reg_select = 0;
        alu_source_select = 0;
        status_bit = 0;
        alu_operation = 2'b00;
        pc_source_select = 0;
    end

    always @(*) begin
        // Default values
        reg_write_enable = 0;
        mem_write_enable = 0;
        mem_to_reg_select = 0;
        alu_source_select = 0;
        status_bit = 0;
        alu_operation = ALU_ADD;
        pc_source_select = 0;

        case (operation_type)
            DATA_PROCESSING: begin
                case (opcode)  // Now only checking actual opcode
                    4'b0001: begin  // AND
                        reg_write_enable = 1;
                        alu_operation = ALU_AND;
                        status_bit = s_bit;  // Set status bits only if S-bit is 1
                        alu_source_select = immediate_flag;
                    end
                    4'b0000: begin  // ADD
                        reg_write_enable = 1;
                        alu_operation = ALU_ADD;
                        status_bit = s_bit;
                        alu_source_select = 0;  // Use register value
                    end
                    default: begin
                        // Default data processing
                        reg_write_enable = 1;
                        alu_operation = ALU_ADD;
                        status_bit = s_bit;
                    end
                endcase
            end

            LOAD_STORE: begin
                mem_to_reg_select = 1;
                alu_source_select = 1;  // Use immediate offset
                
                case (instruction[20])  // Load/Store bit
                    1'b1: begin  // LDRB
                        reg_write_enable = 1;
                        mem_to_reg_select = 1;
                    end
                    1'b0: begin  // STR
                        mem_write_enable = 1;
                        mem_to_reg_select = 0;
                    end
                endcase
            end

            BRANCH: begin
                pc_source_select = 1;
                // Branch condition handling
                case (condition_code)
                    4'b0001: begin  // BNE
                        // Branch logic will be handled by condition flags
                    end
                    4'b1101: begin  // BLLE
                        // Branch logic will be handled by condition flags
                    end
                endcase
            end
        endcase
        
        // Override for NOP (detected by all zeros)
        if (instruction == 32'b0) begin
            reg_write_enable = 0;
            mem_write_enable = 0;
            mem_to_reg_select = 0;
            alu_source_select = 0;
            status_bit = 0;
            alu_operation = ALU_AND;  // Set to default ALU_AND (00) for NOP
            pc_source_select = 0;
        end
    end

endmodule