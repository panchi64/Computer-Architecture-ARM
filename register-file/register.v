// 32bit
module register(
     input wire CLK,
     input wire RESET,
     input wire LOAD,
     input wire [31:0] d,
     output reg [31:0] q
);

    always @(posedge CLK or posedge RESET) begin
        if (RESET)
            q <= 32'b0;
        else if (LOAD)
            q <= d;
    end

endmodule