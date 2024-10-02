// 16 to 1
module multiplexer(
    input wire [31:0] in0, in1, in2, in3, in4, in5, in6, in7, in8, in9, in10, in11, in12, in13, in14, in15,
    input wire [3:0] SEL,
    output wire [31:0] OUT
);

    always @(*) begin
        case(SEL)
            4'b0000: OUT = in0;
            4'b0001: OUT = in1;
            4'b0010: OUT = in2;
            4'b0011: OUT = in3;
            4'b0100: OUT = in4;
            4'b0101: OUT = in5;
            4'b0110: OUT = in6;
            4'b0111: OUT = in7;
            4'b1000: OUT = in8;
            4'b1001: OUT = in9;
            4'b1010: OUT = in10;
            4'b1011: OUT = in11;
            4'b1100: OUT = in12;
            4'b1101: OUT = in13;
            4'b1110: OUT = in14;
            4'b1111: OUT = in15;
            default: OUT = 32'bx; // Unknown state
        endcase
    end

endmodule