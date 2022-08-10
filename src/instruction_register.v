`ifndef _INSTRUCTION_REGISTER_V_
`define _INSTRUCTION_REGISTER_V_

`default_nettype none

module instruction_register (
    inout [7:0] bus,
    input clk,
    input rst,

    // 4 most significant bits of instruction register
    output [3:0] MSB4,

    input IO, // Output
    input II  // Input
);

    reg [7:0] instruction;
    initial instruction = 0;
    always @(posedge clk) begin
        if (rst)
            instruction = 0;
        else if (II)
            instruction = bus;
    end

    assign bus[3:0] = IO ? instruction : 4'bzzzz;
    assign MSB4 = instruction[7:4];

`ifdef FORMAL
    always @* begin
        // Assume IO and II arent high at the same time
        if (IO)
            assume(!II);

        assert(MSB4 == instruction[7:4]);
        if (IO)
            assert(bus[3:0] == instruction[3:0]);
    end

    reg past_valid;
    initial past_valid = 0;
    always @(posedge clk) begin
        past_valid <= 1;

        if ($past(rst))
            assert(instruction == 0);
        else if ($past(II) && past_valid)
            assert(instruction == $past(bus));
    end
`endif // FORMAL
endmodule

`endif // _INSTRUCTION_REGISTER_V_
