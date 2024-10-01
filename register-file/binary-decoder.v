module binary_decoder(
    input wire [3:0] in,
    output reg [15:0] out
);

    always @(*) begin
        out = 16'b0000_0000_0000_0000;
        
        case (in)
            4'b0000: out[0] = 1'b1;
            4'b0001: out[1] = 1'b1;
            4'b0010: out[2] = 1'b1;
            4'b0011: out[3] = 1'b1;
            4'b0100: out[4] = 1'b1;
            4'b0101: out[5] = 1'b1;
            4'b0110: out[6] = 1'b1;
            4'b0111: out[7] = 1'b1;
            4'b1000: out[8] = 1'b1;
            4'b1001: out[9] = 1'b1;
            4'b1010: out[10] = 1'b1;
            4'b1011: out[11] = 1'b1;
            4'b1100: out[12] = 1'b1;
            4'b1101: out[13] = 1'b1;
            4'b1110: out[14] = 1'b1;
            4'b1111: out[15] = 1'b1;
            default: out = 16'b0000_0000_0000_0000; // All outputs that for some reason fail to be decoded should be zero?
        endcase 
    end

endmodule