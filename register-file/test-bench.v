`timescale 1ns / 1ps

module register_file_tb;

  // Parameters
  parameter ADDR_WIDTH = 4;
  parameter DATA_WIDTH = 32;

  // Inputs
  reg [ADDR_WIDTH-1:0] RA, RB, RC, RW;
  reg [DATA_WIDTH-1:0] PW, PROGCOUNT;
  reg CLK, LE;

  // Outputs
  wire [DATA_WIDTH-1:0] PA, PB, PC;

  // Instantiate the Unit Under Test (UUT)
  register_file uut (
    .RA(RA), .RB(RB), .RC(RC), .RW(RW),
    .PA(PA), .PB(PB), .PC(PC),
    .PW(PW), .PROGCOUNT(PROGCOUNT),
    .CLK(CLK), .LE(LE)
  );

  // Clock generation
  initial begin
    CLK = 0;
    forever #2 CLK = ~CLK;
  end

  // Monitor for tracking changes with labeled columns
  initial begin
    $display("Time  RW RA RB RC    PW       PA       PB       PC");
    $display("----  -- -- -- -- -------- -------- -------- --------");
    $monitor("%4t: %2d %2d %2d %2d %8d %8d %8d %8d", 
             $time, RW, RA, RB, RC, PW, PA, PB, PC);
  end

  // Test stimulus
  initial begin
    // Initialize inputs at time 0
    PROGCOUNT = 32;
    PW = 20;
    RW = 0;
    RA = 0;
    RB = 15;
    RC = 14;
    LE = 1; // Enabling write operations

    // Wait for 4 time units before starting the loop
    #4;

    // Loop to increment values every 4 time units
    while (RA < 15) begin
      #4; // Wait for 4 time units
      PW = PW + 1;
      RW = RW + 1;
      RA = RA + 1;
      RB = (RB + 1) % 16; // Wrap around to 0 after 15
      RC = (RC + 1) % 16; // Wrap around to 0 after 15
    end

    // Run for a few more cycles after RA reaches 15
    #20;

    // End simulation
    $finish;
  end

endmodule