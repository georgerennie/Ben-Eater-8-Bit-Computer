`ifndef _instruction_register_v_
`define _instruction_register_v_

`include `GRVM_PATH(interfacing/register.v)
`include `GRVM_PATH(interfacing/tri_state_buffer.v)

module instruction_register (
    inout [7 : 0] bus,
    input clk,
    input rst,

    output [3 : 0] MSB4, //4 most significant bits of instruction register
    
    input IO, //Output
    input II  //Input
    );

    wire [7 : 0] instruction_register_out;
    register instruction_register [7 : 0] (
        .in(bus),
        .out(instruction_register_out),

        .clk(clk),
        .load(II),
        .clr(rst)
    );

    tri_state_buffer instruction_buffer [3 : 0] (
        .in(instruction_register_out[3 : 0]),
        .out(bus[3 : 0]),
        .enable(IO)
    );

    assign MSB4 = instruction_register_out[7 : 4];
endmodule

`endif