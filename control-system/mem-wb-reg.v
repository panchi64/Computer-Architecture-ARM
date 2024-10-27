module mem_wb_register(
    input wire clk,
    input wire reset,
    // Control signals from MEM stage
    input wire [3:0] wb_control_in,   // Control signals for WB stage
    
    // Control signals to WB stage
    output reg [3:0] wb_control_out
);

    // Rising edge triggered with synchronous reset
    always @(posedge clk) begin
        if (reset) begin
            // Clear control signals on reset
            wb_control_out <= 4'b0;
        end
        else begin
            // Propagate control signals
            wb_control_out <= wb_control_in;
        end
    end

endmodule