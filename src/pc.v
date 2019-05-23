`ifndef _pc_v_
`define _pc_v_
//4 Bit program counter
`include `GRVM_PATH(interfacing/tri_state_buffer.v)

module pc (
    inout [7 : 0] bus,
    input clk,
    input CE, // Count enable
    input J, // Jump
    input CO // Counter out
    );

    reg [3 : 0] PC;

    reg buffer_en;
    tri_state_buffer out_buffer [3 : 0] (
        .in(PC),
        .enable(buffer_en),
        .out(bus[3 : 0])
    );

    always @(posedge clk) begin
        buffer_en = CO;

        if (J) begin
            PC = bus[3 : 0];
        end
        else if (CE) begin
            PC += 1'b1;
        end
    end

endmodule

`endif