module fsm_pipeline(
	input logic clk, 
	input logic nRST, 
	input logic serial_data, 
	input logic start,
	//output logic ready,
	output logic [3:0] A00, A01, A10, A11,
	output logic [3:0] B00, B01, B10, B11,
	output logic math_time,
	output logic results
);

	//fresh variables yummer
	logic reg_r;
	logic [3:0] par_out;
	logic done;


	//calls to other modules to sync em up babay
	sipo_shift_register shift (.sck(clk), .ss(nRST), .mosi(serial_data), .ready(start), .done(done), .pulse(reg_r), .parallel_out(par_out));
	
	assign math_time = (current_state == MULTIPLY); //tells top module that its time for the matrix math babay
	//assign results = (current_state == OUTPUT);	//tells top module that the results are real shit babay

	//States declaration for the fsm
	typedef enum logic [3:0] {IDLE, PREP, READY, LOAD, SEND, CHANGE, MULTIPLY, REDUCE, ADD, OUTPUT} states;
	states current_state, next_state;
	logic [2:0] index, next_index;
	
	//state changer babay
	always_ff @(posedge clk or negedge nRST) begin
		if (!nRST) begin 
			current_state <= IDLE;
			index <= 3'd0;
			results <= 1'b0;
			done <= 0;
			//start <= 0;
		end else begin
			current_state <= next_state;
			index <= next_index;
			//$display("State = %s", current_state.name());
			//$display("index and par out = %d %b\n", index, par_out);
			if (reg_r) begin
				case (index)
					0: A00 <= par_out;
					1: A01 <= par_out;
					2: A10 <= par_out;
					3: A11 <= par_out;
					4: B00 <= par_out;
					5: B01 <= par_out;
					6: B10 <= par_out;
					7: B11 <= par_out;		
				endcase
			end 
				
		
			results <= (current_state == OUTPUT);
			//if (start) ready <= 1; //current_state == READY
			if (current_state == CHANGE) done <= 1;
		end
	end
	
	//state logic babay
	always_comb begin
		next_state = current_state;
		next_index = index;
		case (current_state) 
			IDLE : next_state = (start) ? READY : IDLE; //ready was prep but now it goes to the READY state when start goes high and when it goes to teh READY state
			READY : begin //was PREP
				next_index = 0;
				next_state = LOAD;
			end
			//READY : next_state = LOAD;
			LOAD : next_state = (reg_r) ? SEND : LOAD; //will go to SEND if the register is finished
			SEND : begin 
				next_index = (index == 7) ? index : index + 1;
				next_state = (index == 7) ? CHANGE : LOAD;
			end	
			CHANGE : begin next_state = MULTIPLY; 
				
			end
			//we love combinational logic keeps these 3 simple
			MULTIPLY : next_state = REDUCE; 
			REDUCE : next_state = ADD;
			ADD : next_state = OUTPUT;

			OUTPUT : begin next_state = (!nRST) ? IDLE : OUTPUT;
				//results = 1;
			end
			default: next_state = IDLE;
		endcase
	end
endmodule
