// 32bit
module register(
     input wire CLK,
     input wire LOAD,
     input wire [31:0] d,
     output reg [31:0] q
);

    always @(posedge CLK) begin
        if (LOAD)
            q <= d;
    end

endmodule