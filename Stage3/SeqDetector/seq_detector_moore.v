`timescale 1ns/1ps
`default_nettype none

module seq_detector_moore (input wire clk, input wire reset, input wire din, output reg detected);

reg [2:0] state;

localparam [2:0] START = 0;
localparam [2:0] STATE_1 = 1;
localparam [2:0] STATE_10 = 2;
localparam [2:0] STATE_101 = 3;
localparam [2:0] STATE_1011 = 4;

always @(posedge clk) begin

if(reset) begin
    state <= START;
    detected <= 0;
end

else begin
    detected <= 0;

    case (state)
        START: state <= (din == 0) ? START : STATE_1;

        STATE_1: state <= (din == 0) ? STATE_10 : STATE_1;

        STATE_10: state <= (din == 0) ? START : STATE_101;

        STATE_101: begin
            state <= (din == 0) ? STATE_10 : STATE_1011;
            detected <= (din == 1);
        end

        STATE_1011: state <= (din == 0) ? STATE_10 : STATE_1;

        default : state <= START;
    endcase
end

end

endmodule

`default_nettype wire