module top (
	input wire clk25,
	inout wire [3:0] gpio,
	input wire [3:0] key,
	output reg [3:0] led
);
	reg [31:0] ir_command;
	wire ir_ready;
	wire rst;
	//assign gpio[1] = gpio[3];	
	assign rst = key[3];
	
	always_comb begin
	
		if (key[2:0] == 3'b000) led[3:0] = ir_command[3:0];

		else if (key[2:0] == 3'b001) led[3:0] = ir_command[7:4];

		else if (key[2:0] == 3'b010) led[3:0] = ir_command[11:8];

		else if (key[2:0] == 3'b011) led[3:0] = ir_command[15:12];

		else if (key[2:0] == 3'b100) led[3:0] = ir_command[19:16];

		else if (key[2:0] == 3'b101) led[3:0] = ir_command[23:20];

		else if (key[2:0] == 3'b110) led[3:0] = ir_command[27:24];

		else led[3:0] = ir_command[31:28];
	end
	
	ir_decoder #(
		.T0(28750),
		.T1(56250),
		.START(126250)
	)
	decoder_samsung 
	(
		.clk(clk25),
		.rst(rst),
		.ack(1'd1),
		.enable('b1),
		.ir_input(gpio[3]),
		.ready(ir_ready),
		.command(ir_command),
	 	.test(gpio[0])	
	);

	


	
endmodule
