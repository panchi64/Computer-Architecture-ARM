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
        .in(RW)
        .ENABLE(E)
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
        .in0(reg_outputs[0]), 
        .in1(reg_outputs[1]), 
        .in2(reg_outputs[2]), 
        .in3(reg_outputs[3]),
        .in4(reg_outputs[4]), 
        .in5(reg_outputs[5]), 
        .in6(reg_outputs[6]), 
        .in7(reg_outputs[7]),
        .in8(reg_outputs[8]),
        .in9(reg_outputs[9]),
        .in10(reg_outputs[10]),
        .in11(reg_outputs[11]),
        .in12(reg_outputs[12]), 
        .in13(reg_outputs[13]), 
        .in14(reg_outputs[14]), 
        .in15(reg_outputs[15]),
        .SEL(RA),
        .OUT(PA)
    );
    multiplexer mux_B(
        .in0(reg_outputs[0]), 
        .in1(reg_outputs[1]), 
        .in2(reg_outputs[2]), 
        .in3(reg_outputs[3]),
        .in4(reg_outputs[4]), 
        .in5(reg_outputs[5]), 
        .in6(reg_outputs[6]), 
        .in7(reg_outputs[7]),
        .in8(reg_outputs[8]),
        .in9(reg_outputs[9]),
        .in10(reg_outputs[10]),
        .in11(reg_outputs[11]),
        .in12(reg_outputs[12]), 
        .in13(reg_outputs[13]), 
        .in14(reg_outputs[14]), 
        .in15(reg_outputs[15]),
        .SEL(RB),
        .OUT(PB)
    );
    multiplexer mux_C(
        .in0(reg_outputs[0]), 
        .in1(reg_outputs[1]), 
        .in2(reg_outputs[2]), 
        .in3(reg_outputs[3]),
        .in4(reg_outputs[4]), 
        .in5(reg_outputs[5]), 
        .in6(reg_outputs[6]), 
        .in7(reg_outputs[7]),
        .in8(reg_outputs[8]),
        .in9(reg_outputs[9]),
        .in10(reg_outputs[10]),
        .in11(reg_outputs[11]),
        .in12(reg_outputs[12]), 
        .in13(reg_outputs[13]), 
        .in14(reg_outputs[14]), 
        .in15(reg_outputs[15]),
        .SEL(RC),
        .OUT(PC)
    );

endmodule