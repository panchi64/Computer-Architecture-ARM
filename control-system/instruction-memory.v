module instruction_memory(
    input wire [7:0] address,
    output reg [31:0] instruction
);
    reg [7:0] memory [0:255];
    integer i;

    // Initialize memory
    initial begin
        for (i = 0; i < 256; i = i + 1) begin
            memory[i] = 8'h0;
        end
    end

    // Instruction fetch - fixed variable names
    always @(*) begin
        instruction = {memory[address], memory[address+1], memory[address+2], memory[address+3]}; 
    end
endmodule