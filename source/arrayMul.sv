module arrayMul (
    input  logic [3:0] A,   // multiplicand, 0–9
    input  logic [3:0] B,   // multiplier, 0–9
    output logic [7:0] P    // product, 0-81, but 8 bits b/c inputs are 4 bits
);

    // Refer to 'wallaceTree.pdf' in githup repo for variable names and calculation steps!

    //Partial products
    logic [3:0] pp0,  pp1,  pp2,  pp3;
    assign pp0 = A & {4{B[0]}}; // 1st row (at top)
    assign pp1 = A & {4{B[1]}}; // 2nd row
    assign pp2 = A & {4{B[2]}}; // 3rd row
    assign pp3 = A & {4{B[3]}}; // 4th row (at bottom)

    
    //Wallace reduction
    //Sum and carries
    // 'sum11' as in sum, 1st reduction layer, 1st column
    logic sum11, cout11, // pp0[1] + pp1[0]
          sum12, cout12, // pp0[2] + pp1[1] + pp2[0]
          sum13, cout13, // pp0[3] + pp1[2] + pp2[1] + pp3[0]
          sum14, cout14, // pp1[3] + pp2[2] + pp3[1]
          sum15, cout15; // pp2[3] + pp3[2]

    // First reduction, max height 4 -> 3
    halfAdder red1col1 (.x(pp0[1]), .y(pp1[0]), .sum(sum11), .Cout(cout11));
    fullAdder red1col2 (.x(pp0[2]), .y(pp1[1]), .Cin(pp2[0]), .sum(sum12), .Cout(cout12));
    fullAdder red1col3 (.x(pp0[3]), .y(pp1[2]), .Cin(pp2[1]), .sum(sum13), .Cout(cout13));
    halfAdder red1col4 (.x(pp1[3]), .y(pp2[2]), .sum(sum14), .Cout(cout14));

    // Second reduction, max height 3 -> 2
    logic sum22, cout22,
          sum23, cout23,
          sum24, cout24,
          sum25, cout25;

    halfAdder red2col2 (.x(cout11), .y(sum12), .sum(sum22), .Cout(cout22));
    fullAdder red2col3 (.x(cout12), .y(sum13), .Cin(pp3[0]), .sum(sum23), .Cout(cout23));
    fullAdder red2col4 (.x(cout13), .y(sum14), .Cin(pp3[1]), .sum(sum24), .Cout(cout24));
    fullAdder red2col5 (.x(cout14), .y(pp2[3]), .Cin(pp3[2]), .sum(sum25), .Cout(cout25));
    
    // "Ripple Carry" to get P
    // 1st method: more HAs and FAs
    logic fc3, fc4, fc5, fc6; // carries

    assign P[0] = pp0[0];
    assign P[1] = sum11;
    assign P[2] = sum22;
    halfAdder p3 (.x(cout22), .y(sum23), .sum(P[3]), .Cout(fc3));
    fullAdder p4 (.x(fc3), .y(cout23), .Cin(sum24), .sum(P[4]), .Cout(fc4));
    fullAdder p5 (.x(fc4), .y(cout24), .Cin(sum25), .sum(P[5]), .Cout(fc5));
    fullAdder p6 (.x(fc5), .y(cout25), .Cin(pp3[3]), .sum(P[6]), .Cout(fc6));
    assign P[7] = fc6;

endmodule
