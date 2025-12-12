module halfAdder(
    input logic x,y,
    output logic sum,Cout
);

    assign sum = x ^ y;
    assign Cout = x & y;
    
endmodule
