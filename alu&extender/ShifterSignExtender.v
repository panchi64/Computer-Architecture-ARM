module ShifterSignExtender(
    input [31:0] Rm,
    input [11:0] I,
    input [1:0] AM,
    output reg [31:0] N
);

    integer positions;

    always @(*) begin
        case (AM)
            2'b00: begin
                positions = 2 * I[11:8];
                N = ({24'b0, I[7:0]} >> positions) | ({24'b0, I[7:0]} << (32 - positions)); // Circular shift
            end
            2'b01: begin
                N = Rm; // No change
            end
            2'b10: begin
                N = {20'b0, I};
            end
            2'b11: begin
                case (I[6:5])
                    2'b00: N = Rm << I[11:7]; // Logical left shift
                    2'b01: N = Rm >> I[11:7]; // Logical right shift
                    2'b10: N = $signed(Rm) >>> I[11:7]; // Arithmetic right shift
                    2'b11: N = (Rm >> I[11:7]) | (Rm << (32 - I[11:7]));
                endcase
            end
            default: N = 32'b0;
        endcase
    end
endmodule