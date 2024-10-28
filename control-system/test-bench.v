module arm_pipeline_tb;

  // Clock generation
  reg clk;                    // System clock
  initial begin
    clk = 0;
    forever #1 clk = ~clk;
  end

  // Test bench signals
  reg reset;                  // Global reset signal
  
  // IF Stage Signals
  wire [31:0] PC_current;     // Current Program Counter value
  wire [31:0] PC_plus_4;      // PC + 4 for next sequential instruction
  wire [31:0] instruction;    // Current instruction from memory
  wire [1:0]  PC_enable;      // Enable signal for the Program Counter
  
  // ID Stage Signals
  wire [31:0] IF_ID_Instr;    // Instruction passed to ID stage
  
  // Control Unit Signals
  wire RegWrite;              // Register file write enable
  wire MemWrite;              // Memory write enable
  wire MemtoReg;              // Select between ALU result and memory data
  wire ALUSrc;                // Select between register and immediate
  wire [1:0] S_bit;           // Register source selection
  wire [1:0] ALUControl;      // ALU operation control
  wire PCSrc;                 // PC source selection for branches
  
  // EX Stage Signals
  wire [31:0] ID_EX_ExtImm;   // Extended immediate value
  wire ID_EX_RegWrite;        // Register write control in EX stage
  wire ID_EX_MemWrite;        // Memory write control in EX stage
  wire ID_EX_ALUSrc;          // ALU source control in EX stage
  wire [1:0] ID_EX_ALUControl;// ALU operation control in EX stage
  
  // MEM Stage Signals
  wire EX_MEM_RegWrite;           // Register write control in MEM stage
  wire EX_MEM_MemWrite;           // Memory write control in MEM stage
  wire EX_MEM_MemtoReg;           // Memory to register control in MEM stage
  
  // WB Stage Signals
  wire MEM_WB_RegWrite;           // Register write control in WB stage
  wire MEM_WB_MemtoReg;           // Memory to register control in WB stage

  // Pipeline Register Enable Signals
  reg IF_ID_Enable;               // IF/ID register enable

  // Instruction Memory Instance ✅
  instruction_memory imem (
    .address(PC_current[7:0]),
    .instruction(instruction)
  );

  // Program Counter Register Instance ✅
  program_counter pc_reg (
    .clk(clk),
    .reset(reset),
    .pc_next(PC_plus_4),
    .pc_current(PC_current),
    .enable(PC_enable)
  );

  // IF Stage Adder Instance ✅
  adder if_adder (
    .in_a(PC_current),
    .in_b(32'd4),
    .out(PC_plus_4)
  );

  // Control Unit Instance ✅
  control_unit cu (
    .instruction(IF_ID_Instr),
    .reg_write_enable(RegWrite),
    .mem_write_enable(MemWrite),
    .mem_to_reg_select(MemtoReg),
    .alu_source_select(ALUSrc),
    .status_bits(S_bit),
    .alu_operation(ALUControl),
    .pc_source_select(PCSrc)
  );

  // Control Unit Multiplexer Instance ✅
  cu_mux control_mux (
    .reg_write_enable_in(RegWrite),
    .mem_write_enable_in(MemWrite),
    .mem_to_reg_select_in(MemtoReg),
    .alu_src_in(ALUSrc),
    .status_bits_in(S_bit),
    .alu_control_in(ALUControl),
    .pc_src_select_in(PCSrc),
    .reg_write_enable_out(RegWrite_muxed),
    .mem_write_enable_out(MemWrite_muxed),
    .mem_to_reg_select_out(MemtoReg_muxed),
    .alu_src_select_out(ALUSrc_muxed),
    .status_bits_out(S_bit_muxed),
    .alu_control_out(ALUControl_muxed),
    .pc_src_select_out(PCSrc_muxed)
  );

  // IF/ID Pipeline Register Instance ✅
  if_id_reg if_id (
    .clk(clk),
    .reset(reset),
    .enable(IF_ID_Enable),
    .instruction_in(instruction),
    .instruction_out(IF_ID_Instr)
  );

  // ID/EX Pipeline Register Instance ✅
  id_ex_reg id_ex (
    .clk(clk),
    .reset(reset),
    .ext_imm_in(ExtImm),
    .reg_write_enable_in(RegWrite_muxed),
    .mem_write_enable_in(MemWrite_muxed),
    .mem_to_reg_select_in(MemtoReg_muxed),
    .alu_src_select_in(ALUSrc_muxed),
    .alu_control_in(ALUControl_muxed),
    .ext_imm_out(ID_EX_ExtImm),
    .reg_write_out(ID_EX_RegWrite),
    .mem_write_out(ID_EX_MemWrite),
    .alu_src_select_out(ID_EX_ALUSrc),
    .alu_control_out(ID_EX_ALUControl)
  );

  // EX/MEM Pipeline Register Instance ✅
  ex_mem_reg ex_mem (
    .clk(clk),
    .reset(reset),
    .reg_write_enable_in(ID_EX_RegWrite),
    .mem_write_enable_in(ID_EX_MemWrite),
    .reg_write_enable_out(EX_MEM_RegWrite),
    .mem_write_enable_out(EX_MEM_MemWrite),
  );

  // MEM/WB Pipeline Register Instance ✅
  mem_wb_reg mem_wb (
    .clk(clk),
    .reset(reset),
    .reg_write_enable_in(EX_MEM_RegWrite),
    .mem_to_reg_select_in(EX_MEM_MemtoReg),
    .reg_write_enable_out(MEM_WB_RegWrite),
    .mem_to_reg_select_out(MEM_WB_MemtoReg)
  );

  initial begin
    // Initialize instruction memory with the given program
    imem.memory[0] = 32'b11100010_00010001_00000000_00000000; // ANDS R0,R1,#0
    imem.memory[1] = 32'b11100000_10000000_01010001_10000011; // ADD R5,R0,R3,LSL #3
    imem.memory[2] = 32'b11100111_11010001_00100000_00000000; // LDRB R2,[R1,R0]
    imem.memory[3] = 32'b11100101_10001010_01010000_00000000; // STR R5,[R10,#0]
    imem.memory[4] = 32'b00011010_11111111_11111111_11111101; // BNE -3
    imem.memory[5] = 32'b11011011_00000000_00000000_00001001; // BLLE +9
    imem.memory[6] = 32'b11100010_00000001_00000000_00000000; // AND R0,R1,#0
    imem.memory[7] = 32'b11100000_10000000_01010001_10000011; // ADD R5,R0,R3,LSL #3
    imem.memory[8] = 32'b11100111_11010001_00100000_00000000; // LDRB R2,[R1,R0]
    imem.memory[9] = 32'b11100101_10001010_01010000_00000000; // STR R5,[R10,#0]
    imem.memory[10] = 32'b00011010_11111111_11111111_11111101;// BNE -3
    imem.memory[11] = 32'b00000000_00000000_00000000_00000000;// NOP
    imem.memory[12] = 32'b00000000_00000000_00000000_00000000;// NOP

    // Initialize control signals
    reset = 1;
    IF_ID_Enable = 1;
    PC_enable = 1;
    
    // Wait for 3 clock cycles and release reset
    #3;
    reset = 0;
    
    // Monitor signals
    $display("\n=== Simulation Start ===");
    
    // Monitor signals with organized output
    $monitor(
        "\nTime: %0d ns\n" ,
        "----------------------------------------\n" ,
        "Clock: %b  Reset: %b\n" ,
        "----------------------------------------\n" ,
        "Program Counter: %h\n" ,
        "Current Instruction: %h\n" ,
        "----------------------------------------\n" ,
        "Pipeline Controls:\n" ,
        "  IF/ID Enable:   %b\n" ,
        "----------------------------------------\n" ,
        "Control Signals:\n" ,
        "  PCSrc:       %b\n" ,
        "  RegWrite:    %b\n" ,
        "  MemWrite:    %b\n" ,
        "  S_bit:      %b\n" ,
        "  ALUControl:  %b\n" ,
        "----------------------------------------\n",
        $time, 
        clk, reset,
        PC_current,
        instruction,
        IF_ID_Enable,
        PCSrc, RegWrite, MemWrite, S_bit, ALUControl
    );
    
    // Run for specified 40 time units
    #40;
    
    // End simulation
    $finish;
  end

endmodule