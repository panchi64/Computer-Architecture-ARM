module id_forwarding_mux (
    input wire [31:0] reg_data,           // Original register data
    input wire [31:0] ex_forwarded_data,  // Data from EX stage
    input wire [31:0] mem_forwarded_data, // Data from MEM stage
    input wire [31:0] wb_forwarded_data,  // Data from WB stage
    input wire [1:0] forward_select,      // Forwarding control
    output reg [31:0] selected_data
);

    always @(*) begin
        case(forward_select)
            2'b00: selected_data = reg_data;           // No forwarding
            2'b01: selected_data = ex_forwarded_data;  // Forward from EX
            2'b10: selected_data = mem_forwarded_data; // Forward from MEM
            2'b11: selected_data = wb_forwarded_data;  // Forward from WB
        endcase
    end
endmodule