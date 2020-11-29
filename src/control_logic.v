`ifndef _CONTROL_LOGIC_V_
`define _CONTROL_LOGIC_V_

`default_nettype none

`include "instruction_decoder.v"

module control_logic (
    input clk,
    input rst,

    input [3 : 0] IR_MSB4, // 4 most significant bits of instruction register

    output HLT, // Halt
    output MI, // MAR in
    output RI, // RAM IO
    output RO,
    output IO, // Instruction register IO
    output II,
    output AI, // ALU A Reg IO
    output AO,
    output EO, // Sum Out
    output SU, // Subtract
    output BI, // ALU B Reg IO
    output OI, // Output Register in
    output CE, // PC Count enable
    output CO, // PC Out
    output J   // PC Jump
);

    reg [2:0] microcode_count;
    always @(posedge clk) begin
        if (rst)
            microcode_count <= 0;
        else if (microcode_count == 3'b100)
            microcode_count <= 0;
        else
            microcode_count <= microcode_count + 1;
    end

    wire [7 : 0] instr_decoder_addr;
    assign instr_decoder_addr = {
        IR_MSB4[3 : 0],
        1'b0,
        microcode_count[2 : 0]
    };

    instruction_decoder instr_decoder_inst (
        .clk(control_clk),
        .address(instr_decoder_addr),
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
        .J(J)
    );

endmodule

`endif // _CONTROL_LOGIC_V_
