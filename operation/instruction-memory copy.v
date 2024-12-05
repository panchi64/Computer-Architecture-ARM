module instruction_memory(
    input wire [7:0] A,
    output reg [31:0] I
);
    reg [7:0] memory [0:255];
    integer i, file, status;
    reg [7:0] temp;

    // Initialize memory
    initial begin
        for (i = 0; i < 256; i = i + 1) begin
            memory[i] = 8'h0;
        end
    end

    // Instruction fetch
    always @(*) begin
        I = {memory[A], memory[A+1], memory[A+2], memory[A+3]}; 
    end
endmodule