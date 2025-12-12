module matmul (
    input  logic [3:0] A00, A01, A10, A11,   // Matrix A entries
    input  logic [3:0] B00, B01, B10, B11,   // Matrix B entries
    output logic [7:0] C00, C01, C10, C11    // Result matrix entries
);    

    //Partial products
    logic [7:0] p00, p01, p02, p03, p04, p05, p06, p07;

    //Find partial products using array multiplier module
    arrayMul m00 (.A(A00), .B(B00), .P(p00));
    arrayMul m01 (.A(A01), .B(B10), .P(p01));
    arrayMul m02 (.A(A00), .B(B01), .P(p02));
    arrayMul m03 (.A(A01), .B(B11), .P(p03));
    arrayMul m04 (.A(A10), .B(B00), .P(p04));
    arrayMul m05 (.A(A11), .B(B10), .P(p05));
    arrayMul m06 (.A(A10), .B(B01), .P(p06));
    arrayMul m07 (.A(A11), .B(B11), .P(p07));

    /*
    daddaMul m00 (.A(A00), .B(B00), .P(p00));
    daddaMul m01 (.A(A01), .B(B10), .P(p01));
    daddaMul m02 (.A(A00), .B(B01), .P(p02));
    daddaMul m03 (.A(A01), .B(B11), .P(p03));
    daddaMul m04 (.A(A10), .B(B00), .P(p04));
    daddaMul m05 (.A(A11), .B(B10), .P(p05));
    daddaMul m06 (.A(A10), .B(B01), .P(p06));
    daddaMul m07 (.A(A11), .B(B11), .P(p07));
    */

    //Assign results to output matrix
    assign C00 = p00 + p01;
    assign C01 = p02 + p03;
    assign C10 = p04 + p05;
    assign C11 = p06 + p07;

endmodule
