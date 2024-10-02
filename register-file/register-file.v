module register_file(
    input wire [31:0] PW,
    input wire [3:0] RW,
    input wire E,
    input wire CLK,
    input wire [3:0] RA,
    input wire [3:0] RB,
    input wire [3:0] RC,
    output wire [31:0] PA,
    output wire [31:0] PB,
    output wire [31:0] PC
);

    wire [15:0] decoder_output;
    wire [31:0] register_outputs [15:0];

    binary_decoder decoder(
        .in(RW),
        .ENABLE(E),
        .out(decoder_output)
    );

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : registers // Generating the 16 registers needed
            register reg_instance(
                .CLK(CLK),
                .RESET(1'b0), // No reset signal yet
                .LOAD(decoder_output[i]),
                .d(PW),
                .q(register_outputs[i])
            );
        end
    endgenerate

    multiplexer mux_A(
        .in0(register_outputs[0]), 
        .in1(register_outputs[1]), 
        .in2(register_outputs[2]), 
        .in3(register_outputs[3]),
        .in4(register_outputs[4]), 
        .in5(register_outputs[5]), 
        .in6(register_outputs[6]), 
        .in7(register_outputs[7]),
        .in8(register_outputs[8]),
        .in9(register_outputs[9]),
        .in10(register_outputs[10]),
        .in11(register_outputs[11]),
        .in12(register_outputs[12]), 
        .in13(register_outputs[13]), 
        .in14(register_outputs[14]), 
        .in15(register_outputs[15]),
        .SEL(RA),
        .OUT(PA)
    );
    multiplexer mux_B(
        .in0(register_outputs[0]), 
        .in1(register_outputs[1]), 
        .in2(register_outputs[2]), 
        .in3(register_outputs[3]),
        .in4(register_outputs[4]), 
        .in5(register_outputs[5]), 
        .in6(register_outputs[6]), 
        .in7(register_outputs[7]),
        .in8(register_outputs[8]),
        .in9(register_outputs[9]),
        .in10(register_outputs[10]),
        .in11(register_outputs[11]),
        .in12(register_outputs[12]), 
        .in13(register_outputs[13]), 
        .in14(register_outputs[14]), 
        .in15(register_outputs[15]),
        .SEL(RB),
        .OUT(PB)
    );
    multiplexer mux_C(
        .in0(register_outputs[0]), 
        .in1(register_outputs[1]), 
        .in2(register_outputs[2]), 
        .in3(register_outputs[3]),
        .in4(register_outputs[4]), 
        .in5(register_outputs[5]), 
        .in6(register_outputs[6]), 
        .in7(register_outputs[7]),
        .in8(register_outputs[8]),
        .in9(register_outputs[9]),
        .in10(register_outputs[10]),
        .in11(register_outputs[11]),
        .in12(register_outputs[12]), 
        .in13(register_outputs[13]), 
        .in14(register_outputs[14]), 
        .in15(register_outputs[15]),
        .SEL(RC),
        .OUT(PC)
    );

endmodule