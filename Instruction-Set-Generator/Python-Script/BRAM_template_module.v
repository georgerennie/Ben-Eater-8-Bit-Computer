/*This file is automatically generated from an excel file by a python script
located in Instruction-Set-Generator. Any changes made to this file will be
deleted when this python script runs*/

`ifndef _${module_name}_v_
`define _${module_name}_v_

module ${module_name} (
    input  [7  : 0] address,
    output [15 : 0] data,
    input clk
    );

    SB_RAM256x16 ram256x16_inst (
        .RADDR(address),
        .RCLK(clk),
        .RCLKE(1'b1),
        .RDATA(data),
        .RE(1'b1),
        .WDATA(16'b0),
        .WADDR(8'b0),
        .WCLK(1'b0),
        .WCLKE(1'b0),
        .WE(1'b0),
        .MASK(16'b0)
    );

    defparam ram256x16_inst.INIT_0 = 256'h${data_0};
    defparam ram256x16_inst.INIT_1 = 256'h${data_1};
    defparam ram256x16_inst.INIT_2 = 256'h${data_2};
    defparam ram256x16_inst.INIT_3 = 256'h${data_3};
    defparam ram256x16_inst.INIT_4 = 256'h${data_4};
    defparam ram256x16_inst.INIT_5 = 256'h${data_5};
    defparam ram256x16_inst.INIT_6 = 256'h${data_6};
    defparam ram256x16_inst.INIT_7 = 256'h${data_7};
    defparam ram256x16_inst.INIT_8 = 256'h${data_8};
    defparam ram256x16_inst.INIT_9 = 256'h${data_9};
    defparam ram256x16_inst.INIT_A = 256'h${data_A};
    defparam ram256x16_inst.INIT_B = 256'h${data_B};
    defparam ram256x16_inst.INIT_C = 256'h${data_C};
    defparam ram256x16_inst.INIT_D = 256'h${data_D};
    defparam ram256x16_inst.INIT_E = 256'h${data_E};
    defparam ram256x16_inst.INIT_F = 256'h${data_F};

endmodule
`endif