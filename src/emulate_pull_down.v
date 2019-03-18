//A module to emulate pull down resistors by occasionally pulling outputs low
//Built for use with alchitry CU and first gen alchitry IO boards

`ifndef emulate_pull_down
`define emulate_pull_down 

module emulate_pull_down #(parameter SIZE = 1) ( //Number of input pins
    input                 clk, //Clock
    inout      [SIZE-1:0] in,
    output reg [SIZE-1:0] out);

    assign in = {SIZE {(flip_q == 1'h0) ? 1'b0 : 1'bz}};
    
    reg [3:0] flip_d, flip_q; //4 Bit Counter
    reg [SIZE-1:0] saved_d, saved_q;
    
    always @* begin
        saved_d = saved_q;
        flip_d = flip_q;
        
        flip_d = flip_q + 1'h1;
        if (flip_q > 2'h2) begin //Save input on stages 4 and onwards of counter
            saved_d = in;
        end
        out = saved_q;
    end
    
    always @(posedge clk) begin
        flip_q <= flip_d;
        saved_q <= saved_d;
    end
endmodule

`endif