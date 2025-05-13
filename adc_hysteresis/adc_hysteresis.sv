module adc_hysteresis 
# (
	x_High = 12'd3000,		
	x_Low = 12'd1000
) (
	input  logic rst,
	input  logic clk,
	input  logic adc_ready,
	input  logic [11:0] d_signal,			// Digital signal from ADC
	output logic can_move_fwd,
	output logic adc_ack
);
	logic [11:0] not_d_signal;

	always_ff @(posedge clk or posedge rst) begin
		if (rst) begin 				// Global RESET
			can_move_fwd	<= 1'd1;
			not_d_signal	<= 1'd1;
			adc_ack		<= 1'd0;
		end else if (adc_ready) begin
			//not_d_signal <= 12'd4075-d_signal-12'd561;
			not_d_signal <= d_signal;
			
			if (not_d_signal < x_Low)
				can_move_fwd <= 1'd1;
			else if (not_d_signal > x_High)
				can_move_fwd <= 1'd0;
			
			adc_ack	<= 1'd1;
		end else
			adc_ack <= 1'd0;
	end

endmodule
