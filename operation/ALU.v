module ALU(
    input [31:0] A,
    input [31:0] B,
    input CIN,
    input [3:0] Op, // Operation selector
    output reg [31:0] Out,
    output reg Z, N, C, V
);

    always @(*) begin
        Z = 0;
        N = 0;
        C = 0;
        V = 0;

        case (Op)
            4'b0000: {C, Out} = A + B;
            4'b0001: {C, Out} = A + B + CIN;
            4'b0010: {C, Out} = A - B;
            4'b0011: {C, Out} = A - B - CIN;
            4'b0100: {C, Out} = B - A;
            4'b0101: {C, Out} = B - A - CIN;
            4'b0110: Out = A & B;
            4'b0111: Out = A | B;
            4'b1000: Out = A ^ B;
            4'b1001: Out = ~A;
            4'b1010: Out = B;
            4'b1011: Out = ~B;
            4'b1100: Out = A & ~B;
            default: Out = 32'b0; // Default case: output zero  
        endcase

        Z = (Out == 32'b0) ? 1 : 0; // Set zero flag if output is zero
        N = Out[31]; // Set negative flag based on the sign bit of output
        V = ((Op == 4'b0000 || Op == 4'b0001) && (~(A[31] ^ B[31]) & (A[31] ^ Out[31]))) ||
            ((Op == 4'b0010 || Op == 4'b0011) && (A[31] ^ B[31]) & (A[31] ^ Out[31])) ||
            ((Op == 4'b0100 || Op == 4'b0101) && (B[31] ^ A[31]) & (B[31] ^ Out[31])); // Set overflow flag based on operation
        
        if (Op == 4'b0010 || Op == 4'b0011 || Op == 4'b0100 || Op == 4'b0101) begin
            C = (A < B) ? 1 : 0; // Set carry flag for subtraction operations
        end
    end
endmodule
