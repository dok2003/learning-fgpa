module top (
	input  logic clk25,
	input  logic [3:0] key,
	inout  logic [9:0] gpio,
	output logic [3:0] led,
	input  logic adc_spi_miso,
	output logic adc_spi_mosi,
	output logic adc_spi_sclk,
	output logic adc_spi_csn
);

	logic [7:0] motor_dc;
	logic [7:0] servo_dc;
	logic direction;
	logic ack;

	// ADDED
	logic adc_ack;
	logic [2:0] address;
	logic dout_bit;
	logic sclk;
	logic cs;
	logic adc_ready;
	logic din_bit;
	// ADDED

	logic state;

	logic ir_ready;
	logic ctl_valid;
	logic [31:0] command;

	logic [11:0] d_signal;
	logic can_move_fwd;

	assign gpio[9:4] = {adc_ready, ctl_valid, sclk, cs, din_bit, dout_bit};
	
	assign led[0] = state;
	assign led[1] = can_move_fwd;
	assign led[2] = direction;
//	assign led[3] = servo_dc[7];
	assign led[3] = ctl_valid;	

	//assign led[3:0] = d_signal[11:8];

	logic rst;
	assign rst = key[3];

	assign adc_spi_sclk = sclk;
	assign adc_spi_mosi = din_bit;
	assign adc_spi_csn = cs;
	assign dout_bit = adc_spi_miso;

        control
        # (
                .clk_hz(25000000),
		.sclk_hz(256),
		.servo_step(16)
        ) control_inst (
		.state(state),
		.clk(clk25),
		.rst(rst),
		.ir_ready(ir_ready),
		.command(command),
		.can_move_fwd(can_move_fwd),
		.ctl_valid(ctl_valid),
		.ack(ack),
		.motor_dc(motor_dc),
		.direction(direction),
		.servo_dc(servo_dc)
        );
/*	always_ff @(posedge clk25  or posedge rst)begin
		if (rst)
			command <= 32'hFB040707;
		else begin
			if(key[0]) begin
			command <= 32'h9F600707;
			end
			if (key[1]) command  <= 32'hFE010707;
		end

	end
*/	
	motor_drv 
	# (
		.clk_hz(25000000),
		.pwm_hz(250)
	) motor_inst (
		.clk(clk25),
		.enable(ctl_valid),
		.rst(rst),
		.direction(direction),
		.duty_cycle(motor_dc),
		.pwm_outA(gpio[0]),
		.pwm_outB(gpio[1])
	);

	servo_pdm
	# (
		.clk_hz(25000000)
	) servo_inst (
		.rst(rst),
		.clk(clk25),
		.en(ctl_valid),
		.duty(servo_dc),
		.pdm_done(gpio[2])
	);

	ir_decoder decoder_inst (
		.clk(clk25),
		.rst(rst),
		.ack(ack),
		.enable(ctl_valid),
		.ir_input(gpio[3]),
		.ready(ir_ready),
		.command(command)
	);

	adc_hysteresis
	# (
		
		.x_High(12'd1246),
		.x_Low(12'd1059),
	) hysteresis_inst (
		.rst(rst),
		.clk(clk25),
		.adc_ready(adc_ready),
		.d_signal(d_signal),
		.can_move_fwd(can_move_fwd),
		.adc_ack(adc_ack)
	);
	
	adc_capture 
	# (
		.clk_hz(25000000),
		.sclk_hz(500000),
		.cycle_pause(30)
	) adc_capture_inst (
		.clk(clk25),
		.rst(rst),
		.en(ctl_valid),
		.adc_ack(adc_ack),
		.address(3'b000),
		.dout_bit(dout_bit),
		.sclk(sclk),
		.cs(cs),
		.adc_ready(adc_ready),
		.din_bit(din_bit),
		.d_signal(d_signal)
	);

	/*
	always_ff @(posedge sclk or posedge rst) begin
		if (rst) begin
			adc_ack <= 1'd0;
			address <= 3'b000;
		end else if (adc_ready) begin
			adc_ack <= 1'd1;
			address <= 3'b000;
		end
	end
	*/

endmodule
