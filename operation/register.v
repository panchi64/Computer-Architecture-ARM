// 32bit
module register(
     input wire CLK,
     input wire LOAD,
     input wire [31:0] d,
     output reg [31:0] q
);

    initial begin
        q = 32'b0;  // Initialize register value
    end

    always @(posedge CLK) begin
        if (LOAD)
            q <= d;
    end

endmodule