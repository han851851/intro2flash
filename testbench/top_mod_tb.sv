module tb_top_mod();


	logic clk;
	logic nRST;
	logic serial_in;
	logic start;
	//logic ready;
	logic serial_out;
	logic done;
	logic [7:0] recv_reg;
	logic [7:0] C00_recv, C01_recv, C10_recv, C11_recv;
	integer bit_count;
	integer mat_count;
	logic [15:0] A_bits;
	logic [15:0] B_bits;
	logic res_r;

//Dump waves
	initial begin
	$dumpfile("waves.vcd");
    		$dumpvars;
end	

	top_mod DUT ( //connect top  module
		.clk(clk),
		.nRST(nRST),
		.serial_in(serial_in),
		.start(start),
		//.ready(ready),
		.serial_out(serial_out),
		.done(done),
		.recieve(res_r)
		);

	//clockers
	initial clk = 0;
	always #5 clk = ~clk; //clock

	//Task to send one 16-bit matrix serially that might have to change to being called 8 times with the 4 bit registers
	task send_matrix(input logic [15:0] matrix_bits);
		integer i;
		begin for (i = 15; i >= 0; i--) begin
			serial_in = matrix_bits[i];
			//$display("sent in %b", serial_in);
			@(posedge clk); //one full clock per bit
			end
		end
	endtask


	always_ff @(posedge clk or negedge nRST) begin //should read the serial outputs?
		//$display("sent back %b", serial_out);
		if (!nRST) begin
			recv_reg  <= 0;
			bit_count <= 0;
			mat_count <= 0;
			C00_recv <= 0;
			C01_recv <= 0;
			C10_recv <= 0;
			C11_recv <= 0;
		end else if (res_r && !done) begin
			//$display("mat index %d", mat_count);
			if (bit_count == 7) begin
				case (mat_count)
					0: C00_recv <= {recv_reg[6:0], serial_out};
					1: C01_recv <= {recv_reg[6:0], serial_out};
					2: C10_recv <= {recv_reg[6:0], serial_out};
					3: C11_recv <= {recv_reg[6:0], serial_out};
				endcase
				if (mat_count < 3) mat_count <= mat_count + 1;
				bit_count <= 0;
			end else begin
				recv_reg <= {recv_reg[6:0], serial_out};
				bit_count <= bit_count + 1;
			end
		end
	end



	initial begin
		nRST = 0;
		start = 0;
		serial_in = 0;

		@(posedge clk) nRST = 1; //release reset
		

		A_bits = {4'd1, 4'd2, 4'd3, 4'd4}; //A00,A01,A10,A11 0001, 0010, 0011, 0100 = {16'b0001001000110100};
		B_bits = {4'd5, 4'd6, 4'd7, 4'd8}; //B00,B01,B10,B11 0101, 0110, 0111, 1000
		
		//Kick off FSM
		start = 1;
		//wait(ready);
		//start = 0;

		$display("SENDING BEGINNING");
		//@(posedge clk); //wait for one clock cycle or else timing is wrong somehow
		send_matrix(A_bits);
		send_matrix(B_bits);

		wait (done); //waits for fsm to be done because then the registered signals are correct
		@(posedge clk) nRST = 0;
		//Display results
		$display("Received Results:");
		$display("C00 = %0d", C00_recv);
		$display("C01 = %0d", C01_recv);
		$display("C10 = %0d", C10_recv);
		$display("C11 = %0d", C11_recv);
		//$stop;
		
		$finish;
	end
endmodule
