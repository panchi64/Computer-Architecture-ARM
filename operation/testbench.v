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

    // Pipeline registers and other stages similar pattern...
    
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
        // Load instruction memory
        $readmemb("validation_code.txt", if_stage_inst.imem.memory);
        
        // Load data memory
        $readmemb("validation_code.txt", mem_stage_inst.dmem.memory);
    end
    
    // Monitor format strings
    reg [8*50:1] monitor_format;  // For dynamic format string
    
    // Monitoring logic
    initial begin
        // Set default monitoring format
        monitor_format = "Time=%0t PC=%h R1=%0d R2=%0d R3=%0d R5=%0d";
        
        // Start monitoring
        $monitor(monitor_format, 
                $time, PC_out, 
                id_stage_inst.rf.register_outputs[1], 
                id_stage_inst.rf.register_outputs[2],
                id_stage_inst.rf.register_outputs[3],
                id_stage_inst.rf.register_outputs[5]
        );
        
        // Wait for program completion
        wait(instruction == 32'b0);  // Assuming NOP indicates end
        
        // Display final memory contents
        display_memory_contents;
        
        $finish;
    end
    
    // Task to display memory contents
    task display_memory_contents;
        integer i;
        begin
            $display("\nFinal Data Memory Contents:");
            for(i = 0; i < 64; i = i + 4) begin
                $display("Addr %0d: %b %b %b %b", 
                    i,
                    mem_stage_inst.dmem.memory[i],
                    mem_stage_inst.dmem.memory[i+1],
                    mem_stage_inst.dmem.memory[i+2],
                    mem_stage_inst.dmem.memory[i+3]
                );
            end
        end
    endtask
    
    // Optional detailed monitoring
    // Uncomment to enable
    /*
    initial begin
        $monitor("Time=%0t\nControl Signals: WE=%b ME=%b MRW=%b\nInstruction=%b",
            $time, reg_write_enable, mem_enable, mem_rw, instruction_id);
    end
    */
    
endmodule