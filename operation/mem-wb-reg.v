module mem_wb_reg (
    input wire clk,                  
    input wire reset,                
    
    // Control signals input
    input wire reg_write_enable_in,  
    input wire mem_enable_in,  
    input wire mem_rw_in,
    input wire mem_to_reg_select_in, 
    input wire alu_src_select_in,
    input wire [3:0] alu_control_in,
    input wire status_bit_in,
    input wire mem_size_in,
    
    // Data path signals (added)
    input wire [31:0] alu_result_in,
    input wire [31:0] mem_data_in,
    input wire [3:0] write_reg_addr_in,
    
    // Control signals output
    output reg reg_write_enable_out,       
    output reg mem_enable_out,        
    output reg mem_rw_out,
    output reg mem_to_reg_select_out,       
    output reg alu_src_select_out,
    output reg [3:0] alu_control_out,
    output reg status_bit_out,
    output reg mem_size_out,
    
    // Data path signals output (added)
    output reg [31:0] alu_result_out,
    output reg [31:0] mem_data_out,
    output reg [3:0] write_reg_addr_out
);

    initial begin
        reg_write_enable_out = 0;
        mem_enable_out = 0;
        mem_rw_out = 0;
        mem_to_reg_select_out = 0;
        alu_src_select_out = 0;
        alu_control_out = 4'b0000;
        status_bit_out = 0;
        mem_size_out = 0;
        alu_result_out = 32'b0;
        mem_data_out = 32'b0;
        write_reg_addr_out = 4'b0;
    end

    always @(posedge clk) begin
        if (reset) begin
            reg_write_enable_out <= 0;
            mem_enable_out <= 0;
            mem_rw_out <= 0;
            mem_to_reg_select_out <= 0;
            alu_src_select_out <= 0;
            alu_control_out <= 4'b0000;
            status_bit_out <= 0;
            mem_size_out <= 0;
            alu_result_out <= 32'b0;
            mem_data_out <= 32'b0;
            write_reg_addr_out <= 4'b0;
        end
        else begin
            reg_write_enable_out <= reg_write_enable_in;
            mem_enable_out <= mem_enable_in;
            mem_rw_out <= mem_rw_in;
            mem_to_reg_select_out <= mem_to_reg_select_in;
            alu_src_select_out <= alu_src_select_in;
            alu_control_out <= alu_control_in;
            status_bit_out <= status_bit_in;
            mem_size_out <= mem_size_in;
            alu_result_out <= alu_result_in;
            mem_data_out <= mem_data_in;
            write_reg_addr_out <= write_reg_addr_in;
        end
    end
endmodule