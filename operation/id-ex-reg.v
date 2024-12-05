module id_ex_reg (
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
    input wire [1:0] am_bits_in,
    input wire pc_src_select_in,
    input wire [31:0] reg_data_a_in,      // Register A data
    input wire [31:0] reg_data_b_in,      // Register B data
    input wire [31:0] reg_data_c_in,      // Register C data
    input wire [31:0] extended_imm_in,    // Sign extended immediate
    input wire [3:0] reg_dst_in,          // Destination register
    input wire [31:0] pc_plus_4_in,       // PC+4 value

    
    // Control signals output  
    output reg reg_write_enable_out,     
    output reg mem_enable_out,     
    output reg mem_rw_out,
    output reg mem_to_reg_select_out,    
    output reg alu_src_select_out,       
    output reg [3:0] alu_control_out,    
    output reg status_bit_out,
    output reg mem_size_out,
    output reg [1:0] am_bits_out,
    output reg pc_src_select_out,
    output reg [31:0] reg_data_a_out,
    output reg [31:0] reg_data_b_out,
    output reg [31:0] reg_data_c_out,
    output reg [31:0] extended_imm_out,
    output reg [3:0] reg_dst_out,
    output reg [31:0] pc_plus_4_out
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
        am_bits_out = 2'b00;
        pc_src_select_out = 0;
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
            am_bits_out <= 2'b00;
            pc_src_select_out = 0;
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
            am_bits_out <= am_bits_in;
            pc_src_select_out <= pc_src_select_in;
        end
    end
endmodule