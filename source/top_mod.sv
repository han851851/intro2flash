module top_mod(
    input logic clk,         
    input logic nRST,        
    input logic load_btn,    
    input logic start_btn,   
    input logic [15:0] pb_in, 
    
    // Outputs - CHANGED TO 8-BIT TO MATCH top.sv
    output logic [7:0] hex0, hex1, hex2, hex3, hex4, hex5, hex6, hex7,
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
    
    // Internal 7-bit segment wires (before adding Decimal Point)
    logic [6:0] h0_seg, h1_seg, h2_seg, h3_seg, h4_seg, h5_seg, h6_seg, h7_seg;

    // --- 1. Toggle Bank ---
    toggle_bank input_unit (
        .clk(clk),
        .nRST(nRST),             
        .clear(clear_inputs),
        .btn_raw(pb_in),
        .data_out(input_val_toggled)
    );

    // --- 2. FSM Controller ---
    fsm_pipeline ctrl (
        .clk(clk),
        .nRST(nRST),              
        .load_btn(load_btn),
        .start_btn(start_btn),
        .switches(input_val_toggled),
        .A00(A00), .A01(A01), .A10(A10), .A11(A11),
        .B00(B00), .B01(B01), .B10(B10), .B11(B11),
        .active(calc_active),
        .load_pulse_out(clear_inputs)
    );

    // --- 3. Matrix Multiplier ---
    matmul multiplier (
        .A00(A00), .A01(A01), .A10(A10), .A11(A11),
        .B00(B00), .B01(B01), .B10(B10), .B11(B11),
        .C00(C00), .C01(C01), .C10(C10), .C11(C11)
    );

    // --- 4. Display Logic ---
    always_comb begin
        if (calc_active) begin
            d0 = C00; d1 = C01; d2 = C10; d3 = C11;
        end else begin
            d0 = {4'b0, input_val_toggled[3:0]};
            d1 = {4'b0, input_val_toggled[7:4]};
            d2 = {4'b0, input_val_toggled[11:8]};
            d3 = {4'b0, input_val_toggled[15:12]};
        end
    end

    // Drivers: Connect 7-bit outputs to internal 7-bit wires
    display_driver disp0 (.val_in(d3), .seg_tens(h7_seg), .seg_ones(h6_seg));
    display_driver disp1 (.val_in(d2), .seg_tens(h5_seg), .seg_ones(h4_seg));
    display_driver disp2 (.val_in(d1), .seg_tens(h3_seg), .seg_ones(h2_seg));
    display_driver disp3 (.val_in(d0), .seg_tens(h1_seg), .seg_ones(h0_seg));

    // Assign 8-bit outputs (Append 1'b1 to turn OFF decimal point for common anode)
    assign hex7 = {1'b1, h7_seg};
    assign hex6 = {1'b1, h6_seg};
    assign hex5 = {1'b1, h5_seg};
    assign hex4 = {1'b1, h4_seg};
    assign hex3 = {1'b1, h3_seg};
    assign hex2 = {1'b1, h2_seg};
    assign hex1 = {1'b1, h1_seg};
    assign hex0 = {1'b1, h0_seg};

    assign done_led = calc_active;

endmodule