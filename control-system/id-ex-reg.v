module id_ex_register(
    input wire clk,
    input wire reset,
    // Control signals from ID stage
    input wire [3:0] ex_control_in,   // Control signals for EX stage
    input wire [3:0] mem_control_in,  // Control signals for MEM stage
    input wire [3:0] wb_control_in,   // Control signals for WB stage
    
    // Control signals to EX stage
    output reg [3:0] ex_control_out,
    output reg [3:0] mem_control_out,
    output reg [3:0] wb_control_out
);

    // Rising edge triggered with synchronous reset
    always @(posedge clk) begin
        if (reset) begin
            // Clear all control signals on reset
            ex_control_out <= 4'b0;
            mem_control_out <= 4'b0;
            wb_control_out <= 4'b0;
        end
        else begin
            // Propagate control signals
            ex_control_out <= ex_control_in;
            mem_control_out <= mem_control_in;
            wb_control_out <= wb_control_in;
        end
    end

endmodule