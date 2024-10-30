module id_ex_reg (
    input wire clk,                      
    input wire reset,                    
    
    // Control signals input
    input wire reg_write_enable_in,      
    input wire mem_write_enable_in,      
    input wire mem_to_reg_select_in,     
    input wire alu_src_select_in,        
    input wire [1:0] alu_control_in,     
    input wire status_bits_in,
    
    // Control signals output  
    output reg reg_write_enable_out,     
    output reg mem_write_enable_out,     
    output reg mem_to_reg_select_out,    
    output reg alu_src_select_out,       
    output reg [1:0] alu_control_out,    
    output reg status_bits_out
);

    initial begin
        reg_write_enable_out = 1'b0;
        mem_write_enable_out = 1'b0;
        mem_to_reg_select_out = 1'b0;
        alu_src_select_out = 1'b0;
        alu_control_out = 2'b00;
        status_bits_out = 1'b0;
    end

    always @(posedge clk) begin
        if (reset) begin
            reg_write_enable_out <= 0;
            mem_write_enable_out <= 0;
            mem_to_reg_select_out <= 0;
            alu_src_select_out <= 0;
            alu_control_out <= 2'b0;
            status_bits_out <= 0;
        end
        else begin
            reg_write_enable_out <= reg_write_enable_in;
            mem_write_enable_out <= mem_write_enable_in;
            mem_to_reg_select_out <= mem_to_reg_select_in;
            alu_src_select_out <= alu_src_select_in;
            alu_control_out <= alu_control_in;
            status_bits_out <= status_bits_in;
        end
    end
endmodule