// 4 Bit program counter

`ifndef _PC_V_
`define _PC_V_

`default_nettype none

module pc (
    inout [7:0] bus,
    input clk,
    input CE, // Count enable
    input J,  // Jump
    input CO, // Counter out
    input rst // Reset
);
    reg [3:0] PC;
    initial PC = 0;
    assign bus[3:0] = CO ? PC : 4'bzzzz;

    always @(posedge clk) begin
        if (rst)
            PC <= 0;
        else if (J)
            PC <= bus[3 : 0];
        else if (CE)
            PC <= PC + 1;
    end

`ifdef FORMAL
    always @* begin
        // Only one of J, CO and CE can be asserted at once
        if (J)
            assume(!CO && !CE);
        else if (CO)
            assume(!CE);

        if (!CO)
            assert(bus[3:0] == 4'bzzzz);
        else
            assert(bus[3:0] == PC);
    end

    reg past_valid;
    initial past_valid = 0;
    always @(posedge clk) begin
        past_valid <= 1;

       if ($past(rst))
            assert(bus[3:0] == 0);
        else if ($past(CE) && past_valid)
            assert(PC == $past(PC) + 4'b1);
    end
`endif // FORMAL
endmodule
`endif // _PC_V_
