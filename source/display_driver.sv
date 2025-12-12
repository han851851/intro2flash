module display_driver (
    input  logic [7:0] val_in,   // 8-bit input number (0-99)
    output logic [6:0] seg_tens, // Segments for the "Tens" digit
    output logic [6:0] seg_ones  // Segments for the "Ones" digit
);

    logic [3:0] tens;
    logic [3:0] ones;

    // 1. Binary to BCD Conversion
    // Since your max product is 81 (9x9), simple math works fine here.
    assign tens = (val_in / 10) % 10;
    assign ones = val_in % 10;

    // 2. Instantiate 7-Segment Decoders
    seven_seg tens_decoder (
        .bcd(tens),
        .seg(seg_tens)
    );

    seven_seg ones_decoder (
        .bcd(ones),
        .seg(seg_ones)
    );

endmodule

// Helper Module: Single Digit Decoder
module seven_seg (
    input  logic [3:0] bcd,
    output logic [6:0] seg
);
    // Standard 7-Segment Map
    // Adjust 0 vs 1 depending on if your board is Common Anode or Cathode.
    // This mapping assumes 0 = ON (Common Anode), which is standard for many FPGA boards.
    // If your segments remain dark, invert these bits (replace 0 with 1).
    always_comb begin
        case(bcd)
            //                  gfedcba
            4'd0: seg = 7'b1000000; // 0
            4'd1: seg = 7'b1111001; // 1
            4'd2: seg = 7'b0100100; // 2
            4'd3: seg = 7'b0110000; // 3
            4'd4: seg = 7'b0011001; // 4
            4'd5: seg = 7'b0010010; // 5
            4'd6: seg = 7'b0000010; // 6
            4'd7: seg = 7'b1111000; // 7
            4'd8: seg = 7'b0000000; // 8
            4'd9: seg = 7'b0010000; // 9
            default: seg = 7'b1111111; // Off
        endcase
    end
endmodule