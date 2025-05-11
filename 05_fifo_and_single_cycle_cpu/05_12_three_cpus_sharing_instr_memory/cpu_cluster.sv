//
//  schoolRISCV - small RISC-V CPU
//
//  Originally based on Sarah L. Harris MIPS CPU
//  & schoolMIPS project.
//
//  Copyright (c) 2017-2020 Stanislav Zhelnio & Aleksandr Romanov.
//
//  Modified in 2024 by Yuri Panchul & Mike Kuskov
//  for systemverilog-homework project.
//

module cpu_cluster
#(
    parameter nCPUs = 3
)
(
    input                        clk,      
    input                        rst,      

    input   [nCPUs - 1:0][31:0]  rstPC,    
    input   [nCPUs - 1:0][ 4:0]  regAddr,  
    output  [nCPUs - 1:0][31:0]  regData   
);

    logic [nCPUs - 1:0][31:0] imAddr;        
    logic [nCPUs - 1:0][31:0] imData;        
    logic [nCPUs - 1:0]       imDataVld;     
    logic [nCPUs - 1:0]       instr_req;     
    logic [nCPUs - 1:0]       instr_gnt;     
    logic [7:0]              arb_gnt;        
    logic [31:0]             current_addr;   
    logic [31:0]             current_data;   

    genvar i;
    generate
        for (i = 0; i < nCPUs; i++) begin : req_gen
            assign instr_req[i] = 1'b1;
        end
    endgenerate

    round_robin_arbiter_8 arbiter
    (
        .clk    (clk),
        .rst    (rst),
        .req    ({5'b0, instr_req}),  
        .gnt    (arb_gnt)             
    );

    assign instr_gnt = arb_gnt[2:0];

    always_comb begin
        current_addr = 32'h0;
        for (int i = 0; i < nCPUs; i++) begin
            if (instr_gnt[i]) begin
                current_addr = imAddr[i] << 2;  
            end
        end
    end

    instruction_rom #(
        .SIZE(64)
    ) instr_mem (
        .a  (current_addr[7:2]),  
        .rd (current_data)        
    );

    generate
        for (i = 0; i < nCPUs; i++) begin : data_dist
            assign imData[i] = instr_gnt[i] ? current_data : 32'h00000013;  
        end
    endgenerate

    generate
        for (i = 0; i < nCPUs; i++) begin : valid_gen
            assign imDataVld[i] = instr_gnt[i];
        end
    endgenerate

    generate
        for (i = 0; i < nCPUs; i++) begin : cpu_gen
            sr_cpu cpu (
                .clk        (clk),
                .rst        (rst),
                .rstPC      (rstPC[i]),
                .regAddr    (regAddr[i]),
                .regData    (regData[i]),
                .imAddr     (imAddr[i]),
                .imData     (imData[i]),
                .imDataVld  (imDataVld[i])
            );
        end
    endgenerate

endmodule
