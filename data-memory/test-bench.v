module combined_memory_tb;
    // Data Memory signals
    reg [31:0] DI;
    reg [7:0] A_data;
    reg Size, RW, E;
    wire [31:0] DO;
    // Instruction Memory signals
    reg [7:0] A_instr;
    wire [31:0] I;

    // Instantiate both memories
    data_memory dm (
        .DI(DI),
        .A(A_data),
        .Size(Size),
        .RW(RW),
        .E(E),
        .DO(DO)
    );

    instruction_memory im (
        .A(A_instr),
        .I(I)
    );

    initial begin
        // Initialize all signals
        DI = 32'h0;
        A_data = 8'h0;
        A_instr = 8'h0;
        Size = 1'b0;
        RW = 1'b0;
        E = 1'b0;

        // Wait for memory initialization
        #10;

        // Print Instruction Memory Test Header
        $display("\n=== INSTRUCTION MEMORY TEST ===");
        $display("A (Decimal) | I (Hexadecimal)");
        $display("------------------------");

        // Test instruction memory
        A_instr = 8'd0; #10 $display("%d | %h", A_instr, I);
        A_instr = 8'd4; #10 $display("%d | %h", A_instr, I);
        A_instr = 8'd8; #10 $display("%d | %h", A_instr, I);
        A_instr = 8'd12; #10 $display("%d | %h", A_instr, I);

        // Print Data Memory Test Header
        $display("\n=== DATA MEMORY TEST ===");
        $display("A (Decimal) | DO (Hexadecimal) | Size | R/W | E | Data Written");
        $display("------------------------------------------------------------");

        // Test Case 1: Read words from locations 0, 4, 8, and 12
        Size = 1'b1; // Word mode
        RW = 1'b0;   // Read mode
        E = 1'b0;    // Disable writes
        A_data = 8'd0;
        #10 $display("%3d          | %h          | %b    | %b   | %b | N/A", A_data, DO, Size, RW, E);
        A_data = 8'd4;
        #10 $display("%3d          | %h          | %b    | %b   | %b | N/A", A_data, DO, Size, RW, E);
        A_data = 8'd8;
        #10 $display("%3d          | %h          | %b    | %b   | %b | N/A", A_data, DO, Size, RW, E);
        A_data = 8'd12;
        #10 $display("%3d         | %h          | %b    | %b   | %b | N/A", A_data, DO, Size, RW, E);

        // Test Case 2: Read byte from location 0 and word from location 4
        Size = 1'b0; // Byte mode
        A_data = 8'd0;
        #10 $display("%3d          | %h          | %b    | %b   | %b | N/A", A_data, DO, Size, RW, E);
        Size = 1'b1; // Word mode
        A_data = 8'd4;
        #10 $display("%3d          | %h          | %b    | %b   | %b | N/A", A_data, DO, Size, RW, E);

        // Test Case 3: Write operations
        RW = 1'b1; // Write mode
        E = 1'b1;  // Enable writes

        // Write byte 0xA6 to location 0
        Size = 1'b0;
        A_data = 8'd0;
        DI = 32'h000000A6;  // Changed from 32'hA6
        #10 $display("%3d          | %h          | %b    | %b   | %b | %h", A_data, DO, Size, RW, E, DI);

        // Write byte 0xDD to location 2
        A_data = 8'd2;
        DI = 32'h000000DD;  // Changed from 32'hDD
        #10 $display("%3d          | %h          | %b    | %b   | %b | %h", A_data, DO, Size, RW, E, DI);

        // Write word 0xABCDEF01 to location 8
        Size = 1'b1;
        A_data = 8'd8;
        DI = 32'hABCDEF01;
        #10 $display("%3d          | %h          | %b    | %b   | %b | %h", A_data, DO, Size, RW, E, DI);

        // Test Case 4: Read words after writing
        RW = 1'b0; // Read mode
        E = 1'b0;  // Disable writes
        Size = 1'b1; // Word mode
        A_data = 8'd0;
        #10 $display("%3d          | %h          | %b    | %b   | %b | N/A", A_data, DO, Size, RW, E);
        A_data = 8'd4;
        #10 $display("%3d          | %h          | %b    | %b   | %b | N/A", A_data, DO, Size, RW, E);
        A_data = 8'd8;
        #10 $display("%3d          | %h          | %b    | %b   | %b | N/A", A_data, DO, Size, RW, E);

        #10 $finish;
    end
endmodule