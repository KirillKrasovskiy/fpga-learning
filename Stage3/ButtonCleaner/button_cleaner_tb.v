`timescale 1ns/1ps
`default_nettype none

module button_cleaner_tb();

reg clk = 0;
reg reset = 0;
reg btn_in = 0;

wire btn_level;
wire btn_press;

localparam TB_CLK_HZ = 2000;
localparam TB_DEBOUNCE_MS = 10;
localparam PASS_CYCLE = TB_DEBOUNCE_MS*TB_CLK_HZ/1000;
localparam TOLERANCE = 3;

integer errors = 0;
integer i = 0;
integer k = 0; //cycle Count
integer pulse_count = 0;

integer seed = 100500;

reg expected_pulses = 0;
reg expected_btn_level = 0;
reg latency_tolerance = 0;

button_cleaner #(.CLK_HZ(TB_CLK_HZ), .DEBOUNCE_MS(TB_DEBOUNCE_MS))
dut (.clk(clk), .reset(reset), .btn_in(btn_in), .btn_level(btn_level), .btn_press(btn_press));

//Only the cycle count is important.
always begin
    #4 clk = 1;
    #4 clk = 0;
end

initial begin
    $dumpfile("button_cleaner.vcd");
    $dumpvars(0, button_cleaner_tb);

    for(i = 0; i < 720; i = i+1) begin
        latency_tolerance = 0;
        reset = 0;

        //reset tests all throughout.
        if ((i < 30) || i === 47 || i == 165 || i === 450 || i === 700) begin
            reset = 1;
            k = 0;
            expected_btn_level = 0;
        end

        //Holding the button tests
        else if( (i > 70 && i < 110) || (135 < i && i < 200) || ((i>=600) && i < 650)) begin
            btn_in = 1;
            if (expected_btn_level !== 1) begin
                k = k+1;
            end
            else begin
                k = 0;
            end
        end

        //Bouncing behaviour test.
        else if ((i >= 300) && (i < 375)) begin
            if (k < 1 + $urandom(seed) % 30) begin
                btn_in = 1;
                if (!expected_btn_level) begin
                    k = k + 1;
                end
                else begin
                    k = 0;
                end
            end
            else begin
                btn_in = 0;
                if (expected_btn_level) begin
                    k = k + 1;
                end
                else begin
                    k = 0;
                end
            end
        end

        //Holding after bounce.
        else if ( (i >= 375) && (i < 450)) begin
            btn_in = 1;
            if (!expected_btn_level) begin
                k = k + 1;
            end
            else begin
                k = 0;
            end
        end

        //Testing spikes. 
        else if ((i >= 450) && (i < 600)) begin
            if(k < 1 + $urandom(seed) % 19) begin
                btn_in = 1;
                k = k + 1;
            end
            else begin 
                k = 0;
                btn_in = 0;
            end
        end

        //Testing release spike
        else if ( (i >=650) && i < 700) begin
            if(k < 1 + $urandom(seed) % 19) begin
                btn_in = 0;
                k = k + 1;
            end
            else begin
                k = 0;
                btn_in = 1;
            end
        end

        else begin
            btn_in = 0;
            if (expected_btn_level) begin
                k = k + 1;
            end
            else begin
                k = 0;
            end
        end

        //10 ms is TB_DEBOUNCE_MS*10^-3 *TB_CLK_HZ cycles. Spikes shorter than that are ignored.
        //Allow for a slight delay.
        //Known gap: Current model doesn't catch a short drop after accept; it's too late to catch a missing cycle clear.
        if( (k >= PASS_CYCLE) && !expected_btn_level) begin
            if (k < PASS_CYCLE + TOLERANCE) begin
                latency_tolerance = 1;
            end
            else begin
                expected_btn_level = 1;
                k = 0;
                latency_tolerance = 0;
                expected_pulses = 1;
            end
        end
        else if( (k >= PASS_CYCLE) && expected_btn_level) begin
            if (k < PASS_CYCLE + TOLERANCE) begin
                latency_tolerance = 1;
            end
            else begin
                expected_btn_level = 0;
                k = 0;
                latency_tolerance = 0;
                expected_pulses = 0;
            end
        end
        else begin
            expected_pulses = 0;
            pulse_count = 0;
        end

        @(negedge clk);
        pulse_count = pulse_count + btn_press;

        if(btn_level !== expected_btn_level && !latency_tolerance) begin
            $display("ERROR, button level is wrong at cycle %0d, btn_level = %0d, expected_btn_level = %0d", i, btn_level, expected_btn_level);
            errors = errors + 1;
        end

        if (reset === 1 && (btn_press === 1 || btn_level === 1)) begin
            $display("ERROR, raised button press or level at cycle %0d, btn_press = %0d, btn_level = %0d, reset = %0d", i, btn_press, btn_level, reset);
            errors = errors + 1;
        end

        //Outside the range, the count goes back to 0 every cycle.
        if (pulse_count !== expected_pulses && !latency_tolerance) begin
            $display("ERROR, wrong amount of pulses at cycle %0d, pulse_count = %0d, expected_pulses = %0d", i, pulse_count, expected_pulses);
            errors = errors + 1;
        end

    end

if (errors > 0) begin
    $display("FAIL. The button cleaner design had %0d errors.", errors);
end
else begin
    $display("PASS. The button cleaner design passed with no errors.");
end


$finish;
end

endmodule

`default_nettype wire