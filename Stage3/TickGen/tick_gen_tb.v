`timescale 1ns/1ps
`default_nettype none

//tick generator testbench test.

module tick_gen_tb();

reg clk = 0;
reg reset = 0;
wire tick;

integer i;
integer k = 0;
integer tick_count = 0;
reg expected_tick;

integer errors = 0;

localparam TB_CLK_HZ = 10;

tick_gen #(.CLK_HZ(TB_CLK_HZ)) dut (
.clk(clk),
.reset(reset),
.tick(tick)
);

always begin
    #4 clk = 1;
    #4 clk = 0;
end

initial begin
    $dumpfile("tick_gen.vcd");
    $dumpvars(0, tick_gen_tb);

    for(i = 0; i < 100*TB_CLK_HZ; i = i + 1) begin
        k = k + 1;
            if (i < 20 || i === 545) begin
                reset = 1;
                k = 0;
            end
            else begin 
                reset = 0;
            end
        expected_tick = (k !== 0 && ( k % TB_CLK_HZ) === 0) ? 1 : 0;

        @(negedge clk);

        //1 no tick during reset
        if (reset === 1 && tick === 1) begin
            $display("ERROR, tick during reset at %0d, clk=%0d, reset=%0d, tick = %0d", $time, clk, reset, tick);
            errors = errors + 1;
        end
        //2 ticks exactly TB_CLK_HZ cycles apart
        //3 each tick exactly 1 cycle wide
        if ( tick !== expected_tick  )  begin
            $display("ERROR, tick at wrong cycle at %0d, with k = %0d expected tick = %0d", $time, k, expected_tick);
            errors = errors + 1;
        end

        //4 at least 5 ticks in total.
        if (tick == 1) begin
            tick_count = tick_count + 1;
        end

    end

    if (tick_count < 5) begin
        $display("ERROR, too few ticks at the end at %0d, tick_count = %0d", $time, tick_count);
        errors = errors + 1;
    end

    if (errors > 0) begin
        $display("FAIL. The tick_gen design had %0d errors", errors);
    end
    else begin
        $display("PASS. The tick_gen design passed with no errors.");
    end

$finish;
end



endmodule

`default_nettype wire