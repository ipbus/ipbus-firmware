`timescale 1ns / 1ps

module clock_divider_s6(
    input clk,
    output d25,
    output d28
    );

	wire [6:0] q;
	reg [5:0] qr = 0;
	reg [2:0] ctr = 0;

	assign q[0] = 1'b1;
	
	generate
		genvar i;
		for(i=1; i<=5; i=i+1) begin: gen_sr

			SRLC32E #(
				.INIT(32'h80000000)
			) sr_0 (
				.Q(q[i]),
				.A(5'b11111),
				.CE(q[i-1] & ~qr[i-1]),
				.CLK(clk),
				.D(q[i])
			);

			always @(posedge clk)
			begin
				qr[i] <= q[i];
			end

		end
	endgenerate

	assign d25 = q[5];

	always @(posedge clk)
	begin
		if(q[5] & ~qr[5]) ctr <= ctr + 1;
	end
	
	assign d28 = ctr[2];
	
endmodule
