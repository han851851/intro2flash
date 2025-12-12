module fullAdder(
    input logic x,y,Cin,
    output logic sum, Cout
);
// sum is XOR of Cin, x, y, so basically ha2 (ha1.sum, sum)
    assign sum = x ^ y ^ Cin;
    assign Cout = (x&y) | (x&Cin) | (y&Cin);

endmodule
