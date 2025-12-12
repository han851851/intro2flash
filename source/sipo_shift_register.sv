module sipo_shift_register (
    input logic sck, //CLOCK
    input logic ss, //nRST
    input logic mosi, //serial in
    input logic ready, //start
    input logic done,
    output logic pulse,
    output logic [3:0] parallel_out
);
    logic [2:0] bit_cnt;
    logic [3:0] shift_reg;

    always_ff @(posedge sck or negedge ss) begin
        if (!ss) begin
            bit_cnt      <= 0;
            pulse        <= 0;
            shift_reg    <= 0;
            parallel_out <= 0;
        end else if (!done && ready) begin
            // shift in one bit (MSB-first as example)
            shift_reg <= {shift_reg[2:0], mosi};
		//$display("shift register and par out: %b and %b", shift_reg, parallel_out);
            if (bit_cnt == 3) begin
                // after receiving 4th bit (bit_cnt=3), produce parallel output and pulse
                parallel_out <= {shift_reg[2:0], mosi};
                pulse        <= 1;   // one-clock pulse
                bit_cnt      <= 0;
		//$display("for real shift register and par out: %b and %b", shift_reg, parallel_out);
            end else begin
                pulse   <= 0;
                bit_cnt <= bit_cnt + 1;
            end
        end
    end

    //assign parallel_out = shift_reg;

endmodule
