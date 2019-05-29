`include "emulate_pull_down.v"

//Quickly include files from the George Rennie Verilog Modules Library:
`define GRVM_PATH(module_file_address) "../../Shared Files/Verilog/George-Rennie-Verilog-Modules/module_file_address"
`include `GRVM_PATH(synchronous/reset_conditioner.v)
`include `GRVM_PATH(interfacing/tri_state_buffer.v)
`include `GRVM_PATH(synchronous/binary_counter.v)

`include "alu.v"
`include "instruction_register.v"
`include "ram.v"
`include "pc.v"
`include "sev_seg_out.v"
`include "control_logic.v"

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

    wire HLT, bus_clk, control_clk, sev_seg_clk;
    assign bus_clk = HLT ? 0 : clk_count.out[24];
    assign control_clk = ~bus_clk;
    assign sev_seg_clk = ~clk_count.out[15];

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

    wire MI, RO, RI;
    ram ram_inst (
        .bus(main_bus),
        .clk(bus_clk),
        .rst(rst),

        .MI(MI),
        .RO(RO),
        .RI(RI)
    );

    wire AI, BI, AO, EO, SU;
    alu alu_inst (
        .bus(main_bus),
        .clk(bus_clk),
        .rst(rst),

        .AI(AI),
        .BI(BI),
        .AO(AO),
        .BO(1'b0),

        .EO(EO),
        .SU(SU)
    );

    wire IO, II;
    wire [3 : 0] IR_MSB4;
    instruction_register instruction_register_inst (
        .bus(main_bus),
        .clk(bus_clk),
        .rst(rst),

        .MSB4(IR_MSB4),
        .IO(IO),
        .II(II)
    );

    wire CO, CE, J;
    pc pc_inst (
        .bus(main_bus),
        .clk(bus_clk),
        .rst(rst),

        .CO(CO),
        .CE(CE),
        .J(J)
    );

    wire OI;
    sev_seg_out sev_seg_out_inst (
        .bus(main_bus),
        .bus_clk(bus_clk),
        .sev_seg_clk(sev_seg_clk),

        .OI(OI),
        .rst(rst),
        
        .segs(io_seg),
        .sel(io_sel)
    );

    control_logic control_logic_inst (
        .control_clk(control_clk),
        .rst(rst),

        .HLT(HLT),
        .MI(MI),
        .RI(RI),
        .RO(RO),
        .IO(IO),
        .II(II),
        .AI(AI),
        .AO(AO),
        .EO(EO),
        .SU(SU),
        .BI(BI),
        .OI(OI),
        .CE(CE),
        .CO(CO),
        .J(J),

        .IR_MSB4(IR_MSB4)
    );

    always @* begin
        led[0] = bus_clk;
    end

endmodule
