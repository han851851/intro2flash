module fsm_pipeline(
    input logic clk,
    input logic nRST,              
    input logic load_btn,
    input logic start_btn,
    input logic [15:0] switches,   
    
    output logic [3:0] A00, A01, A10, A11,
    output logic [3:0] B00, B01, B10, B11,
    output logic active,
    output logic load_pulse_out
);
    typedef enum logic [1:0] {IDLE, LOAD_B, CALC} state_t;
    state_t state, next_state;

    // Internal Registers
    logic [3:0] A00_r, A01_r, A10_r, A11_r;
    logic [3:0] B00_r, B01_r, B10_r, B11_r;

    // Edge Detection
    logic load_q1, load_q2, load_pulse;
    logic start_q1, start_q2, start_pulse;

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

    // State Machine & Datapath
    always_ff @(posedge clk, negedge nRST) begin
        if (!nRST) begin
            state <= IDLE;
            {A00_r, A01_r, A10_r, A11_r} <= '0;
            {B00_r, B01_r, B10_r, B11_r} <= '0;
        end else begin
            state <= next_state;
            if (load_pulse) begin
                if (state == IDLE) begin
                    {A00_r, A01_r, A10_r, A11_r} <= switches;
                end else if (state == LOAD_B) begin
                    {B00_r, B01_r, B10_r, B11_r} <= switches;
                end
            end
        end
    end

    // Next State Logic
    always_comb begin
        next_state = state;
        case (state)
            IDLE:   if (load_pulse) next_state = LOAD_B;
            LOAD_B: if (load_pulse) next_state = CALC;
            CALC:   begin 
                // Remains in CALC until Reset
            end
            default: next_state = IDLE; // Fix: Handle undefined states
        endcase
    end

    assign A00 = A00_r; assign A01 = A01_r; assign A10 = A10_r; assign A11 = A11_r;
    assign B00 = B00_r; assign B01 = B01_r; assign B10 = B10_r; assign B11 = B11_r;
    assign active = (state == CALC) && start_btn; 

endmodule