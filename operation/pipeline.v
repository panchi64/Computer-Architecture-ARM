module pipeline(
    input wire clk,
    input wire reset,
    output wire [31:0] PC_out
);
    // ---------- Control Signals ----------
    wire reg_write_enable, mem_enable, mem_rw, mem_to_reg_select;
    wire alu_source_select, status_bit, pc_source_select, mem_size;
    wire [3:0] alu_operation;
    wire [1:0] addressing_mode;

    // ---------- IF Stage ----------
    wire [31:0] PC_current, PC_next;
    wire [31:0] instruction;
    wire if_id_enable;

    // Program Counter
    program_counter pc(
        .clk(clk),
        .reset(reset),
        .enable(~stall_pipeline),
        .pc_next(PC_next),
        .pc_current(PC_current)
    );

    // Instruction Memory
    instruction_memory imem(
        .address(PC_current[7:0]),  // Using 8-bit address as per instruction_memory.v
        .instruction(instruction)
    );

    assign PC_next = pc_source_select ? branch_target : PC_current + 4;

    // ---------- IF/ID Pipeline Register ----------
    wire [31:0] instruction_id;
    wire [1:0] am_bits_if_id;

    if_id_reg if_id(
        .clk(clk),
        .reset(reset || flush_pipeline),
        .enable(~stall_pipeline),
        .instruction_in(instruction),
        .am_bits_in(addressing_mode),
        .instruction_out(instruction_id),
        .am_bits_out(am_bits_if_id)
    );

    // ---------- ID Stage ----------
    wire [3:0] ra_id = instruction_id[19:16];  // Rn
    wire [3:0] rb_id = instruction_id[15:12];  // Rd
    wire [3:0] rc_id = instruction_id[3:0];    // Rm

    // Control Unit
    control_unit cu(
        .instruction(instruction_id),
        .reg_write_enable(reg_write_enable),
        .mem_enable(mem_enable),
        .mem_rw(mem_rw),
        .mem_to_reg_select(mem_to_reg_select),
        .alu_source_select(alu_source_select),
        .status_bit(status_bit),
        .alu_operation(alu_operation),
        .pc_source_select(pc_source_select),
        .mem_size(mem_size),
        .addressing_mode(addressing_mode)
    );

    // ---------- Hazard Unit ----------
    wire [1:0] ISA, ISB, ISC;
    wire stall_pipeline, flush_pipeline;

    HazardUnit hazard_unit(
        .ISA(ISA),
        .ISB(ISB),
        .ISC(ISC),
        .stall_pipeline(stall_pipeline),
        .flush_pipeline(flush_pipeline),
        .RW_EX(rd_ex),
        .RW_MEM(rd_mem),
        .RW_WB(rd_wb),
        .RA_ID(ra_id),
        .RB_ID(rb_id),
        .RC_ID(rc_id),
        .enable_LD_EX(mem_enable_ex && ~mem_rw_ex),
        .enable_RF_EX(reg_write_enable_ex),
        .enable_RF_MEM(reg_write_enable_mem),
        .enable_RF_WB(reg_write_enable_wb),
        .branch_taken(branch_taken),
        .branch_ID(is_branch)
    );

    // ---------- ID/EX Pipeline Register ----------
    wire reg_write_enable_ex, mem_enable_ex, mem_rw_ex;
    wire mem_to_reg_select_ex, alu_src_select_ex;
    wire [3:0] alu_control_ex;
    wire status_bit_ex, mem_size_ex;
    wire [1:0] am_bits_ex;
    wire pc_src_select_ex;
    wire [3:0] rd_ex;

    id_ex_reg id_ex(
        .clk(clk),
        .reset(reset || flush_pipeline),
        .reg_write_enable_in(reg_write_enable),
        .mem_enable_in(mem_enable),
        .mem_rw_in(mem_rw),
        .mem_to_reg_select_in(mem_to_reg_select),
        .alu_src_select_in(alu_source_select),
        .alu_control_in(alu_operation),
        .status_bit_in(status_bit),
        .mem_size_in(mem_size),
        .am_bits_in(addressing_mode),
        .pc_src_select_in(pc_source_select),
        // Outputs
        .reg_write_enable_out(reg_write_enable_ex),
        .mem_enable_out(mem_enable_ex),
        .mem_rw_out(mem_rw_ex),
        .mem_to_reg_select_out(mem_to_reg_select_ex),
        .alu_src_select_out(alu_src_select_ex),
        .alu_control_out(alu_control_ex),
        .status_bit_out(status_bit_ex),
        .mem_size_out(mem_size_ex),
        .am_bits_out(am_bits_ex),
        .pc_src_select_out(pc_src_select_ex)
    );

    // ---------- EX Stage ----------
    wire [31:0] alu_result;
    
    // ALU implementation (you'll need to create this module)
    alu alu_unit(
        .in_a(alu_in_a),
        .in_b(alu_in_b),
        .alu_op(alu_control_ex),
        .out(alu_result)
    );

    // ---------- EX/MEM Pipeline Register ----------
    wire reg_write_enable_mem, mem_enable_mem, mem_rw_mem;
    wire mem_to_reg_select_mem, alu_src_select_mem;
    wire [3:0] alu_control_mem;
    wire status_bit_mem, mem_size_mem;
    wire [31:0] alu_result_mem;
    wire [3:0] rd_mem;

    ex_mem_reg ex_mem(
        .clk(clk),
        .reset(reset),
        .reg_write_enable_in(reg_write_enable_ex),
        .mem_enable_in(mem_enable_ex),
        .mem_rw_in(mem_rw_ex),
        .mem_to_reg_select_in(mem_to_reg_select_ex),
        .alu_src_select_in(alu_src_select_ex),
        .alu_control_in(alu_control_ex),
        .status_bit_in(status_bit_ex),
        .mem_size_in(mem_size_ex),
        // Outputs
        .reg_write_enable_out(reg_write_enable_mem),
        .mem_enable_out(mem_enable_mem),
        .mem_rw_out(mem_rw_mem),
        .mem_to_reg_select_out(mem_to_reg_select_mem),
        .alu_src_select_out(alu_src_select_mem),
        .alu_control_out(alu_control_mem),
        .status_bit_out(status_bit_mem),
        .mem_size_out(mem_size_mem)
    );

    // ---------- MEM Stage ----------
    // Data memory interface would go here
    // You'll need to create a data_memory module

    // ---------- MEM/WB Pipeline Register ----------
    wire reg_write_enable_wb, mem_enable_wb, mem_rw_wb;
    wire mem_to_reg_select_wb, alu_src_select_wb;
    wire [3:0] alu_control_wb;
    wire status_bit_wb, mem_size_wb;
    wire [3:0] rd_wb;

    mem_wb_reg mem_wb(
        .clk(clk),
        .reset(reset),
        .reg_write_enable_in(reg_write_enable_mem),
        .mem_enable_in(mem_enable_mem),
        .mem_rw_in(mem_rw_mem),
        .mem_to_reg_select_in(mem_to_reg_select_mem),
        .alu_src_select_in(alu_src_select_mem),
        .alu_control_in(alu_control_mem),
        .status_bit_in(status_bit_mem),
        .mem_size_in(mem_size_mem),
        // Outputs
        .reg_write_enable_out(reg_write_enable_wb),
        .mem_enable_out(mem_enable_wb),
        .mem_rw_out(mem_rw_wb),
        .mem_to_reg_select_out(mem_to_reg_select_wb),
        .alu_src_select_out(alu_src_select_wb),
        .alu_control_out(alu_control_wb),
        .status_bit_out(status_bit_wb),
        .mem_size_out(mem_size_wb)
    );

    // Output assignment
    assign PC_out = PC_current;

endmodule