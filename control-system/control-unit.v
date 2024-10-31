module control_unit (
    input wire [31:0] instruction,          // Input instruction to decode
    
    // Control signals outputs
    output reg        reg_write_enable,     // Register file write enable
    output reg        mem_write_enable,     // Memory write enable
    output reg        mem_read_enable,      // Memory read enable
    output reg        mem_to_reg_select,    // Select between ALU result and memory data
    output reg        alu_source_select,    // Select between register and immediate
    output reg        status_bit,           // Status bit for condition flags
    output reg [3:0]  alu_operation,        // ALU operation control
    output reg        pc_source_select,      // Program counter source selection for branches
    output reg        mem_size              // Memory access size (1: word, 0: byte)
);

    // Instruction field extraction
    wire [3:0] condition_code = instruction[31:28];  // Condition field
    wire [1:0] operation_type = instruction[27:26];  // Determines instruction type
    wire immediate_flag = instruction[25];           // Immediate operand flag
    wire [3:0] opcode = instruction[24:21];          // Operation code
    wire byte_access = instruction[22];              // B bit for byte access
    wire s_bit = instruction[20];                    // Status bit flag
    
    // Instruction type parameters
    localparam DATA_PROCESSING = 2'b00;
    localparam LOAD_STORE = 2'b01;
    localparam BRANCH = 2'b10;

    initial begin
        reg_write_enable = 0;
        mem_write_enable = 0;
        mem_read_enable = 0;
        mem_to_reg_select = 0;
        alu_source_select = 0;
        status_bit = 0;
        alu_operation = 4'b0000;
        pc_source_select = 0;
        mem_size = 0;
    end

    always @(*) begin
        // Default values
        reg_write_enable = 0;
        mem_write_enable = 0;
        mem_read_enable = 0;
        mem_to_reg_select = 0;
        alu_source_select = 0;
        status_bit = 0;
        alu_operation = 4'b0000;
        pc_source_select = 0;
        mem_size = 0;

        case (operation_type)
            DATA_PROCESSING: begin
                reg_write_enable = 1;
                alu_operation = opcode;
                status_bit = s_bit;
                alu_source_select = immediate_flag;
            end

            LOAD_STORE: begin
                mem_to_reg_select = 1;
                alu_source_select = 1;  // Use immediate offset
                mem_size = byte_access; // Set the size based on B bit
                
                case (instruction[20])  // Load/Store bit
                    1'b1: begin  // LDRB
                        reg_write_enable = 1;
                        mem_read_enable = 1;
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
                alu_operation = opcode;
            end
        endcase
        
        // Override for NOP (detected by all zeros)
        if (instruction == 32'b0) begin
            reg_write_enable = 0;
            mem_write_enable = 0;
            mem_read_enable = 0;
            mem_to_reg_select = 0;
            alu_source_select = 0;
            status_bit = 0;
            alu_operation = 4'b0000;
            pc_source_select = 0;
            mem_size = 0;
        end
    end

endmodule