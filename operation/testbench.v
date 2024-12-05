module pipeline_tb;
    // Clock and reset signals
    reg clk;
    reg reset;
    
    // Pipeline outputs
    wire [31:0] PC_out;
    
    // Internal monitoring signals
    wire [31:0] instruction_id;
    wire [31:0] alu_result_ex;
    wire [31:0] mem_data_out;
    wire [31:0] forwarded_a, forwarded_b;
    wire [31:0] shifter_out;
    
    // Control signal monitoring
    wire reg_write_enable, mem_enable, mem_rw;
    wire mem_to_reg_select, alu_src_select;
    wire [3:0] alu_operation;
    wire status_bit, mem_size;
    
    // Instantiate pipeline
    pipeline dut (
        .clk(clk),
        .reset(reset),
        .PC_out(PC_out)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #2 clk = ~clk;
    end

    // Reset sequence
    initial begin
        reset = 1;
        #3 reset = 0;
    end

    // Memory initialization
    initial begin
        // Initialize data memory
        dut.dmem.mem[52] = 8'h00;  // N value
        dut.dmem.mem[53] = 8'h00;
        dut.dmem.mem[54] = 8'h00;
        dut.dmem.mem[55] = 8'h00;
        dut.dmem.mem[56] = 8'h05;  // A value
        dut.dmem.mem[57] = 8'h03;  // B value
    end

    // Monitor for validation program
    task monitor_validation_program;
        begin
            $display("\nValidation Program Monitoring");
            $monitor("Time=%0t PC=%h R1=%0d R2=%0d R3=%0d R5=%0d R6=%0d",
                    $time,
                    PC_out,
                    dut.rf.register_outputs[1],
                    dut.rf.register_outputs[2],
                    dut.rf.register_outputs[3],
                    dut.rf.register_outputs[5],
                    dut.rf.register_outputs[6]);
        end
    endtask

    // Monitor for pipeline stages
    // task monitor_pipeline_stages;
    //     begin
    //         $display("\nPipeline Stage Monitoring");
    //         $display("IF Stage - PC: %h", PC_out);
    //         $display("ID Stage - Instruction: %h", instruction_id);
    //         $display("EX Stage - ALU Result: %h", alu_result_ex);
    //         $display("MEM Stage - Memory Data: %h", mem_data_out);
    //         $display("Forwarding Mux A: %h, Mux B: %h", forwarded_a, forwarded_b);
    //         $display("Shifter Output: %h", shifter_out);
    //     end
    // endtask

    // Monitor for control signals
    // task monitor_control_signals;
    //     begin
    //         $display("\nControl Signals");
    //         $display("RegWrite=%b MemEnable=%b MemRW=%b MemToReg=%b",
    //                 reg_write_enable, mem_enable, mem_rw, mem_to_reg_select);
    //         $display("ALUSrc=%b ALUOp=%b StatusBit=%b MemSize=%b",
    //                 alu_src_select, alu_operation, status_bit, mem_size);
    //     end
    // endtask

    // Monitor for memory contents
    // task display_memory_contents;
    //     integer i;
    //     begin
    //         $display("\nData Memory Contents:");
    //         for(i = 0; i < 64; i = i + 4) begin
    //             $display("Addr %0h: %b %b %b %b",
    //                     i,
    //                     dut.dmem.mem[i],
    //                     dut.dmem.mem[i+1],
    //                     dut.dmem.mem[i+2],
    //                     dut.dmem.mem[i+3]);
    //         end
    //     end
    // endtask

    // Hazard detection monitoring
    // task monitor_hazards;
    //     begin
    //         $display("\nHazard and Forwarding Status");
    //         $display("Stall: %b, Flush: %b", 
    //                 dut.stall_pipeline,
    //                 dut.flush_pipeline);
    //         $display("Forward A Sel: %b, Forward B Sel: %b",
    //                 dut.forward_a_sel,
    //                 dut.forward_b_sel);
    //     end
    // endtask

    // Signal assignments for monitoring
    assign instruction_id = dut.if_id.instruction_out;
    assign alu_result_ex = dut.execute_stage.alu_result;
    assign mem_data_out = dut.mem_stage.Out;
    assign forwarded_a = dut.forwarded_a;
    assign forwarded_b = dut.forwarded_b;
    assign shifter_out = dut.shifter_out;

    // Control signal assignments
    assign reg_write_enable = dut.reg_write_id;
    assign mem_enable = dut.mem_enable_id;
    assign mem_rw = dut.mem_rw_id;
    assign mem_to_reg_select = dut.mem_to_reg_id;
    assign alu_src_select = dut.alu_src_id;
    assign alu_operation = dut.alu_operation_id;
    assign status_bit = dut.cu.status_bit;
    assign mem_size = dut.mem_size_id;

    // Main test sequence
    initial begin
        // Wait for reset to complete
        @(negedge reset);
        
        // Start validation program monitoring
        monitor_validation_program();
        
        // Monitor pipeline stages every 10 time units
        // repeat(10) begin
        //     #10 monitor_pipeline_stages();
        //     monitor_hazards();
        //     monitor_control_signals();
        // end
        
        // Wait for program completion (detection of NOP instruction)
        wait(dut.instruction == 32'h0);
        
        // Display final memory contents
        // display_memory_contents();
        
        // // Display final word at location 56
        $display("\nFinal word at location 56: %b",
                {dut.dmem.mem[56],
                 dut.dmem.mem[57],
                 dut.dmem.mem[58],
                 dut.dmem.mem[59]});
        
        $finish;
    end

    // Additional monitoring for pipeline stages
    // always @(posedge clk) begin
    //     if (!reset) begin
    //         // Monitor for data hazards
    //         if (dut.stall_pipeline)
    //             $display("Time=%0t: Data hazard detected", $time);
            
    //         // Monitor for control hazards
    //         if (dut.flush_pipeline)
    //             $display("Time=%0t: Control hazard detected", $time);
            
    //         // Monitor for branch execution
    //         if (dut.branch_taken)
    //             $display("Time=%0t: Branch taken to target: %h", 
    //                     $time, dut.branch_target);
    //     end
    // end

endmodule