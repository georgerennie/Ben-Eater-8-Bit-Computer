`include "emulate_pull_down.v"

//Quickly include files from the George Rennie Verilog Modules Library:
`define GRVM_PATH(module_file_address) "../../Shared Files/Verilog/George-Rennie-Verilog-Modules/module_file_address"
`include `GRVM_PATH(synchronous/reset_conditioner.v)
`include `GRVM_PATH(interfacing/tri_state_buffer.v)
`include `GRVM_PATH(synchronous/binary_counter.v)

`include "alu.v"
`include "ram.v"
`include "pc.v"
`include "sev_seg_out.v"

module top(
    input clk,               // 100MHz clock
    input rst_n,             // reset button (active low)
    output reg [7:0] led,    // 8 user controllable LEDs

    output reg [23:0] io_led, // Alchitry IO pins
    inout [23:0] io_dip,
    inout [4:0] io_button,
    output [7:0] io_seg,
    output [3:0] io_sel,

    input usb_rx,            // USB->Serial input
    output usb_tx            // USB->Serial output
    );

    //emulate_pull_down caters for the lack of pull down resistors on the Cu
    wire[23:0] dip_pd_out;
    emulate_pull_down #(.SIZE (24)) dip_pd(
        .clk(clk),
        .in(io_dip),
        .out(dip_pd_out));

    wire[4:0] button_pd_out;
    emulate_pull_down #(.SIZE (5)) button_pd(
        .clk(clk),
        .in(io_button),
        .out(button_pd_out));

    binary_counter #(.SIZE(32)) clk_count (
        .clk(clk),
        .rst(1'b0),
        .top(32'hFFFFFFFF)
    );

    wire HLT; //Halt wire
    wire bus_clk;
    assign bus_clk = HLT ? 0 : clk_count.out[25];
    wire control_clk;
    assign control_clk = ~bus_clk;
    wire sev_seg_clk;
    assign sev_seg_clk = ~clk_count.out[15];

    assign HLT = dip_pd_out[9];

    wire rst;
    reset_conditioner reset_cond (
        .clk(bus_clk),
        .in(~rst_n),
        .out(rst)
    );

    wire [7 : 0] main_bus;
    always @* begin
      io_led[7 : 0] = main_bus;
    end

    tri_state_buffer test_input [7 : 0] (
        .in(dip_pd_out[7 : 0]),
        .enable(dip_pd_out[23]),
        .out(main_bus)
    );

    alu alu_inst (
        .bus(main_bus),
        .clk(bus_clk),
        .rst(rst),

        .AI(dip_pd_out[22]),
        .BI(dip_pd_out[21]),
        .AO(dip_pd_out[20]),
        .BO(dip_pd_out[19]),

        .EO(dip_pd_out[18]),
        .SU(dip_pd_out[17])
    );

    ram ram_inst (
        .bus(main_bus),
        .clk(bus_clk),
        .rst(rst),

        .MI(dip_pd_out[16]),
        .RO(dip_pd_out[15]),
        .RI(dip_pd_out[14])
    );

    pc pc_inst (
        .bus(main_bus),
        .clk(bus_clk),
        .CO(dip_pd_out[13]),
        .CE(dip_pd_out[12]),
        .J(dip_pd_out[11]),
        .rst(rst)
    );

    sev_seg_out sev_seg_out_inst (
        .bus(main_bus),
        .bus_clk(bus_clk),
        .sev_seg_clk(sev_seg_clk),

        .OI(dip_pd_out[10]),
        .rst(rst),
        
        .segs(io_seg),
        .sel(io_sel)
    );

    always @* begin
        led[0] = bus_clk;
    end

endmodule