`timescale 1ns / 1ps

module register_file_tb;

  parameter ADDR_WIDTH = 4;
  parameter DATA_WIDTH = 32;

  // Inputs
  reg [ADDR_WIDTH-1:0] RA, RB, RC, RW;
  reg [DATA_WIDTH-1:0] PW, PROGCOUNT;
  reg CLK, LE;

  // Outputs
  wire [DATA_WIDTH-1:0] PA, PB, PC;

  // Unit Under Test (UUT)
  register_file uut (
    .RA(RA), .RB(RB), .RC(RC), .RW(RW),
    .PA(PA), .PB(PB), .PC(PC),
    .PW(PW), .PROGCOUNT(PROGCOUNT),
    .CLK(CLK), .LE(LE)
  );

  initial begin
    CLK = 0;
    forever #2 CLK = ~CLK;
  end

  initial begin
    $display("Time  RW RA RB RC    PW       PA       PB       PC   PROGCOUNT");
    $display("----  -- -- -- -- -------- -------- -------- -------- --------");
    $monitor("%4d: %2d %2d %2d %2d %8d %8d %8d %8d %8d", 
             $time, RW, RA, RB, RC, PW, PA, PB, PC, PROGCOUNT);
  end

  initial begin
    // Time 0 values
    PROGCOUNT = 32;
    PW = 20;
    RW = 0;
    RA = 0;
    RB = 15;
    RC = 14;
    LE = 1;

    while (RA < 15) begin
      #4; // Wait for 4 time units
      PW = PW + 1;
      RW = RW + 1;
      RA = RA + 1;
      RB = (RB + 1) % 16; // Wrap around to 0 after 15
      RC = (RC + 1) % 16; // Wrap around to 0 after 15
      PROGCOUNT = PROGCOUNT + 1;
    end

    // RA reaches 15
    #20;

    $finish;
  end

endmodule