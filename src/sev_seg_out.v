`ifndef _sev_seg_out_v_
`define _sev_seg_out_v_

`include `GRVM_PATH(io/seven_segment_displays/sev_seg_hex_multiplexed.v)
`include `GRVM_PATH(interfacing/register.v)
`include `GRVM_PATH(encoding/binary_to_bcd_8.v)

//TODO: make this use BCD and support twos complement

module sev_seg_out (
    inout [7 : 0] bus,
    input bus_clk,
    input sev_seg_clk,

    input OI, // Enable input from bus

    /* Currently not implemented, allows
    twos complement displaying if set */
    input twos_complement,

    input rst,

    output [7 : 0] segs, //Outputs to control each segment
    output [3 : 0] sel //Select which segment is being controlled
    );

    wire [7 : 0] display_data_bin;
    register output_register [7 : 0] (
        .in(bus),
        .out(display_data_bin),

        .clk(bus_clk),
        .clr(rst),
        .load(OI)
    );

    wire [11 : 0] display_data_bcd;
    binary_to_bcd_8 binary_to_bcd_8_inst (
        .binary(display_data_bin),
        .bcd(display_data_bcd)
    );

    sev_seg_hex_multiplexed #(
        .ACTIVE_HIGH(0),
        .NUMBER_OF_SEGMENTS(4)
        ) sev_seg (
        .in({4'b0, display_data_bcd}),

        .clk(sev_seg_clk),
        .rst(1'b0),

        .segs(segs),
        .sel(sel)
    );

endmodule

`endif
