module fsm_pipeline(
    input logic clk,
    input logic nRST,              // Asynchronous Reset
    input logic load_btn,
    input logic start_btn,
    input logic [15:0] switches,   // Input from toggle_bank
    
    output logic [3:0] A00, A01, A10, A11,
    output logic [3:0] B00, B01, B10, B11,
    output logic active,
    output logic load_pulse_out    // Tells toggle_bank to clear
);

    typedef enum logic [1:0] {IDLE, LOAD_B, CALC} state_t;
    state_t state, next_state;

    // Internal Registers
    logic [3:0] A00_r, A01_r, A10_r, A11_r;
    logic [3:0] B00_r, B01_r, B10_r, B11_r;

    // Edge Detection for Load/Start buttons
    logic load_q1, load_q2, load_pulse;
    logic start_q1, start_q2, start_pulse;

    // 1. Edge Detectors with Async Reset
    always_ff @(posedge clk, negedge nRST) begin
        if(!nRST) begin
            load_q1 <= 0; load_q2 <= 0;
            start_q1 <= 0; start_q2 <= 0;
        end else begin
            load_q1 <= load_btn; load_q2 <= load_q1;
            start_q1 <= start_btn; start_q2 <= start_q1;
        end
    end
    assign load_pulse = load_q1 && !load_q2;
    assign start_pulse = start_q1 && !start_q2;
    assign load_pulse_out = load_pulse;

    // 2. State Machine & Datapath with Async Reset
    always_ff @(posedge clk, negedge nRST) begin
        if (!nRST) begin
            state <= IDLE;              // Go to IDLE instantly
            {A00_r, A01_r, A10_r, A11_r} <= '0; // Wipe Matrix A
            {B00_r, B01_r, B10_r, B11_r} <= '0; // Wipe Matrix B
        end else begin
            state <= next_state;

            // Load Operations
            if (load_pulse) begin
                if (state == IDLE) begin
                    {A00_r, A01_r, A10_r, A11_r} <= switches;
                end else if (state == LOAD_B) begin
                    {B00_r, B01_r, B10_r, B11_r} <= switches;
                end
            end
        end
    end

    // 3. Next State Logic
    always_comb begin
        next_state = state;
        case (state)
            IDLE:   if (load_pulse) next_state = LOAD_B;
            LOAD_B: if (load_pulse) next_state = CALC;
            CALC:   begin 
                // Remains in CALC until Reset is pressed
            end
        endcase
    end

    // Output assignments
    assign A00 = A00_r; assign A01 = A01_r; assign A10 = A10_r; assign A11 = A11_r;
    assign B00 = B00_r; assign B01 = B01_r; assign B10 = B10_r; assign B11 = B11_r;
    
    // Only show results if we are in CALC state AND Start button was toggled
    // (Or just based on state for simplicity)
    assign active = (state == CALC) && start_btn; 

endmodule