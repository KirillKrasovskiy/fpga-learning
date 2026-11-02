`timescale 1ns/1ps
`default_nettype none

module tick_gen #(parameter CLK_HZ = 125_000_000, parameter TICK_HZ = 1) 
(input clk, input reset, output reg tick);

localparam COUNTER_WIDTH = $clog2(CLK_HZ/TICK_HZ);
localparam CYCLE_COUNT = CLK_HZ/TICK_HZ - 1;
reg [COUNTER_WIDTH - 1:0] counter;

always @(posedge clk) begin
    tick <= 0;

    if (reset) begin
        counter <= 0;
    end
    else if (counter == CYCLE_COUNT) begin
        counter <= 0;
        tick <= 1'b1;
    end
    else begin
        counter <= counter + 1'b1;
    end  
end

endmodule

`default_nettype wire