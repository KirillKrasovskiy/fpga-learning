`default_nettype none
`timescale 1ns/1ps

module full_adder(input a,b,cin, output sum, cout);

wire c;
assign c = b ^ cin;

assign sum = a ^ c;
assign cout = (a & c) | (b & cin);

endmodule

`default_nettype wire