`include "emulate_pull_down.v"

//Quickly include files from the George Rennie Verilog Modules Library:
`define GRVM_PATH(module_file_address) "../../Shared Files/Verilog/George-Rennie-Verilog-Modules/module_file_address"
`include `GRVM_PATH(synchronous/reset_conditioner.v)
`include `GRVM_PATH(interfacing/tri_state_buffer.v)
`include `GRVM_PATH(synchronous/binary_counter.v)

`include "alu.v"

module top(
    input clk,               // 100MHz clock
    input rst_n,             // reset button (active low)
    output reg [7:0] led,    // 8 user controllable LEDs

    output reg [23:0] io_led, // Alchitry IO pins
    inout [23:0] io_dip,
    inout [4:0] io_button,
    output reg [7:0] io_seg,
    output reg [3:0] io_sel,

    input usb_rx,            // USB->Serial input
    output usb_tx            // USB->Serial output
    );

    wire rst;
    reset_conditioner reset_cond (
        .clk(clk),
        .in(~rst_n),
        .out(rst)
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

    wire [7 : 0] main_bus;
    always @* begin
      io_led[7 : 0] = main_bus;
    end

    wire slow_clk;
    binary_counter #(.SIZE(32)) clk_count (
        .clk(clk),
        .rst(rst),
        .top(32'hFFFFFFFF)
    );

    assign slow_clk = ~clk_count.out[27];
    //assign slow_clk = clk;

    tri_state_buffer test_input [7 : 0] (
        .in(dip_pd_out[7 : 0]),
        .enable(dip_pd_out[23]),
        .out(main_bus)
    );

    alu alu_inst(
        .bus(main_bus),
        .clk(slow_clk),
        .clr(rst),

        .load_A(dip_pd_out[22]),
        .load_B(dip_pd_out[21]),
        .write_A(dip_pd_out[20]),
        .write_B(dip_pd_out[19]),

        .write_ALU(dip_pd_out[18]),
        .subtract(dip_pd_out[17])
    );

    always @* begin
        io_led [9 : 8] = {alu_inst.zero, alu_inst.carry};
        led[0] = slow_clk;
    end

endmodule