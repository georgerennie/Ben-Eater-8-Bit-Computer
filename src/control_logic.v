`ifndef _control_logic_v_
`define _control_logic_v_

`include `GRVM_PATH(synchronous/pow_2_binary_counter.v)
`include `GRVM_PATH(encoding/binary_to_one_hot.v)

module control_logic (
    input control_clk,
    
    output HLT, //Halt
    output MI, //MAR in
    output RI, //RAM IO
    output RO,
    output IO, //Instruction register IO
    output II,
    output AI, //ALU A Reg IO
    output AO,
    output EO, //Sum Out
    output SU, //Subtract
    output BI, //ALU B Reg IO
    output OI, //Output Register in
    output CE, //PC Count enable
    output CO, //PC Out
    output J,  //PC Jump

    input IR_MSB4 //4 most significant bits of instruction register
    );

    wire [2 : 0] microcode_count;
    wire microcode_counter_reset;
    pow_2_binary_counter #(
        .SIZE(3),
        .SYNC_RESET(0)  //check this
        ) microcode_counter (
        .clk(control_clk),
        .rst(microcode_counter_reset),
        .out(microcode_count)
    );

    wire [7 : 0] one_hot_count_out;
    binary_to_one_hot #(
        .SIZE(3)
        ) one_hot_count (
        .in(microcode_count),
        .out(one_hot_count_out)
    );
    assign microcode_counter_reset = one_hot_count_out[5];

endmodule

`endif
