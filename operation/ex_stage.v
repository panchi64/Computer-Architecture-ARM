// Branch Target Calculator
module branch_calc(
    input wire [31:0] pc_plus_4,
    input wire [31:0] immediate,
    input wire [31:0] reg_data,      
    input wire [1:0] branch_type,    
    output reg [31:0] branch_target
);
    always @(*) begin
        case(branch_type)
            2'b00: branch_target = pc_plus_4 + (immediate << 2);  // PC-relative
            2'b01: branch_target = reg_data;                      // Register
            default: branch_target = pc_plus_4;
        endcase
    end
endmodule

// Condition Check Module
module condition_check(
    input wire [3:0] cond,        // Condition field from instruction
    input wire [3:0] flags,       // ALU flags (N,Z,C,V)
    output reg condition_passed   // Whether condition is met
);
    always @(*) begin
        case(cond)
            4'b0000: condition_passed = flags[2];                    // EQ
            4'b0001: condition_passed = !flags[2];                   // NE
            4'b0010: condition_passed = flags[1];                    // CS/HS
            4'b0011: condition_passed = !flags[1];                   // CC/LO
            4'b0100: condition_passed = flags[3];                    // MI
            4'b0101: condition_passed = !flags[3];                   // PL
            4'b0110: condition_passed = flags[0];                    // VS
            4'b0111: condition_passed = !flags[0];                   // VC
            4'b1000: condition_passed = flags[1] & !flags[2];        // HI
            4'b1001: condition_passed = !flags[1] | flags[2];        // LS
            4'b1010: condition_passed = flags[3] == flags[0];        // GE
            4'b1011: condition_passed = flags[3] != flags[0];        // LT
            4'b1100: condition_passed = !flags[2] & (flags[3] == flags[0]); // GT
            4'b1101: condition_passed = flags[2] | (flags[3] != flags[0]);  // LE
            4'b1110: condition_passed = 1'b1;                        // AL
            default: condition_passed = 1'b0;
        endcase
    end
endmodule

// Execute Stage Module
module execute_stage(
    input wire clk,
    input wire reset,
    
    // Control signals from ID/EX
    input wire [3:0] alu_operation,  // Direct from control unit, no need for translation
    input wire [1:0] branch_type,
    input wire [3:0] condition,
    
    // Data inputs
    input wire [31:0] operand_a,
    input wire [31:0] operand_b,
    input wire [31:0] pc_plus_4,
    input wire [31:0] immediate,
    input wire [31:0] reg_data,
    input wire CIN,              // Added for ADC/SBC instructions
    
    // Forwarding inputs
    input wire [31:0] forward_ex_mem,
    input wire [31:0] forward_mem_wb,
    input wire [1:0] forward_sel_a,
    input wire [1:0] forward_sel_b,
    
    // Outputs
    output wire [31:0] alu_result,
    output wire [31:0] branch_target,
    output wire [3:0] flags,     // {N,Z,C,V}
    output wire branch_taken
);

    // Internal wires
    wire [31:0] alu_input_a, alu_input_b;
    wire condition_result;
    
    // Input Forwarding Muxes
    id_forwarding_mux forward_mux_a(
        .reg_data(operand_a),
        .ex_forwarded_data(forward_ex_mem),
        .mem_forwarded_data(forward_mem_wb),
        .wb_forwarded_data(32'b0),
        .forward_select(forward_sel_a),
        .selected_data(alu_input_a)
    );
    
    id_forwarding_mux forward_mux_b(
        .reg_data(operand_b),
        .ex_forwarded_data(forward_ex_mem),
        .mem_forwarded_data(forward_mem_wb),
        .wb_forwarded_data(32'b0),
        .forward_select(forward_sel_b),
        .selected_data(alu_input_b)
    );
    
    // ALU
    ALU alu_unit(
        .A(alu_input_a),
        .B(alu_input_b),
        .CIN(CIN),
        .Op(alu_operation),     // Direct from control unit
        .Out(alu_result),
        .Z(flags[2]),
        .N(flags[3]),
        .C(flags[1]),
        .V(flags[0])
    );
    
    // Branch Target Calculator
    branch_calc branch_calc_unit(
        .pc_plus_4(pc_plus_4),
        .immediate(immediate),
        .reg_data(reg_data),
        .branch_type(branch_type),
        .branch_target(branch_target)
    );
    
    // Condition Check
    condition_check cond_check(
        .cond(condition),
        .flags(flags),
        .condition_passed(branch_taken)
    );

endmodule