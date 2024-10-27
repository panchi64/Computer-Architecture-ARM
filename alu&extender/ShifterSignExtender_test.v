`include "shiftersignextender.v"

module ShifterSignExtender_Test;
    reg [31:0] Rm;
    reg [11:0] I;
    reg [1:0] AM;
    wire [31:0] N;

    // Instantiate the Unit Under Test
    ShifterSignExtender uut (
        .Rm(Rm),
        .I(I),
        .AM(AM),
        .N(N)
    );

    initial begin
        Rm = 32'b10000100001100011111111111101010;
        I = 12'b001001101100;

        $display("AM  N (binary)"); 

        AM = 2'b00; #2; // Test addressing mode 00
        $display("%b  %b", AM, N); 

        AM = 2'b01; #2; // Test addressing mode 01
        $display("%b  %b", AM, N);

        AM = 2'b10; #2; // Test addressing mode 10
        $display("%b  %b", AM, N);

        AM = 2'b11; #2; // Test addressing mode 11
        $display("%b  %b", AM, N);

        $finish;
    end
endmodule