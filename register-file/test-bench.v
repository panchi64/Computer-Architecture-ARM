`timescale 1ns / 1ps

module register_file_tb;

    // Inputs
    reg [31:0] PW;
    reg [3:0] RW;
    reg E;
    reg CLK;
    reg [3:0] RA, RB, RC;

    // Outputs
    wire [31:0] PA, PB, PC;

    // Instantiate the Unit Under Test (UUT)
    register_file uut (
        .PW(PW), 
        .RW(RW), 
        .E(E), 
        .CLK(CLK), 
        .RA(RA), 
        .RB(RB), 
        .RC(RC), 
        .PA(PA), 
        .PB(PB), 
        .PC(PC)
    );

    // Clock generation
    initial begin
        CLK = 0;
        forever #5 CLK = ~CLK; // 100MHz clock
    end

    // Test scenario
    initial begin
        // Initialize inputs
        PW = 0; RW = 0; E = 0; RA = 0; RB = 0; RC = 0;

        // Wait for global reset
        #100;

        // Test case 1: Write to register 5
        PW = 32'hAABBCCDD;
        RW = 4'b0101; // Register 5
        E = 1;
        #10; // Wait for one clock cycle
        E = 0;

        // Test case 2: Read from register 5
        RA = 4'b0101; // Read from register 5
        #10;

        // Test case 3: Write to register 10
        PW = 32'h11223344;
        RW = 4'b1010; // Register 10
        E = 1;
        #10;
        E = 0;

        // Test case 4: Read from registers 5 and 10
        RA = 4'b0101; // Read from register 5
        RB = 4'b1010; // Read from register 10
        #10;

        // Test case 5: Write to register 15 (R15)
        PW = 32'hFFFFFFFF;
        RW = 4'b1111; // Register 15
        E = 1;
        #10;
        E = 0;

        // Test case 6: Read from R15 using PC
        RC = 4'b1111; // Read from register 15
        #10;

        // End simulation
        #100;
        $finish;
    end

    // Monitor
    initial begin
        $monitor("Time=%0t, E=%b, RW=%b, PW=%h, RA=%b, RB=%b, RC=%b, PA=%h, PB=%h, PC=%h",
                 $time, E, RW, PW, RA, RB, RC, PA, PB, PC);
    end

endmodule