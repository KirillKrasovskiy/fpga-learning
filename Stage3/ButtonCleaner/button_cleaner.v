`timescale 1ns/1ps
`default_nettype none

module button_cleaner #(parameter CLK_HZ = 125_000_000, parameter DEBOUNCE_MS = 10)
(input wire clk, input wire reset, input wire btn_in, output reg btn_level = 0, output reg btn_press = 0);

//Division first to prevent overflow
localparam DEBOUNCE_CYCLES = CLK_HZ/1000*DEBOUNCE_MS;

reg state = 0;
reg [$clog2(DEBOUNCE_CYCLES) - 1:0] cycle = 0;
(* ASYNC_REG = "TRUE" *) reg [1:0] btn_sync = 0;

always @(posedge clk) begin

//Synchronizer
btn_sync[0] <= btn_in;
btn_sync[1] <= btn_sync[0]; 

if (reset) begin
    btn_level <= 0;
    btn_press <= 0;
    cycle <= 0;
    state <= 0;
end

else begin
    if(state == 0) begin
        if (btn_sync[1]) begin
            if (cycle == DEBOUNCE_CYCLES - 1) begin
                state <= 1;
                cycle <= 0;
                btn_level <= 1;
                btn_press <= 1;
            end
            else begin
                cycle <= cycle + 1;
            end
        end
        else begin
            cycle <= 0;
        end
    end
    else begin
        btn_press <= 0;
        if(!btn_sync[1]) begin
            if (cycle == DEBOUNCE_CYCLES - 1) begin
                state <= 0;
                cycle <= 0;
                btn_level <= 0;
            end
            else begin
                cycle <= cycle + 1;
            end
        end
        else begin
            cycle <= 0;
        end
    end

end

end

endmodule

`default_nettype wire