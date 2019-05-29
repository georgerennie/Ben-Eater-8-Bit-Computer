`ifndef _control_logic_v_
`define _control_logic_v_

`include `GRVM_PATH(synchronous/binary_counter.v)

`include "instruction_decoder.v"

module control_logic (
    input control_clk,
    input rst,
    
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

    input [3 : 0] IR_MSB4 //4 most significant bits of instruction register
    );

    wire [2 : 0] microcode_count;
    binary_counter #(
        .SIZE(3),
        .SYNC_RESET(0)  //check this
        ) microcode_counter (
        .clk(control_clk),
        .rst(rst),
        .top(3'b100),
        .out(microcode_count)
    );

    wire [7 : 0] instr_decoder_addr;
    assign instr_decoder_addr = {
        IR_MSB4[3 : 0],
        1'b0,
        microcode_count[2 : 0]
    };

    wire [15 : 0] instr_decoder_data;
    assign {
        HLT,
        MI,
        RI,
        RO,
        IO,
        II,
        AI,
        AO,
        EO,
        SU,
        BI,
        OI,
        CE,
        CO,
        J
    } = instr_decoder_data[15 : 1];

    instruction_decoder instr_decoder_inst (
        .clk(control_clk),
        .address(instr_decoder_addr),
        .data(instr_decoder_data)
    );

endmodule

`endif
