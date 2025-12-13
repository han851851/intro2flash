module top_mod(
	input logic clk,
	input logic nRST,
	input logic serial_in,
	input logic start,
	//output logic ready,
	output logic serial_out,
	output logic done,
	output logic recieve
); //these should be like wires or pins that connect to the microcontroller i am like 85% sure

	logic math_r;
	logic done_r;
	logic results_r;
	logic sending;
	logic sending_r;
	assign done = done_r;
	logic buffer;

	logic [3:0] A00, A01, A10, A11;
	logic [3:0] B00, B01, B10, B11;
	logic [7:0] C00, C01, C10, C11;

	//connects the fsm to the top
	fsm_pipeline fsm (.clk(clk), .nRST(nRST), .serial_data(serial_in), .start(start), //.ready(ready), 
		.A00(A00), .A01(A01), .A10(A10), .A11(A11), .B00(B00), .B01(B01), .B10(B10), .B11(B11), 
		.math_time(math_r), .results(results_r)); //I don't think math_time actually is necessary but I'm keeping it anyways
	//connects the math to the top
	matmul multiplier (.A00(A00), .A01(A01), .A10(A10), .A11(A11), .B00(B00), .B01(B01), .B10(B10), .B11(B11),
		.C00(C00), .C01(C01), .C10(C10), .C11(C11)); 

	//we probably need to make a new serial out module to relay the output back to the microcontroller because we won't have enough pins depending on the method.

    // Serializer control
	logic [7:0] shift_reg;    // current element to send
	logic [2:0] bit_idx;      // bit position (0–7)
	logic [1:0] mat_idx;      // which Cxx (0–3)

	//initial $display("Value of Start: %d, %d, %d, %d", C00, C01, C10, C11);	
	
	always_ff @(posedge clk or negedge nRST) begin
		//$display("\nserial_in, %b", serial_in);
		//$display("Value of A: [%d, %d, %d, %d]", A00, A01, A10, A11);
		//$display("Value of B: [%d, %d, %d, %d]", B00, B01, B10, B11);
        	if (!nRST) begin
			serial_out <= 0;
		    	shift_reg <= 0;
		    	bit_idx <= 0;
		    	mat_idx <= 0;
		    	sending <= 0;
			done_r <= 0;
			buffer <= 0;
			//$display("Value of nRST: %d, %d, %d, %d", C00, C01, C10, C11);
		end else begin
			sending_r <= sending;
			//$display("results_r and sending: %d, %d", results_r, sending);
			if (results_r && !sending) begin
			    	//start new transmission
				mat_idx <= 0;
				bit_idx <= 0;
				sending <= 1;
				done_r <= 0;
				buffer <= 0;
				//$display("Value of Begin: %d, %d, %d, %d", C00, C01, C10, C11);
				//load first element (C00)
				shift_reg <= C00;
			end else if (sending) begin
				//output MSB first
				//$display("Value of Final: %d, %d, %d, %d", C00, C01, C10, C11);
				serial_out <= shift_reg[7];
				if (bit_idx == 3'd7) begin
					bit_idx <= 0;
					mat_idx <= mat_idx + 1;
					case (mat_idx)
						0: shift_reg <= C01;
						1: shift_reg <= C10;
						2: shift_reg <= C11;
						default: begin
					    		sending <= 0; //all 4 sent
							buffer <= 1; //done_r <= 1;
			        		end
			    		endcase
				end else begin
					shift_reg <= {shift_reg[6:0], 1'b0};
					bit_idx <= bit_idx + 1;
				end
		    	end
			if (buffer) begin done_r <= 1;
				buffer <= 0;
			end
		end
	end

	assign recieve = sending_r;

endmodule
