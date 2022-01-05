// ==================================================================
// 	Engineer:				Brian Sune
//	File:					twiddle_mod.v
//	Date (YYYY,MM,DD):		2022/1/1
//	Aim:					Complex Multiplication
// ==================================================================


`timescale 1 ns/ 1 ps

module twiddle_mod#(
	parameter division = 16,
	parameter fft_length = 16,
	parameter ff_in_en = 0
)(
	input							sys_clk,
	input							sys_nrst,
	input							sys_en,
	
	output	[16 : 0]				tw_fac_r,
	output	[16 : 0]				tw_fac_i,
	output							cordic_rdy
);
	
	`include "logfunc.vh"
	
	localparam phase_bw = 16;
	localparam cordic_bw = clog2(division);
	localparam tick_bw = clog2(fft_length);
	
	localparam pwr_cmp = clog4(fft_length) - clog4(division);
	localparam offset = (pwr_cmp > 0) ? 1 : 0;
	localparam cordic_rdy_cnt = 17 + (fft_length / 4) - ff_in_en * (2 * (pwr_cmp + 1));
	localparam cordic_init_cnt = (division / 4) * offset - ff_in_en * (2 * (pwr_cmp + 1));
	
	reg							cordic_rdy_r;
	reg		[tick_bw : 0]		cordic_init;
	reg		[cordic_bw-1 : 0]	phase_cnt;
	
	always@(posedge sys_clk or negedge sys_nrst)begin
		if(!sys_nrst)begin
			phase_cnt <= 'd0;
		end else begin
			if(sys_en)begin
				if(cordic_init[0+:(cordic_bw-2)] == {(cordic_bw-2){1'b1}})begin
					phase_cnt <= 'd0;
				end else begin
					phase_cnt <= phase_cnt - 
						{{(cordic_bw-2){1'b0}}, cordic_init[cordic_bw-2], cordic_init[cordic_bw-1]};
				end
			end
		end
	end
	
	cordic#(
		.pipeline		(16)
	)cordic_s0(
		.sys_clk		(sys_clk),
		.sys_nrst		(sys_nrst),
		.sys_en			(sys_en),
		.phase_in		({phase_cnt, {(phase_bw-cordic_bw){1'b0}}}),
		.cos			(tw_fac_r),
		.sin			(tw_fac_i),
		.eps			()
	);
	
	always@(posedge sys_clk or negedge sys_nrst)begin
		if(!sys_nrst)begin
			cordic_init <= cordic_init_cnt;
			cordic_rdy_r <= 1'b0;
		end else begin
			if(sys_en)begin
				cordic_init <= cordic_init + 'd1;
				if(cordic_init == cordic_rdy_cnt)begin
					cordic_rdy_r <= 1'b1;
				end
			end
		end
	end
	
	assign cordic_rdy = cordic_rdy_r;
	
endmodule
