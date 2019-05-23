`ifndef _ram_v_
`define _ram_v_
//This ram only presents 16 8-bit words as per ben eater's design
//In its current implementation this ram cant be reset with the computer reset button, just by power 
//This also contains the MAR

`include `GRVM_PATH(interfacing/register.v)
`include `GRVM_PATH(interfacing/tri_state_buffer.v)

module ram (
    inout [7 : 0] bus,
    input clk,
    input clr,

    input MI, //Reads address into MAR from bus on clock posedge
    input RO, //Ouputs ram to bus
    input RI //Enables ram being read on positive clock edges
    );

    wire [3 : 0] mar_out;

    register MAR [3 : 0] (
        .in(bus[3 : 0]),
        .out(mar_out),
        .clk(clk),
        .load(MI),
        .clr(clr)
    );
 
    wire [7 : 0] ram_out;
    SB_RAM512x8 ram512x8_inst (
        .RADDR({5'h0, mar_out}),
        .RCLK(clk),
        .RCLKE(1'b1),
        .RDATA(ram_out),
        .RE(1'b1),
        .WDATA(bus),
        .WADDR({5'h0, mar_out}),
        .WCLK(clk),
        .WCLKE(1'b1),
        .WE(RI)
    );

    tri_state_buffer output_buf [7 : 0] (
            .in(ram_out),
            .out(bus),
            .enable(RO)
    );

    defparam ram512x8_inst.INIT_0 = 256'h0000000000000000000000000000000000000000000000000000000000000000; //Only the second half of this is memory locations accessibly in this processor

endmodule

`endif