module ppu(
    input clk,
    input reset,
    output [31:0] PC_out
);
    // Control signals
    wire [3:0] ALU_op;
    wire mem_read, mem_write, reg_write, branch, ALU_src, mem_to_reg;

    // --- Wires for IF stage ---
    wire [31:0] PC, next_PC, instruction;

    // --- Wires for ID stage ---
    wire [31:0] PC_ID, instruction_ID;
    wire [31:0] read_data1, read_data2, imm_ext;
    wire [4:0] rs_ID, rt_ID, rd_ID;

    // --- Wires for EX stage ---
    wire [31:0] read_data1_EX, read_data2_EX, imm_ext_EX;
    wire [3:0] ALU_op_EX;
    wire [4:0] rs_EX, rt_EX, rd_EX;
    wire mem_read_EX, mem_write_EX, reg_write_EX, branch_EX, ALU_src_EX, mem_to_reg_EX;
    wire [31:0] ALU_result, mux_B_out;
    wire zero_EX;

    // --- Wires for MEM stage ---
    wire [31:0] ALU_result_MEM, mem_data_MEM;
    wire mem_read_MEM, mem_write_MEM, reg_write_MEM, mem_to_reg_MEM;

    // --- Wires for WB stage ---
    wire [31:0] ALU_result_WB, mem_data_WB, write_data;
    wire reg_write_WB, mem_to_reg_WB;

    // --- IF Stage ---
    pc_register PC_reg(
        .clk(clk),
        .reset(reset),
        .next_PC(next_PC),
        .PC(PC)
    );

    instruction_memory inst_mem(
        .address(PC),
        .instruction(instruction)
    );

    // Calculate next PC
    assign next_PC = PC + 4;  // Simple increment (without branch prediction)

    // --- IF/ID Pipeline Register ---
    reg_if_id IF_ID(
        .clk(clk),
        .reset(reset),
        .PC_in(PC),
        .instruction_in(instruction),
        .PC_out(PC_ID),
        .instruction_out(instruction_ID)
    );

    // --- ID Stage ---
    control_unit control(
        .opcode(instruction_ID[31:26]),
        .ALU_op(ALU_op),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .reg_write(reg_write),
        .branch(branch),
        .ALU_src(ALU_src),
        .mem_to_reg(mem_to_reg)
    );

    register_file reg_file(
        .clk(clk),
        .read_reg1(instruction_ID[25:21]),
        .read_reg2(instruction_ID[20:16]),
        .write_reg(rd_ID),
        .write_data(write_data),
        .reg_write(reg_write_WB),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    sign_extend sign_ext(
        .instr(instruction_ID[15:0]),
        .data_out(imm_ext)
    );

    // --- ID/EX Pipeline Register ---
    reg_id_ex ID_EX(
        .clk(clk),
        .reset(reset),
        .read_data1_in(read_data1),
        .read_data2_in(read_data2),
        .imm_ext_in(imm_ext),
        .rs_in(instruction_ID[25:21]),
        .rt_in(instruction_ID[20:16]),
        .rd_in(instruction_ID[15:11]),
        .ALU_op_in(ALU_op),
        .mem_read_in(mem_read),
        .mem_write_in(mem_write),
        .reg_write_in(reg_write),
        .branch_in(branch),
        .ALU_src_in(ALU_src),
        .mem_to_reg_in(mem_to_reg),
        .read_data1_out(read_data1_EX),
        .read_data2_out(read_data2_EX),
        .imm_ext_out(imm_ext_EX),
        .rs_out(rs_EX),
        .rt_out(rt_EX),
        .rd_out(rd_EX),
        .ALU_op_out(ALU_op_EX),
        .mem_read_out(mem_read_EX),
        .mem_write_out(mem_write_EX),
        .reg_write_out(reg_write_EX),
        .branch_out(branch_EX),
        .ALU_src_out(ALU_src_EX),
        .mem_to_reg_out(mem_to_reg_EX)
    );

    // --- EX Stage ---
    mux2to1 #(.WIDTH(32)) ALU_mux(
        .a(read_data2_EX),
        .b(imm_ext_EX),
        .sel(ALU_src_EX),
        .y(mux_B_out)
    );

    alu ALU_unit(
        .A(read_data1_EX),
        .B(mux_B_out),
        .ALU_op(ALU_op_EX),
        .result(ALU_result),
        .zero(zero_EX)
    );

    // --- EX/MEM Pipeline Register ---
    reg_ex_mem EX_MEM(
        .clk(clk),
        .reset(reset),
        .ALU_result_in(ALU_result),
        .mem_data_in(read_data2_EX),
        .mem_read_in(mem_read_EX),
        .mem_write_in(mem_write_EX),
        .reg_write_in(reg_write_EX),
        .mem_to_reg_in(mem_to_reg_EX),
        .ALU_result_out(ALU_result_MEM),
        .mem_data_out(mem_data_MEM),
        .mem_read_out(mem_read_MEM),
        .mem_write_out(mem_write_MEM),
        .reg_write_out(reg_write_MEM),
        .mem_to_reg_out(mem_to_reg_MEM)
    );

    // --- MEM Stage ---
    data_memory data_mem(
        .address(ALU_result_MEM),
        .write_data(mem_data_MEM),
        .mem_read(mem_read_MEM),
        .mem_write(mem_write_MEM),
        .read_data(mem_data_MEM)
    );

    // --- MEM/WB Pipeline Register ---
    reg_mem_wb MEM_WB(
        .clk(clk),
        .reset(reset),
        .ALU_result_in(ALU_result_MEM),
        .mem_data_in(mem_data_MEM),
        .reg_write_in(reg_write_MEM),
        .mem_to_reg_in(mem_to_reg_MEM),
        .ALU_result_out(ALU_result_WB),
        .mem_data_out(mem_data_WB),
        .reg_write_out(reg_write_WB),
        .mem_to_reg_out(mem_to_reg_WB)
    );

    // --- WB Stage ---
    mux2to1 #(.WIDTH(32)) wb_mux(
        .a(ALU_result_WB),
        .b(mem_data_WB),
        .sel(mem_to_reg_WB),
        .y(write_data)
    );

    // PC output (for monitoring)
    assign PC_out = PC;

endmodule
