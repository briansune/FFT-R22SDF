// ==================================================================
// 	Engineer:				Brian Sune
//	File:					bf2i.v
//	Date (YYYY,MM,DD):		2022/1/1
//	Aim:					Butterfly Type-I
// ==================================================================


`timescale 1 ns/ 1 ps

module bf2i#(
	parameter data_resolution = 16,
	parameter delay_num = 2,
	parameter ff_in_en = 0,
	parameter ff_out_en = 0
)(
	
	input								sys_clk,
	input								sys_nrst,
	input								sys_en,
	
	input								sel,
	
	input	[data_resolution-1 : 0]		din_r,
	input	[data_resolution-1 : 0]		din_i,
	
	output	[data_resolution-1 : 0]		dout_r,
	output	[data_resolution-1 : 0]		dout_i
);
	
	reg		[data_resolution-1 : 0]		buff_r_d0;
	reg		[data_resolution-1 : 0]		buff_r_d1;
	
	reg		[data_resolution-1 : 0]		buff_i_d0;
	reg		[data_resolution-1 : 0]		buff_i_d1;
	
	wire	[data_resolution-1 : 0]		din_r_w;
	wire	[data_resolution-1 : 0]		din_i_w;
	
	reg		[data_resolution-1 : 0]		delay_r		[delay_num-1 : 0];
	reg		[data_resolution-1 : 0]		delay_i		[delay_num-1 : 0];
	
	wire								sel_w;
	
	always@(*)begin
		case(sel_w)
			1'b0: begin
				buff_r_d0 = $signed(delay_r[delay_num-1]);
				buff_i_d0 = $signed(delay_i[delay_num-1]);
				
				buff_r_d1 = $signed(din_r_w);
				buff_i_d1 = $signed(din_i_w);
			end
			1'b1: begin
				buff_r_d1 = $signed(delay_r[delay_num-1]) - $signed(din_r_w);
				buff_i_d1 = $signed(delay_i[delay_num-1]) - $signed(din_i_w);
				
				buff_r_d0 = $signed(delay_r[delay_num-1]) + $signed(din_r_w);
				buff_i_d0 = $signed(delay_i[delay_num-1]) + $signed(din_i_w);
			end
		endcase
	end
	
	genvar i;
	
	generate
		for(i=0;i<delay_num;i=i+1)begin
			always@(posedge sys_clk or negedge sys_nrst)begin
				if(!sys_nrst)begin
					delay_r[i] <= 'd0;
					delay_i[i] <= 'd0;
				end else begin
					if(sys_en)begin
						if(i==0)begin
							delay_r[i] <= buff_r_d1;
							delay_i[i] <= buff_i_d1;
						end else begin
							delay_r[i] <= delay_r[i-1];
							delay_i[i] <= delay_i[i-1];
						end
					end
				end
			end
		end
	endgenerate
	
	generate
		if(ff_in_en)begin : FF_IN_EN
			
			reg		[data_resolution-1 : 0]		din_r_r;
			reg		[data_resolution-1 : 0]		din_i_r;
			
			reg									sel_r;
			
			always@(posedge sys_clk or negedge sys_nrst)begin
				if(!sys_nrst)begin
					din_r_r <= 'd0;
					din_i_r <= 'd0;
					sel_r <= 1'b0;
				end else begin
					if(sys_en)begin
						din_r_r <= din_r;
						din_i_r <= din_i;
						sel_r <= sel;
					end
				end
			end
			
			assign din_r_w = din_r_r;
			assign din_i_w = din_i_r;
			assign sel_w = sel_r;
			
		end else begin
			assign din_r_w = din_r;
			assign din_i_w = din_i;
			assign sel_w = sel;
		end
	endgenerate
	
	generate
		if(ff_out_en)begin : FF_OUT_EN
			
			reg	[data_resolution-1 : 0]		buff_r_d0_r;
			reg	[data_resolution-1 : 0]		buff_i_d0_r;
			
			always@(posedge sys_clk or negedge sys_nrst)begin
				if(!sys_nrst)begin
					buff_r_d0_r <= 'd0;
					buff_i_d0_r <= 'd0;
				end else begin
					if(sys_en)begin
						buff_r_d0_r <= buff_r_d0;
						buff_i_d0_r <= buff_i_d0;
					end
				end
			end
			
			assign dout_r = buff_r_d0_r;
			assign dout_i = buff_i_d0_r;
			
		end else begin
			assign dout_r = buff_r_d0;
			assign dout_i = buff_i_d0;
		end
	endgenerate
	
endmodule
