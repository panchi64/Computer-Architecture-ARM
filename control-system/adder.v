module adder(
    input [31:0] in_a,
    input [31:0] in_b,
    output [31:0] out
);
    assign out = in_a + in_b;
endmodule