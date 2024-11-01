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
  reg PC_enable;              // Program Counter enable signal (changed from wire to reg)
  wire [31:0] PC_current;     // Current Program Counter value
  wire [31:0] PC_plus_4;      // PC + 4 for next sequential instruction
  wire [31:0] instruction;    // Current instruction from memory

  
  // ID Stage Signals
  wire [31:0] IF_ID_Instr;    // Instruction passed to ID stage
  wire [1:0]  IF_ID_AM_bits;  // Addresssing mode bits
  
  // Control Unit Signals
  wire RegWrite;              // Register file write enable
  wire MemEnable;             // Memory write enable
  wire MemRW;                 // Memory read enable from control unit
  wire MemtoReg;              // Select between ALU result and memory data
  wire ALUSrc;                // Select between register and immediate
  wire S_bit_ctrl;            // Register source selection from control unit
  reg  S_bit_mux;             // Multiplexer Select bit
  wire [3:0] ALUControl;      // ALU operation control
  wire PCSrc;                 // PC source selection for branches
  
  // EX Stage Signals
  wire ID_EX_RegWrite;        // Register write control in EX stage
  wire ID_EX_MemEnable;       // Memory write control in EX stage
  wire ID_EX_MemRW;           // Memory read control in ID stage
  wire ID_EX_mem_size;        // Memory size in ID stage
  wire ID_EX_ALUSrc;          // ALU source control in EX stage
  wire [3:0] ID_EX_ALUControl;// ALU operation control in EX stage
  wire [1:0] ID_EX_AM_bits;   // Addressing Mode bits
  
  // MEM Stage Signals
  wire EX_MEM_RegWrite;           // Register write control in MEM stage
  wire EX_MEM_MemEnable;          // Memory write control in MEM stage
  wire EX_MEM_MemRW;              // Memory read control in EX stage
  wire EX_MEM_mem_size;           // Memory size in EX stage
  wire EX_MEM_MemtoReg;           // Memory to register control in MEM stage
  wire [3:0] EX_MEM_ALUControl;
  wire EX_MEM_ALUSrc;
  wire EX_MEM_Status;
  
  // WB Stage Signals
  wire MEM_WB_RegWrite;           // Register write control in WB stage
  wire MEM_WB_MemEnable;
  wire MEM_WB_MemRW;              // Memory read control in MEM stage
  wire MEM_WB_mem_size;           // Memory size in MEM stage
  wire MEM_WB_MemtoReg;           // Memory to register control in WB stage
  wire [3:0] MEM_WB_ALUControl;
  wire MEM_WB_ALUSrc;
  wire MEM_WB_Status;

  // Pipeline Register Enable Signals
  reg IF_ID_Enable;                // IF/ID register enable

  wire S_bit_muxed;                // Muxed status bits
  wire [3:0] ALUControl_muxed;     // Muxed ALU control
  wire MemtoReg_muxed;             // Muxed memory to register select
  wire mem_size;                   // Memory size control

  reg [31:0] instruction_keyword;  // For storing instruction text

  // Instruction Memory Instance ✅
  instruction_memory imem (
    .address(PC_current[7:0]),
    .instruction(instruction)
  );

  // Program Counter Register Instance ✅
  program_counter pc_reg (
    .clk(clk),
    .reset(reset),
    .enable(PC_enable),
    .pc_next(PC_plus_4),
    .pc_current(PC_current)
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
    .mem_enable(MemEnable),
    .mem_rw(MemRW),    
    .mem_to_reg_select(MemtoReg),
    .alu_source_select(ALUSrc),
    .status_bit(S_bit_ctrl),
    .alu_operation(ALUControl),
    .pc_source_select(PCSrc),
    .mem_size(mem_size)                   
  );


  // Control Unit Multiplexer Instance ✅
  cu_mux control_mux (
    .reg_write_enable_in(RegWrite),
    .mem_enable_in(MemEnable),
    .mem_rw_in(MemRW),  
    .mem_to_reg_select_in(MemtoReg),
    .alu_src_in(ALUSrc),
    .status_bit_in(S_bit_ctrl),
    .alu_control_in(ALUControl),
    .pc_src_select_in(PCSrc),
    .mem_size_in(mem_size),               
    .mux_select(S_bit_mux),
    .reg_write_enable_out(RegWrite_muxed),
    .mem_enable_out(MemEnable_muxed),
    .mem_rw_out(MemRW_muxed),  
    .mem_to_reg_select_out(MemtoReg_muxed),
    .alu_src_select_out(ALUSrc_muxed),
    .status_bit_out(S_bit_muxed),
    .alu_control_out(ALUControl_muxed),
    .pc_src_select_out(PCSrc_muxed),
    .mem_size_out(mem_size_muxed)         
  );

  // IF/ID Pipeline Register Instance ✅
  if_id_reg if_id (
    .clk(clk),
    .reset(reset),
    .enable(IF_ID_Enable),
    .instruction_in(instruction),
    .am_bits_out(IF_ID_AM_bits),
    .instruction_out(IF_ID_Instr)
  );

  // ID/EX Pipeline Register Instance ✅
  id_ex_reg id_ex (
      .clk(clk),
      .reset(reset),
      .reg_write_enable_in(RegWrite_muxed),
      .mem_enable_in(MemEnable_muxed),
      .mem_rw_in(MemRW_muxed),    
      .mem_to_reg_select_in(MemtoReg_muxed),
      .alu_src_select_in(ALUSrc_muxed),
      .alu_control_in(ALUControl_muxed),
      .status_bit_in(S_bit_muxed),
      .mem_size_in(mem_size_muxed),
      .am_bits_in(IF_ID_AM_bits),                 
      .reg_write_enable_out(ID_EX_RegWrite),
      .mem_enable_out(ID_EX_MemEnable),
      .mem_rw_out(ID_EX_MemRW),
      .mem_to_reg_select_out(ID_EX_MemtoReg),
      .alu_src_select_out(ID_EX_ALUSrc),
      .alu_control_out(ID_EX_ALUControl),
      .status_bit_out(ID_EX_Status),
      .mem_size_out(ID_EX_mem_size),
      .am_bits_out(ID_EX_AM_bits)                
  );

  // EX/MEM Pipeline Register Instance ✅
  ex_mem_reg ex_mem (
      .clk(clk),
      .reset(reset),
      .reg_write_enable_in(ID_EX_RegWrite),
      .mem_enable_in(ID_EX_MemEnable),
      .mem_rw_in(ID_EX_MemRW),   
      .mem_to_reg_select_in(ID_EX_MemtoReg),
      .alu_src_select_in(ID_EX_ALUSrc),
      .alu_control_in(ID_EX_ALUControl),
      .status_bit_in(ID_EX_Status),
      .mem_size_in(ID_EX_mem_size),                
      .reg_write_enable_out(EX_MEM_RegWrite),
      .mem_enable_out(EX_MEM_MemEnable),
      .mem_rw_out(EX_MEM_MemRW), 
      .mem_to_reg_select_out(EX_MEM_MemtoReg),
      .alu_src_select_out(EX_MEM_ALUSrc),
      .alu_control_out(EX_MEM_ALUControl),
      .status_bit_out(EX_MEM_Status),
      .mem_size_out(EX_MEM_mem_size)               
  );

  // MEM/WB Pipeline Register Instance ✅
  mem_wb_reg mem_wb (
      .clk(clk),
      .reset(reset),
      .reg_write_enable_in(EX_MEM_RegWrite),
      .mem_enable_in(EX_MEM_MemEnable),
      .mem_rw_in(EX_MEM_MemRW),  
      .mem_to_reg_select_in(EX_MEM_MemtoReg),
      .alu_src_select_in(EX_MEM_ALUSrc),
      .alu_control_in(EX_MEM_ALUControl),
      .status_bit_in(EX_MEM_Status),
      .mem_size_in(EX_MEM_mem_size),               
      .reg_write_enable_out(MEM_WB_RegWrite),
      .mem_enable_out(MEM_WB_MemEnable),
      .mem_rw_out(MEM_WB_MemRW), 
      .mem_to_reg_select_out(MEM_WB_MemtoReg),
      .alu_src_select_out(MEM_WB_ALUSrc),
      .alu_control_out(MEM_WB_ALUControl),
      .status_bit_out(MEM_WB_Status),
      .mem_size_out(MEM_WB_mem_size)               
  );

  // Time calculation
  integer monitor_time;

  // Update the time on each clock
  always @(clk) begin
    monitor_time = $time;

    decode_instruction(IF_ID_Instr); // Decode instruction in ID stage
    
    // Print header if time is 0
    if (monitor_time == 0) begin
        $display("======= Simulation Start =======\n");
    end
    
    $display("Clock: %0d", monitor_time);
    $display("Program Counter: %0d\n", PC_current);

    $display("Instruction: %s", instruction_keyword);
    $display("Reset: %0b", reset);
    $display("Hazard Bit (CU MUX): %b\n", S_bit_mux);
    
    // Control Unit (ID Stage) signals
    $display("Control Unit Signals (ID Stage):");
    $display("    ID_RF_Enable               = %b", RegWrite_muxed);
    $display("    MEM_Enable                 = %b", MemEnable_muxed);
    $display("    MEM_RW                     = %b", MemRW_muxed);
    $display("    MEM_Size                   = %b", mem_size_muxed);
    $display("    ID_load_instr              = %b", MemtoReg_muxed);
    $display("    ID_ALU_Op                  = %b", ALUControl_muxed);
    $display("    AM                         = %b", IF_ID_AM_bits);
    $display("    S_bit                      = %b\n", S_bit_muxed);
    
    // Execute Stage signals
    $display("Execute Stage Signals:");
    $display("    ID_RF_Enable               = %b", ID_EX_RegWrite);
    $display("    MEM_Enable                 = %b", ID_EX_MemEnable);
    $display("    MEM_RW                     = %b", ID_EX_MemRW);
    $display("    MEM_Size                   = %b", ID_EX_mem_size);
    $display("    ID_load_instr              = %b", ID_EX_MemtoReg);
    $display("    ID_ALU_Op                  = %b", ID_EX_ALUControl);
    $display("    AM                         = %b", ID_EX_AM_bits);
    $display("    S_bit                      = %b", ID_EX_ALUSrc);
    $display("    B/BL                       = %b\n", PCSrc_muxed);
    // $display(, ID_EX_);
    
    // Memory Stage signals
    $display("Memory Stage Signals:");
    $display("    ID_RF_Enable               = %b", EX_MEM_RegWrite);
    $display("    MEM_Enable                 = %b", EX_MEM_MemEnable);
    $display("    MEM_RW                     = %b", EX_MEM_MemRW);
    $display("    MEM_Size                   = %b", EX_MEM_mem_size);
    $display("    ID_load_instr              = %b\n", EX_MEM_MemtoReg);
    
    // Write Back Stage signals
    $display("Write Back Stage Signals:");
    $display("    ID_RF_Enable               = %b", MEM_WB_RegWrite);
    
    $display("\n----------------------------------------\n");
  end

  // Add this task before the initial block
  task decode_instruction;
    input [31:0] instr;
    begin
        case(instr)
            32'b11100010_00010001_00000000_00000000: begin
                instruction_keyword = "ANDS";
            end
            32'b11100010_00000001_00000000_00000000: begin
                instruction_keyword = "AND ";
            end
            32'b11100000_10000000_01010001_10000011: begin
                instruction_keyword = "ADD ";
            end
            32'b11100111_11010001_00100000_00000000: begin
                instruction_keyword = "LDRB";
            end
            32'b11100101_10001010_01010000_00000000: begin
                instruction_keyword = "STR ";
            end
            32'b00011010_11111111_11111111_11111101: begin
                instruction_keyword = "BNE ";
            end
            32'b11011011_00000000_00000000_00001001: begin
                instruction_keyword = "BLLE";
            end
            32'b00000000_00000000_00000000_00000000: begin
                instruction_keyword = "NOP ";
            end
            default: begin
                instruction_keyword = "UNK ";
            end
        endcase
    end
  endtask

  // Update in the test bench's initial block
  initial begin
      // Initialize memory from inline binary string
      $readmemb("memory-preload.txt", imem.memory);
  
      // Initialize control signals
      reset = 1;
      IF_ID_Enable = 1;
      PC_enable = 1;
      S_bit_mux = 2'b00; // Initialize S_bit to 0
      instruction_keyword = "UNK"; // Initialize instruction keyword
      
      // Initialize all signals explicitly
      #0; // Force initialization at time 0
      
      // Wait 3 cycles then release reset
      #3;
      reset = 0;
  
      // Wait until time 32 (29 more units after reset at time 3)
      #29;
      S_bit_mux = 2'b01; // Set S_bit to 1
      
      #8;
      $finish;
  end
endmodule
