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
    input rst,

    input MI, //Reads address into MAR from bus on clock posedge
    input RO, //Ouputs ram to bus
    input RI //Enables ram being read on positive clock edges
    );

    reg [8 : 0] mar;
    always @(posedge clk) begin
        mar = {5'h0, bus[3 : 0]};
    end

    wire [7 : 0] ram_out;
    SB_RAM512x8 ram512x8_inst (
        .RADDR(mar),
        .RCLK(~clk),
        .RCLKE(1'b1),
        .RDATA(ram_out),
        .RE(1'b1),
        .WDATA(bus),
        .WADDR(mar),
        .WCLK(clk),
        .WCLKE(1'b1),
        .WE(RI)
    );

    tri_state_buffer output_buf [7 : 0] (
        .in(ram_out),
        .out(bus),
        .enable(RO)
    );

    defparam ram512x8_inst.INIT_0 = 256'h000000000000000000000000000000000100010000000000604F1E4D2F4EE01D; //Only the second half of this is memory locations accessible in this processor

endmodule

`endif
