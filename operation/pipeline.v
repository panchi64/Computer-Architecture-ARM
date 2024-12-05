module pipeline(
    input wire clk,
    input wire reset,
    output wire [31:0] PC_out
);
    // -------------------- IF Stage Signals --------------------
    wire [31:0] pc_current, pc_next, pc_plus_4;
    wire [31:0] instruction;
    wire stall_pipeline, flush_pipeline;
    
    // -------------------- IF/ID Register Signals --------------------
    wire [31:0] instruction_id;
    wire [31:0] alu_result;
    wire [31:0] mem_data;
    wire [31:0] pc_plus_4_id;
    wire [1:0] am_bits_if_id;
    
    // -------------------- ID Stage Signals --------------------
    wire [31:0] pa_id, pb_id, pd_id;  // Register file outputs
    wire [31:0] immediate_id;         // Sign extended immediate
    wire [3:0] alu_operation_id;
    wire mem_to_reg_id, alu_src_id;
    wire reg_write_id, mem_enable_id;
    wire mem_rw_id, mem_size_id;
    wire [1:0] addressing_mode_id;
    wire [3:0] rd_id, rs1_id, rs2_id;
    wire branch_taken;
    wire [3:0] condition_flags;
    wire [31:0] branch_target;
    
    // -------------------- ID/EX Register Signals --------------------
    wire [31:0] pa_ex, pb_ex, pd_ex;
    wire [31:0] immediate_ex;
    wire [3:0] alu_operation_ex;
    wire mem_to_reg_ex, alu_src_ex;
    wire reg_write_ex, mem_enable_ex;
    wire mem_rw_ex, mem_size_ex;
    wire [1:0] addressing_mode_ex;
    wire [3:0] rd_ex;
    
    // -------------------- EX Stage Signals --------------------
    wire [31:0] alu_result_ex;
    wire [31:0] shifter_out;
    wire [3:0] alu_flags;
    wire [31:0] forwarded_a, forwarded_b;
    wire [1:0] forward_a_sel, forward_b_sel;
    
    // -------------------- EX/MEM Register Signals --------------------
    wire [31:0] alu_result_mem;
    wire [31:0] write_data_mem;
    wire mem_to_reg_mem, reg_write_mem;
    wire mem_enable_mem, mem_rw_mem;
    wire mem_size_mem;
    wire [3:0] rd_mem;
    
    // -------------------- MEM Stage Signals --------------------
    wire [31:0] mem_data_out;
    wire [31:0] mem_final_out;
    
    // -------------------- MEM/WB Register Signals --------------------
    wire [31:0] result_wb;
    wire [31:0] mem_data_wb;
    wire mem_to_reg_wb, reg_write_wb;
    wire [3:0] rd_wb;
    
    // -------------------- IF Stage --------------------
    program_counter pc(
        .clk(clk),
        .reset(reset),
        .enable(~stall_pipeline),
        .pc_next(branch_taken ? branch_target : pc_plus_4),
        .pc_current(pc_current)
    );
    
    pc_incrementer pc_inc(
        .pc_current(pc_current),
        .pc_plus_4(pc_plus_4)
    );
    
    instruction_memory imem(
        .address(pc_current[7:0]),
        .instruction(instruction)
    );
    
    // -------------------- IF/ID Register --------------------
    if_id_reg if_id(
        .clk(clk),
        .reset(reset || flush_pipeline),
        .enable(~stall_pipeline),
        .instruction_in(instruction),
        .pc_plus_4_in(pc_plus_4),
        .am_bits_in(addressing_mode_id),
        .instruction_out(instruction_id),
        .pc_plus_4_out(pc_plus_4_id),
        .am_bits_out(am_bits_if_id)
    );
    
    // -------------------- ID Stage --------------------
    control_unit cu(
        .instruction(instruction_id),
        .reg_write_enable(reg_write_id),
        .mem_enable(mem_enable_id),
        .mem_rw(mem_rw_id),
        .mem_to_reg_select(mem_to_reg_id),
        .alu_source_select(alu_src_id),
        .status_bit(),  // Connected to condition handler
        .alu_operation(alu_operation_id),
        .pc_source_select(),  // Connected to branch logic
        .mem_size(mem_size_id),
        .addressing_mode(addressing_mode_id)
    );
    
    register_file rf(
        .CLK(clk),
        .PW(result_wb),
        .RW(rd_wb),
        .LE(reg_write_wb),
        .RA(instruction_id[19:16]),
        .RB(instruction_id[15:12]),
        .RC(instruction_id[3:0]),
        .PROGCOUNT(pc_plus_4_id),
        .PA(pa_id),
        .PB(pb_id),
        .PC(pd_id)
    );
    
    condition_check cond_check(
        .cond(instruction_id[31:28]),
        .flags(condition_flags),
        .condition_passed(branch_taken)
    );
    
    branch_calc branch_calc_unit(
        .pc_plus_4(pc_plus_4_id),
        .immediate(immediate_id),
        .reg_data(pa_id),
        .branch_type(addressing_mode_id),
        .branch_target(branch_target)
    );
    
    // -------------------- ID/EX Register --------------------
    id_ex_reg id_ex(
        .clk(clk),
        .reset(reset),
        .reg_write_enable_in(reg_write_id),
        .mem_enable_in(mem_enable_id),
        .mem_rw_in(mem_rw_id),
        .mem_to_reg_select_in(mem_to_reg_id),
        .alu_src_select_in(alu_src_id),
        .alu_control_in(alu_operation_id),
        .status_bit_in(1'b0),  // From condition handler
        .mem_size_in(mem_size_id),
        .am_bits_in(addressing_mode_id),
        .pc_src_select_in(branch_taken),
        .reg_data_a_in(pa_id),
        .reg_data_b_in(pb_id),
        .reg_data_c_in(pd_id),
        .extended_imm_in(immediate_id),
        .reg_dst_in(instruction_id[15:12]),
        .pc_plus_4_in(pc_plus_4_id),
        .reg_write_enable_out(reg_write_ex),
        .mem_enable_out(mem_enable_ex),
        .mem_rw_out(mem_rw_ex),
        .mem_to_reg_select_out(mem_to_reg_ex),
        .alu_src_select_out(alu_src_ex),
        .alu_control_out(alu_operation_ex),
        .status_bit_out(),
        .mem_size_out(mem_size_ex),
        .am_bits_out(addressing_mode_ex),
        .pc_src_select_out(),
        .reg_data_a_out(pa_ex),
        .reg_data_b_out(pb_ex),
        .reg_data_c_out(pd_ex),
        .extended_imm_out(immediate_ex),
        .reg_dst_out(rd_ex),
        .pc_plus_4_out()
    );
    
    // -------------------- EX Stage --------------------
    id_forwarding_mux forward_mux_a(
        .reg_data(pa_ex),
        .ex_forwarded_data(alu_result_mem),
        .mem_forwarded_data(result_wb),
        .wb_forwarded_data(32'b0),
        .forward_select(forward_a_sel),
        .selected_data(forwarded_a)
    );
    
    id_forwarding_mux forward_mux_b(
        .reg_data(pb_ex),
        .ex_forwarded_data(alu_result_mem),
        .mem_forwarded_data(result_wb),
        .wb_forwarded_data(32'b0),
        .forward_select(forward_b_sel),
        .selected_data(forwarded_b)
    );
    
    ALU alu(
        .A(forwarded_a),
        .B(alu_src_ex ? immediate_ex : forwarded_b),
        .CIN(1'b0),
        .Op(alu_operation_ex),
        .Out(alu_result_ex),
        .Z(alu_flags[2]),
        .N(alu_flags[3]),
        .C(alu_flags[1]),
        .V(alu_flags[0])
    );
    
    ShifterSignExtender shifter(
        .Rm(pd_ex),
        .I(immediate_ex[11:0]),
        .AM(addressing_mode_ex),
        .N(shifter_out)
    );
    
    // -------------------- EX/MEM Register --------------------
    ex_mem_reg ex_mem(
        .clk(clk),
        .reset(reset),
        .reg_write_enable_in(reg_write_ex),
        .mem_enable_in(mem_enable_ex),
        .mem_rw_in(mem_rw_ex),
        .mem_to_reg_select_in(mem_to_reg_ex),
        .alu_src_select_in(alu_src_ex),
        .alu_control_in(alu_operation_ex),
        .status_bit_in(1'b0),
        .mem_size_in(mem_size_ex),
        .reg_write_enable_out(reg_write_mem),
        .mem_enable_out(mem_enable_mem),
        .mem_rw_out(mem_rw_mem),
        .mem_to_reg_select_out(mem_to_reg_mem),
        .alu_src_select_out(),
        .alu_control_out(),
        .status_bit_out(),
        .mem_size_out(mem_size_mem)
    );
    
    // -------------------- MEM Stage --------------------
    data_memory dmem(
        .DO(mem_data_out),
        .DI(write_data_mem),
        .A(alu_result_mem[7:0]),
        .Size(mem_size_mem),
        .RW(mem_rw_mem),
        .E(mem_enable_mem)
    );
    
    // -------------------- MEM/WB Register --------------------
    mem_wb_reg mem_wb(
        .clk(clk),
        .reset(reset),
        .reg_write_enable_in(reg_write_mem),
        .mem_enable_in(mem_enable_mem),
        .mem_rw_in(mem_rw_mem),
        .mem_to_reg_select_in(mem_to_reg_mem),
        .alu_src_select_in(1'b0),
        .alu_control_in(4'b0),
        .status_bit_in(1'b0),
        .mem_size_in(mem_size_mem),
        .alu_result_in(alu_result_mem),
        .mem_data_in(mem_data_out),
        .write_reg_addr_in(rd_mem),
        .reg_write_enable_out(reg_write_wb),
        .mem_enable_out(),
        .mem_rw_out(),
        .mem_to_reg_select_out(mem_to_reg_wb),
        .alu_src_select_out(),
        .alu_control_out(),
        .status_bit_out(),
        .mem_size_out(),
        .alu_result_out(result_wb),
        .mem_data_out(mem_data_wb),
        .write_reg_addr_out(rd_wb)
    );
    
    // -------------------- Hazard Unit --------------------
    HazardUnit hazard_unit(
        .ISA(forward_a_sel),
        .ISB(forward_b_sel),
        .ISC(),  // For register C forwarding
        .stall_pipeline(stall_pipeline),
        .flush_pipeline(flush_pipeline),
        .RW_EX(rd_ex),
        .RW_MEM(rd_mem),
        .RW_WB(rd_wb),
        .RA_ID(instruction_id[19:16]),
        .RB_ID(instruction_id[15:12]),
        .RC_ID(instruction_id[3:0]),
        .enable_LD_EX(mem_enable_ex && ~mem_rw_ex),
        .enable_RF_EX(reg_write_ex),
        .enable_RF_MEM(reg_write_mem),
        .enable_RF_WB(reg_write_wb),
        .branch_taken(branch_taken),
        .branch_ID(1'b0)  // Set based on instruction decode
    );
    
    // Output assignment
    assign PC_out = pc_current;
    assign instruction_id = if_id.instruction_out;
    assign alu_result_ex = execute_stage.alu_result;
    assign mem_data_out = mem_stage.Out;
    assign forwarded_a = id_stage.PA;
    assign forwarded_b = id_stage.PB;
    assign shifter_out = id_stage.N;
    assign alu_result = execute_stage.alu_result;
    assign mem_data = mem_stage.Out;
        
endmodule