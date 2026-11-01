`timescale 1ns/1ps
`default_nettype none

// Mux4 test all 64 input combinations

module mux4_tb();

reg d0;
reg d1;
reg d2;
reg d3;
reg [1:0] sel;

wire y;

integer i;
integer errors;
reg expected;

mux4 dut(.d0(d0),
    .d1(d1),
    .d2(d2),
    .d3(d3),
    .sel(sel),
    .y(y)
);

initial begin
    $dumpfile("mux4.vcd");
    $dumpvars(0, mux4_tb); 

    errors = 0;

    for(i=0; i < 64; i = i+1) begin
        {sel, d3, d2, d1, d0} = i[5:0];
        #10;

        expected = i[sel];

        if (y !== expected) begin
            $display("ERROR at %0d ns: sel=%d, data=%b, got = %b, expected=%b", $time, i[5:4], i[3:0], y, expected);
            errors = errors +1;
        end
    end

    if (errors > 0) begin
        $display("FAIL. The design had %0d errors", errors);
    end
    else begin
        $display("PASS. The design passed with no errors.");
    end

    $finish;
end

endmodule

`default_nettype wire