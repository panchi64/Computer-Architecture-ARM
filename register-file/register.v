// 32bit
module register(
     input wire clk,
     input wire reset,
     input wire load,
     input wire [31:0] d,
     output reg [31:0] q;
);

    always @(posedge clk or posedge reset) begin
        if (reset)
            q <= 32'b0;
        else if (load)
            q <= d;
    end

endmodule