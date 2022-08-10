`ifndef _alu_v_
`define _alu_v_
`include `GRVM_PATH(arithmetic/alu/add_sub_alu.v)
`include `GRVM_PATH(interfacing/register.v)
`include `GRVM_PATH(interfacing/tri_state_buffer.v)

module alu(
    inout [7 : 0] bus,
    input clk,
    input rst, //Clears registers

    input AI, //load and write alu registers to/from bus
    input BI,
    input AO,
    input BO,

    input EO, //Output to bus
    input SU, //Subtract

    output CY, //Carry flag output to be fed into flag register
    output Z //Zero flag output to be fed into flag register
    );

    wire [7 : 0] reg_A_out;
    register reg_A [7 : 0] (
        .in(bus),
        .clk(clk),
        .clr(rst),
        .load(AI),
        .out(reg_A_out)
    );

    wire [7 : 0] reg_B_out;
    register reg_B [7 : 0] (
        .in(bus),
        .clk(clk),
        .clr(rst),
        .load(BI),
        .out(reg_B_out)
    );

    add_sub_alu #(.SIZE(8)) add_sub_alu_inst (
        .A(reg_A_out),
        .B(reg_B_out),
        .bus(bus),

        .subtract(SU),
        .output_enable(EO),
        .carry(carry),
        .zero(zero)
    );

    tri_state_buffer buffer_A [7 : 0] (
        .in(reg_A_out),
        .enable(AO),
        .out(bus)
    );

    tri_state_buffer buffer_B [7 : 0] (
        .in(reg_B_out),
        .enable(BO),
        .out(bus)
    );

endmodule

`endif