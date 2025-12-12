module top_mod(
    input logic clk,         // Manual Clock Button
    input logic nRST,        // Manual Reset Button (Async)
    input logic load_btn,    // Load Button
    input logic start_btn,   // Start Button
    input logic [15:0] pb_in, // 16 Data Buttons
    
    // Outputs
    output logic [6:0] hex0, hex1, hex2, hex3, hex4, hex5, hex6, hex7,
    output logic done_led
);

    // Signals
    logic [15:0] input_val_toggled;
    logic clear_inputs;
    logic calc_active;
    
    // Matrix Signals
    logic [3:0] A00, A01, A10, A11;
    logic [3:0] B00, B01, B10, B11;
    logic [7:0] C00, C01, C10, C11;
    
    // Display Mux
    logic [7:0] d0, d1, d2, d3; 

    // --- 1. Toggle Bank (Handles Inputs) ---
    toggle_bank input_unit (
        .clk(clk),
        .nRST(nRST),              // <--- Connected here
        .clear(clear_inputs),
        .btn_raw(pb_in),
        .data_out(input_val_toggled)
    );

    // --- 2. FSM Controller (Handles State) ---
    fsm_pipeline ctrl (
        .clk(clk),
        .nRST(nRST),              // <--- Connected here
        .load_btn(load_btn),
        .start_btn(start_btn),
        .switches(input_val_toggled),
        .A00(A00), .A01(A01), .A10(A10), .A11(A11),
        .B00(B00), .B01(B01), .B10(B10), .B11(B11),
        .active(calc_active),
        .load_pulse_out(clear_inputs)
    );

    // --- 3. Matrix Multiplier (Math) ---
    matmul multiplier (
        .A00(A00), .A01(A01), .A10(A10), .A11(A11),
        .B00(B00), .B01(B01), .B10(B10), .B11(B11),
        .C00(C00), .C01(C01), .C10(C10), .C11(C11)
    );

    // --- 4. Display Logic ---
    always_comb begin
        if (calc_active) begin
            // Show Results
            d0 = C00; d1 = C01; d2 = C10; d3 = C11;
        end else begin
            // Show Input Preview
            d0 = {4'b0, input_val_toggled[3:0]};
            d1 = {4'b0, input_val_toggled[7:4]};
            d2 = {4'b0, input_val_toggled[11:8]};
            d3 = {4'b0, input_val_toggled[15:12]};
        end
    end

    // Helper: Map 8-bit values to 7-segment pairs
    // Note: Use the 'display_driver' module defined in previous turns
    display_driver disp0 (.val_in(d3), .seg_tens(hex7), .seg_ones(hex6));
    display_driver disp1 (.val_in(d2), .seg_tens(hex5), .seg_ones(hex4));
    display_driver disp2 (.val_in(d1), .seg_tens(hex3), .seg_ones(hex2));
    display_driver disp3 (.val_in(d0), .seg_tens(hex1), .seg_ones(hex0));

    assign done_led = calc_active;

endmodule