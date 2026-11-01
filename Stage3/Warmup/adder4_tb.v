`timescale 1ns/1ps
`default_nettype none

// Adder4 test all 256 input combinations

module adder4_tb();

reg [3:0] a;
reg [3:0] b;

wire [3:0] sum;
wire cout;

integer i;
integer errors;
reg [4:0] expected_sum;
reg expected_cout;

adder4 dut(.a(a),
.b(b),
.sum(sum),
.cout(cout)
);

initial begin
    $dumpfile("adder4.vcd");
    $dumpvars(0, adder4_tb); 

    errors = 0;

    for(i=0; i < 256; i = i+1) begin
        {a,b} = i[7:0];
        #10;

        expected_sum = a + b;
        expected_cout = expected_sum[4];

        if (cout !== expected_cout) begin
            $display("ERROR at %0d ns: a = %d, b = %d, sum = %d, cout = %b, expected_sum = %d, expected_cout=%b",
            $time, a, b, sum, cout, expected_sum, expected_cout);
            errors = errors +1;
        end
        else if (sum !== expected_sum[3:0]) begin
            $display("ERROR at %0d ns: a = %d, b = %d, sum = %d, cout = %b, expected_sum = %d, expected_cout=%b",
            $time, a, b, sum, cout, expected_sum, expected_cout);
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