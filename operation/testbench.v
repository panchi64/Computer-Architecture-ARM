module ppu_tb;
    // Clock and reset signals
    reg clk;
    reg reset;
    
    // Monitor signals
    wire [31:0] PC_out;
    wire [31:0] instruction_id;
    wire [31:0] alu_result;
    wire [31:0] mem_data;
    wire [31:0] final_result;
    
    // Register file monitoring
    wire [31:0] r1, r2, r3, r5, r6;
    
    // Control signals monitoring
    wire reg_write_enable, mem_enable, mem_rw;
    wire mem_to_reg_select, alu_source_select;
    wire [3:0] alu_operation;
    wire status_bit, mem_size;
    wire [1:0] addressing_mode;
    
    // Forwarding and hazard signals
    wire [1:0] forward_sel_a, forward_sel_b;
    wire stall_pipeline, flush_pipeline;
    
    // Memory signals
    wire [7:0] mem_address;
    wire [31:0] mem_write_data;
    reg [7:0] instr_mem [0:255];  // 256 bytes of instruction memory
    reg [7:0] data_mem [0:255];   // 256 bytes of data memory

    // Pipeline register signals
    wire [31:0] instruction;  // From IF stage
    wire [31:0] pc_plus_4;    // From IF stage
    wire branch_taken;        // For branch control
    wire [31:0] branch_target; // For branch target
    wire [31:0] extended_immediate; // From ID stage
    wire [31:0] reg_data_a, reg_data_b, reg_data_c; // From ID stage
    wire [3:0] destination_reg; // From ID stage
    wire [31:0] wb_write_data; // From WB stage
    wire [3:0] wb_write_reg;   // From WB stage
    wire wb_reg_write_enable;  // From WB stage
    wire id_reg_write_enable, id_mem_enable, id_mem_rw;  // ID stage control signals
    wire id_mem_to_reg_select, id_alu_source_select;     // ID stage control signals
    wire [3:0] id_alu_operation;                         // ID stage control signals
    wire id_status_bit, id_mem_size;                     // ID stage control signals
    wire [1:0] id_addressing_mode;                       // ID stage control signals

    wire [31:0] if_id_pc_plus_4;
    wire [31:0] if_id_instruction;
    wire [1:0] if_id_am_bits;
    wire [3:0] alu_flags;

    wire reg_write_enable_ex, mem_enable_ex, mem_rw_ex;
    wire mem_to_reg_select_ex, alu_src_select_ex;
    wire [3:0] alu_control_ex;
    wire status_bit_ex, mem_size_ex;
    wire [1:0] am_bits_ex;
    wire pc_src_select_ex;
    wire [31:0] reg_data_a_ex, reg_data_b_ex, reg_data_c_ex;
    wire [31:0] extended_imm_ex;
    wire [3:0] reg_dst_ex;
    wire [31:0] pc_plus_4_ex;

    wire reg_write_enable_mem, mem_enable_mem, mem_rw_mem;
    wire mem_to_reg_select_mem, alu_src_select_mem;
    wire [3:0] alu_control_mem;
    wire status_bit_mem, mem_size_mem;
    wire [31:0] alu_result_mem;
    wire [31:0] mem_data_mem;
    wire [3:0] write_reg_addr_mem;
    
    // Instantiate the pipeline stages
    if_stage if_stage_inst (
        .clk(clk),
        .reset(reset),
        .stall(stall_pipeline),
        .branch_taken(branch_taken),
        .branch_target(branch_target),
        .instruction(instruction),
        .pc_plus_4(pc_plus_4),
        .current_pc(PC_out)
    );

    id_stage id_stage_inst (
        .clk(clk),
        .reset(reset),
        .instruction(instruction_id),
        .pc_plus_4_in(pc_plus_4),
        .ex_result(alu_result),
        .mem_result(mem_data),
        .wb_result(final_result),
        .write_data(wb_write_data),
        .write_reg(wb_write_reg),
        .write_enable(wb_reg_write_enable),
        .reg_write_enable(id_reg_write_enable),
        .mem_enable(id_mem_enable),
        .mem_rw(id_mem_rw),
        .mem_to_reg_select(id_mem_to_reg_select),
        .alu_source_select(id_alu_source_select),
        .alu_operation(id_alu_operation),
        .status_bit(id_status_bit),
        .mem_size(id_mem_size),
        .addressing_mode(id_addressing_mode),
        .stall_pipeline(stall_pipeline),
        .flush_pipeline(flush_pipeline)
    );

      // IF/ID Pipeline Register
    if_id_reg if_id_reg_inst (
        .clk(clk),
        .reset(reset),
        .enable(~stall_pipeline),
        .instruction_in(instruction),
        .pc_plus_4_in(pc_plus_4),
        .am_bits_in(id_addressing_mode),
        .pc_plus_4_out(if_id_pc_plus_4),
        .am_bits_out(if_id_am_bits),
        .instruction_out(if_id_instruction)
    );

    // ID/EX Pipeline Register
    id_ex_reg id_ex_reg_inst (
        .clk(clk),
        .reset(reset || flush_pipeline),
        .reg_write_enable_in(id_reg_write_enable),
        .mem_enable_in(id_mem_enable),
        .mem_rw_in(id_mem_rw),
        .mem_to_reg_select_in(id_mem_to_reg_select),
        .alu_src_select_in(id_alu_source_select),
        .alu_control_in(id_alu_operation),
        .status_bit_in(id_status_bit),
        .mem_size_in(id_mem_size),
        .am_bits_in(id_addressing_mode),
        .pc_src_select_in(1'b0),  // Connect to branch control if implemented
        .reg_data_a_in(reg_data_a),
        .reg_data_b_in(reg_data_b),
        .reg_data_c_in(reg_data_c),
        .extended_imm_in(extended_immediate),
        .reg_dst_in(destination_reg),
        .pc_plus_4_in(if_id_pc_plus_4),
        
        .reg_write_enable_out(reg_write_enable_ex),
        .mem_enable_out(mem_enable_ex),
        .mem_rw_out(mem_rw_ex),
        .mem_to_reg_select_out(mem_to_reg_select_ex),
        .alu_src_select_out(alu_src_select_ex),
        .alu_control_out(alu_control_ex),
        .status_bit_out(status_bit_ex),
        .mem_size_out(mem_size_ex),
        .am_bits_out(am_bits_ex),
        .pc_src_select_out(pc_src_select_ex),
        .reg_data_a_out(reg_data_a_ex),
        .reg_data_b_out(reg_data_b_ex),
        .reg_data_c_out(reg_data_c_ex),
        .extended_imm_out(extended_imm_ex),
        .reg_dst_out(reg_dst_ex),
        .pc_plus_4_out(pc_plus_4_ex)
    );

    // Execute Stage
    execute_stage ex_stage_inst (
        .clk(clk),
        .reset(reset),
        .alu_operation(alu_control_ex),
        .branch_type(2'b00),  // Connect to branch control if implemented
        .condition(instruction[31:28]),  // Condition field from instruction
        .operand_a(reg_data_a_ex),
        .operand_b(reg_data_b_ex),
        .pc_plus_4(pc_plus_4_ex),
        .immediate(extended_imm_ex),
        .reg_data(reg_data_c_ex),
        .CIN(1'b0),  // Connect to status flags if needed
        .forward_ex_mem(alu_result_mem),
        .forward_mem_wb(wb_write_data),
        .forward_sel_a(forward_sel_a),
        .forward_sel_b(forward_sel_b),
        .alu_result(alu_result),
        .branch_target(branch_target),
        .flags(alu_flags),
        .branch_taken(branch_taken)
    );

    // EX/MEM Pipeline Register
    ex_mem_reg ex_mem_reg_inst (
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
        .reg_write_enable_out(reg_write_enable_mem),
        .mem_enable_out(mem_enable_mem),
        .mem_rw_out(mem_rw_mem),
        .mem_to_reg_select_out(mem_to_reg_select_mem),
        .alu_src_select_out(alu_src_select_mem),
        .alu_control_out(alu_control_mem),
        .status_bit_out(status_bit_mem),
        .mem_size_out(mem_size_mem)
    );

    // Memory Stage
    mem_stage mem_stage_inst (
        .clk(clk),
        .reset(reset),
        .mem_enable(mem_enable_mem),
        .mem_rw(mem_rw_mem),
        .mem_size(mem_size_mem),
        .mem_to_reg_select(mem_to_reg_select_mem),
        .alu_result(alu_result_mem),
        .write_data(reg_data_b_ex),  // Data to write to memory
        .forward_select(2'b00),  // Add forwarding if needed
        .ex_forwarded_data(32'b0),
        .mem_forwarded_data(32'b0),
        .wb_forwarded_data(32'b0),
        .mem_result(mem_data_mem),
        .final_result(final_result)
    );

    // MEM/WB Pipeline Register
    mem_wb_reg mem_wb_reg_inst (
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
        .alu_result_in(alu_result_mem),
        .mem_data_in(mem_data_mem),
        .write_reg_addr_in(reg_dst_ex),
        .reg_write_enable_out(wb_reg_write_enable),
        .mem_enable_out(),  // Not used in WB stage
        .mem_rw_out(),      // Not used in WB stage
        .mem_to_reg_select_out(),  // Used internally in WB stage
        .alu_src_select_out(),     // Not used in WB stage
        .alu_control_out(),        // Not used in WB stage
        .status_bit_out(),         // Not used in WB stage
        .mem_size_out(),           // Not used in WB stage
        .alu_result_out(wb_write_data),
        .mem_data_out(),           // Used internally in WB stage
        .write_reg_addr_out(wb_write_reg)
    );

    // Write-Back Stage
    wb_stage wb_stage_inst (
        .mem_to_reg_select(mem_to_reg_select_mem),
        .reg_write_enable(reg_write_enable_mem),
        .alu_result(alu_result_mem),
        .mem_data(mem_data_mem),
        .write_reg_addr(reg_dst_ex),
        .write_data(wb_write_data),
        .write_reg_addr_out(wb_write_reg),
        .reg_write_enable_out(wb_reg_write_enable)
    );
    
    // Monitor format strings
    reg [8*50:1] monitor_format;  // For dynamic format string
    integer counter;  // For counting cycles
    
    // Clock generation
    initial begin
        clk = 0;
        forever #2 clk = ~clk;
    end
    
    // Reset generation
    initial begin
        reset = 1;
        #3 reset = 0;
    end
    
    // Memory initialization
    initial begin
        // Initialize counter
        counter = 0;
        
        // Load instruction memory from file
        $readmemb("validation_code.txt", instr_mem);
        
        // Load data memory from file
        $readmemb("validation_code.txt", data_mem);
        
        // Set default monitoring format
        monitor_format = "Time=%0t PC=%h\n";
        
        // Start monitoring
        $monitor(monitor_format, $time, PC_out);
        
        // Optional: Add waveform dumping
        $dumpfile("ppu_tb.vcd");
        $dumpvars(0, ppu_tb);
    end
    
    // Program execution monitoring
    always @(posedge clk) begin
        counter = counter + 1;
        
        // Print register contents every clock cycle
        $display("Cycle %0d:", counter);
        $display("  R1=%0d R2=%0d R3=%0d R5=%0d R6=%0d",
            id_stage_inst.rf.register_outputs[1],
            id_stage_inst.rf.register_outputs[2],
            id_stage_inst.rf.register_outputs[3],
            id_stage_inst.rf.register_outputs[5],
            id_stage_inst.rf.register_outputs[6]
        );
        
        // Check for program completion
        if (instruction == 32'b0) begin
            display_memory_contents;
            $finish;
        end
    end
    
    // Task to display memory contents
    task display_memory_contents;
        integer i;
        begin
            $display("\nFinal Data Memory Contents:");
            for(i = 0; i < 64; i = i + 4) begin
                $display("Addr %0d: %b %b %b %b", 
                    i,
                    data_mem[i],
                    data_mem[i+1],
                    data_mem[i+2],
                    data_mem[i+3]
                );
            end
        end
    endtask
    
    // Optional detailed monitoring
    // Uncomment to enable detailed control signal monitoring
    /*
    always @(posedge clk) begin
        $display("Control Signals:");
        $display("  WE=%b ME=%b MRW=%b",
            id_reg_write_enable,
            id_mem_enable,
            id_mem_rw
        );
        $display("Instruction: %b", instruction_id);
    end
    */
    
endmodule