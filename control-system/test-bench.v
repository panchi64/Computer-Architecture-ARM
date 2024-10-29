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
  reg PC_enable;                 // Program Counter enable signal (changed from wire to reg)
  wire [31:0] PC_current;        // Current Program Counter value
  wire [31:0] PC_plus_4;         // PC + 4 for next sequential instruction
  wire [31:0] instruction;       // Current instruction from memory

  
  // ID Stage Signals
  wire [31:0] IF_ID_Instr;    // Instruction passed to ID stage
  
  // Control Unit Signals
  wire RegWrite;              // Register file write enable
  wire MemWrite;              // Memory write enable
  wire MemtoReg;              // Select between ALU result and memory data
  wire ALUSrc;                // Select between register and immediate
  wire [1:0] S_bit_ctrl;      // Register source selection from control unit
  reg  [1:0] S_bit_forced;    // Testbench forced value
  wire [1:0] ALUControl;      // ALU operation control
  wire PCSrc;                 // PC source selection for branches
  
  // EX Stage Signals
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

  wire [1:0] S_bit_muxed;         // Muxed status bits
  wire [1:0] ALUControl_muxed;    // Muxed ALU control
  wire MemtoReg_muxed;            // Muxed memory to register select
 
  reg [31:0] instruction_keyword; // For storing instruction text

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
    .mem_write_enable(MemWrite),
    .mem_to_reg_select(MemtoReg),
    .alu_source_select(ALUSrc),
    .status_bits(S_bit_ctrl),
    .alu_operation(ALUControl),
    .pc_source_select(PCSrc)
);

  // Control Unit Multiplexer Instance ✅
  cu_mux control_mux (
    .reg_write_enable_in(RegWrite),
    .mem_write_enable_in(MemWrite),
    .mem_to_reg_select_in(MemtoReg),
    .alu_src_in(ALUSrc),
    .status_bits_in(S_bit_forced),
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
    .reg_write_enable_in(RegWrite_muxed),
    .mem_write_enable_in(MemWrite_muxed),
    .mem_to_reg_select_in(MemtoReg_muxed),
    .alu_src_select_in(ALUSrc_muxed),
    .alu_control_in(ALUControl_muxed),
    .reg_write_enable_out(ID_EX_RegWrite),
    .mem_write_enable_out(ID_EX_MemWrite),
    .mem_to_reg_select_out(ID_EX_MemtoReg),
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
    .mem_write_enable_out(EX_MEM_MemWrite)
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

  reg [31:0] cycle_count;
  wire [63:0] monitor_time;
  assign monitor_time = $time/2;

  initial begin
    
    // Initialize memory from inline binary string
    $readmemb("memory-preload.txt", imem.memory);

    // Initialize control signals
    reset = 1;
    IF_ID_Enable = 1;
    PC_enable = 1;
    cycle_count = 0;
    S_bit_forced = 2'b00; // Initialize S_bit to 0
    instruction_keyword = "UNK"; // Initialize instruction keyword
    
    $display("\n=== Simulation Start ===\n");
    
    // Wait 3 cycles then release reset
    #3;
    reset = 0;

    // Wait until time 32 (29 more units after reset at time 3)
    #29;
    S_bit_forced = 2'b01; // Set S_bit to 1
    
    $monitor("\nTime: %0d\nInstruction: %s\nPC: %0d | CU: RegW=%b MemW=%b Mem2Reg=%b ALUSrc=%b Status=%b ALUOp=%b PCSrc=%b\nEX:  RegW=%b MemW=%b Mem2Reg=%b ALUSrc=%b ALUOp=%b\nMEM: RegW=%b MemW=%b\nWB:  RegW=%b Mem2Reg=%b\n----------------------------------------",
        monitor_time,
        instruction_keyword,
        PC_current,
        // Control Unit outputs
        RegWrite, MemWrite, MemtoReg, ALUSrc, S_bit_ctrl, ALUControl, PCSrc,
        // EX Stage
        ID_EX_RegWrite, ID_EX_MemWrite, ID_EX_MemtoReg, ID_EX_ALUSrc, ID_EX_ALUControl,
        // MEM Stage
        EX_MEM_RegWrite, EX_MEM_MemWrite,
        // WB Stage
        MEM_WB_RegWrite, MEM_WB_MemtoReg
    );

    #40;
    $finish;
end

always @(instruction) begin
    case(instruction)
        32'b11100010_00010001_00000000_00000000: begin  // First instruction
            instruction_keyword = "ANDS";
            $strobe("Decoded: ANDS R0,R1,#0");
        end
        32'b11100010_00000001_00000000_00000000: begin  // Seventh instruction
            instruction_keyword = "AND ";
            $strobe("Decoded: AND R0,R1,#0");
        end
        32'b11100000_10000000_01010001_10000011: begin
            instruction_keyword = "ADD ";
            $strobe("Decoded: ADD R5,R0,R3,LSL #3");
        end
        32'b11100111_11010001_00100000_00000000: begin
            instruction_keyword = "LDRB";
            $strobe("Decoded: LDRB R2,[R1,R0]");
        end
        32'b11100101_10001010_01010000_00000000: begin
            instruction_keyword = "STR ";
            $strobe("Decoded: STR R5,[R10,#0]");
        end
        32'b00011010_11111111_11111111_11111101: begin
            instruction_keyword = "BNE ";
            $strobe("Decoded: BNE -3");
        end
        32'b11011011_00000000_00000000_00001001: begin
            instruction_keyword = "BLLE";
            $strobe("Decoded: BLLE +9");
        end
        32'b00000000_00000000_00000000_00000000: begin
            instruction_keyword = "NOP ";
            $strobe("Decoded: NOP");
        end
        default: begin
            instruction_keyword = "UNK ";
            $strobe("Decoded: Unknown Instruction");
        end
    endcase
end
endmodule
