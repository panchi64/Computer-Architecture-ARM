`include "alu.v"

module ALU_Test;
    reg [31:0] A;
    reg [31:0] B;
    reg CIN;
    reg [3:0] Op;
    wire [31:0] Out;
    wire Z, N, C, V;

    // Instantiate the Unit Under Test
    ALU uut (
        .A(A),
        .B(B),
        .CIN(CIN),
        .Op(Op),
        .Out(Out),
        .Z(Z),
        .N(N),
        .C(C),
        .V(V)
    );

    initial begin
        A = 32'b10011100000000000000000000111000;
        B = 32'b10011100000000000000000000111000;
        CIN = 0;
        Op = 4'b0000; // Start with operation 0

        $display("Op    A (dec)                B (dec)                Out (dec)              Flags (Z N C V)");

        repeat (13) begin
            #2; // Wait for 2 time units
            $display("%b  %d (%b)  %d (%b)  %d (%b)  %b %b %b %b", Op, A, A, B, B, Out, Out, Z, N, C, V);
            Op = Op + 4'b0001;
        end

        CIN = 1; // Change carry input
        Op = 4'b0000;
        repeat (6) begin
            #2;
            $display("%b  %d (%b)  %d (%b)  %d (%b)  %b %b %b %b", Op, A, A, B, B, Out, Out, Z, N, C, V);
            Op = Op + 4'b0001;
        end

        $finish;
 end
endmodule