`ifndef _alu_v_
`define _alu_v_
`include `GRVM_PATH(arithmetic/alu/add_sub_alu.v)
`include `GRVM_PATH(interfacing/register.v)
`include `GRVM_PATH(interfacing/tri_state_buffer.v)

module alu(
    inout [7 : 0] bus,
    input clk,
    input clr, //Clears registers

    input load_A, //load and write alu registers to/from bus
    input load_B,
    input write_A,
    input write_B,

    input write_ALU, //write alu output to bus
    input subtract, //out = subtract ? A - B : A + B

    output carry, //Carry flag output to be fed into flag register
    output zero //Zero flag output to be fed into flag register
    );

    wire [7 : 0] reg_A_out;
    register reg_A [7 : 0] (
        .in(bus),
        .clk(clk),
        .clr(clr),
        .load(load_A),
        .out(reg_A_out)
    );

    wire [7 : 0] reg_B_out;
    register reg_B [7 : 0] (
        .in(bus),
        .clk(clk),
        .clr(clr),
        .load(load_B),
        .out(reg_B_out)
    );

    add_sub_alu #(.SIZE(8)) add_sub_alu_inst (
        .A(reg_A_out),
        .B(reg_B_out),
        .bus(bus),

        .subtract(subtract),
        .output_enable(write_ALU),
        .carry(carry),
        .zero(zero)
    );

    tri_state_buffer buffer_A [7 : 0] (
        .in(reg_A_out),
        .enable(write_A),
        .out(bus)
    );

    tri_state_buffer buffer_B [7 : 0] (
        .in(reg_B_out),
        .enable(write_B),
        .out(bus)
    );

endmodule

`endif