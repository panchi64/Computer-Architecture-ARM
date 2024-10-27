module data_memory (
    output reg [31:0] DO,        // DataOut
    input wire [31:0] DI,        // DataIn
    input wire [7:0] A,          // Address
    input wire Size,             // Size
    input wire RW,               // RW
    input wire E                 // Enable
);
    reg [7:0] mem [0:255];      // 256 bytes of memory
    integer i, file, status;
    reg [7:0] byte_temp;

    initial begin
        // Initialize all memory to 0
        for (i = 0; i < 256; i = i + 1) begin
            mem[i] = 8'h0;
        end
        
        // Read binary values from file
        i = 0;
        file = $fopen("precharge-data.txt", "r");
        if (file) begin
            while (i < 16) begin  // Read up to 16 bytes
                status = $fscanf(file, "%b", byte_temp);
                if (status == 1) begin
                    mem[i] = byte_temp;
                    i = i + 1;
                end
                else begin
                    i = 16;
                end
            end
            $fclose(file);
        end
    end

    always @(*) begin
        if (RW == 0) begin
            case (Size)
                0: DO = {24'b0, mem[A]};
                1: DO = {mem[A], mem[A+1], mem[A+2], mem[A+3]};
            endcase
        end
        if (RW == 1) begin
            case (Size)
                0: mem[A] = DI[7:0];
                1: begin
                    mem[A] = DI[31:24];
                    mem[A+1] = DI[23:16];
                    mem[A+2] = DI[15:8];
                    mem[A+3] = DI[7:0];
                end
            endcase
        end
    end
endmodule

// TODO: Something in here is fucked and I can't be bothered to fix it right now. Time is sensitive.