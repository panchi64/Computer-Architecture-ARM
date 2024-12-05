module if_id_reg (
    input wire clk,
    input wire reset,
    input wire enable,
    input wire [31:0] instruction_in,
    input wire [31:0] pc_plus_4_in,
    input wire [1:0] am_bits_in,

    output reg [31:0] pc_plus_4_out,
    output reg [1:0] am_bits_out,     
    output reg [31:0] instruction_out
);

    initial begin
        instruction_out = 32'b0;
        am_bits_out = 2'b00;
    end

    always @(posedge clk) begin
        if (reset) begin
            instruction_out <= 32'b0;
            am_bits_out <= 2'b00;
        end
        else if (enable) begin
            instruction_out <= instruction_in;
            am_bits_out <= am_bits_in;
        end
    end

endmodule