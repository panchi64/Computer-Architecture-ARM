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

        file = $fopen("precharge-data.txt", "r");
        if (file) begin
            for (i = 0; i < 16; i = i + 1) begin
                status = $fscanf(file, "%b", temp);
                if (status > 0) memory[i] = temp;
            end
            $fclose(file);
        end
    end

    // Instruction fetch
    always @(*) begin
        I = {memory[A], memory[A+1], memory[A+2], memory[A+3]}; 
    end
endmodule