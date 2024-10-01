module multiplexer(
    input wire [3:0] A,
    input wire [3:0] B,
    input wire S,
    input wire [3:0] O
);

assign O = S ? A : B;

endmodule