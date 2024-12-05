module data_memory (
    output reg [31:0] DO, // DataOut
    input wire [31:0] DI, // DataIn
    input wire [7:0] A, // Address
    input wire Size, // Size
    input wire RW, // RW
    input wire E // Enable
);
    reg [7:0] mem [0:255];      // 256 bytes of memory
    integer i, file, status;
    reg [7:0] byte_temp;

    initial begin
        // Initialize all memory to 0
        for (i = 0; i < 256; i = i + 1) begin
            mem[i] = 8'h0;
        end
    end

    always @(*) begin
        if (RW == 0) begin
            case (Size)
                0: DO = {24'b0, mem[A]};
                1: DO = {mem[A], mem[A+1], mem[A+2], mem[A+3]};
            endcase
        end
        if (RW == 1 && E == 1) begin
            DO = DI;
            case (Size)
                0: mem[A] = DI[7:0];
                1: begin
                    mem[A] = DI[31:24];    // Write MOST significant byte first
                    mem[A+1] = DI[23:16];
                    mem[A+2] = DI[15:8];
                    mem[A+3] = DI[7:0];
                end
            endcase
        end
    end
endmodule