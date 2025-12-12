module toggle_bank (
    input logic clk,              // Manual Clock Button
    input logic nRST,             // Asynchronous Reset (Active Low)
    input logic clear,            // Sync clear from FSM (after Load)
    input logic [15:0] btn_raw,   // 16 Data Buttons
    output logic [15:0] data_out  // The stored toggle values
);

    logic [15:0] q1, q2;
    logic [15:0] btn_pulse;

    // We process all 16 buttons in parallel
    genvar i;
    generate
        for (i = 0; i < 16; i++) begin : btn_logic
            
            // 1. Edge Detector (Synchronized to Manual Clock)
            // Detects if the button is held DOWN during this specific clock tick
            // when it was UP during the previous clock tick.
            always_ff @(posedge clk, negedge nRST) begin
                if (!nRST) begin
                    q1[i] <= 1'b0;
                    q2[i] <= 1'b0;
                end else begin
                    q1[i] <= btn_raw[i];
                    q2[i] <= q1[i];
                end
            end
            
            assign btn_pulse[i] = q1[i] && !q2[i]; // Rising edge logic

            // 2. Toggle Register
            always_ff @(posedge clk, negedge nRST) begin
                if (!nRST) begin
                    data_out[i] <= 1'b0;      // ASYNC RESET: Wipe immediately
                end else if (clear) begin
                    data_out[i] <= 1'b0;      // SYNC CLEAR: Wipe on clock edge (Load)
                end else if (btn_pulse[i]) begin
                    data_out[i] <= ~data_out[i]; // Toggle on press
                end
            end
        end
    endgenerate

endmodule