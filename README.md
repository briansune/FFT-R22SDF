# FFT-R22SDF
R22SDF FFT VLSI/FPGA investigate and implementation

# Architecture


|R2<sup>2</sup>SDF - BF2-Type I|R2<sup>2</sup>SDF - BF2-Type II|
|:---:|:---:|
|<img src="img/fft_r22sdf_bf2i.png" width="350">|<img src="img/fft_r22sdf_bf2ii.png" width="400">|
|R2<sup>2</sup>SDF - Module | |
|<img src="img/fft_r22sdf_mod.png" width="400">| |
	
# These synthesis # are based on ZYNQ XC7Z020-1CLG400 FPGA

## These frabic utilization # can also applied onto Artix 7 series FPGA


<img src="https://user-images.githubusercontent.com/29487339/148173895-7f757f23-7ef8-4da7-a7cc-2ad7abfb0c3c.png" width="800"><img src="https://user-images.githubusercontent.com/29487339/148174033-eb10f1de-8993-44ae-92ba-ca2c9641523d.png" width="800">

# Xilinx FPGA Artix / Zynq PL Frabic Synthesis Data
										
	Wo-FF			16		Wo-FF			64	
	LUT	1262	53200	2.37		LUT	2370	53200	4.45	
	LUTRAM	66	17400	0.38		LUTRAM	132	17400	0.76	
	FF	1048	106400	0.98		FF	2008	106400	1.89	
	DSP	4	220	1.82		DSP	8	220	3.64	
										
	W-FF			16		W-FF			64	
	LUT	1266	53200	2.38		LUT	2378	53200	4.47	
	LUTRAM	66	17400	0.38		LUTRAM	132	17400	0.76	
	FF	1155	106400	1.09		FF	2158	106400	2.03	
	DSP	4	220	1.82		DSP	8	220	3.64	
										
	Wo-FF			256		Wo-FF			1024	
	LUT	3611	53200	6.79		LUT	5459	53200	10.26	
	LUTRAM	326	17400	1.87		LUTRAM	1112	17400	6.39	
	FF	3051	106400	2.87		FF	4138	106400	3.89	
	DSP	12	220	5.45		DSP	16	220	7.27	
										
	W-FF			256		W-FF			1024	
	LUT	3626	53200	6.82		LUT	5479	53200	10.30	
	LUTRAM	326	17400	1.87		LUTRAM	1112	17400	6.39	
	FF	3245	106400	3.05		FF	4381	106400	4.12	
	DSP	12	220	5.45		DSP	16	220	7.27	
										
	Wo-FF			4096		Wo-FF+BRAM Delay	4096	
	LUT	9567	53200	17.98		LUT	6559	53200	12.33	
	LUTRAM	4170	17400	23.97		LUTRAM	1114	17400	6.40	
	FF	6893	106400	6.48		FF	5019	106400	4.72	
	DSP	20	220	9.09		DSP	20	220	9.09	
						BRAM	3	140	2.14	
										
	W-FF			4096		W-FF+BRAM Delay		4096	
	LUT	9591	53200	18.03		LUT	6584	53200	12.38	
	LUTRAM	4170	17400	23.97		LUTRAM	1114	17400	6.40	
	FF	7335	106400	6.89		FF	5311	106400	4.99	
	DSP	20	220	9.09		DSP	20	220	9.09	
						BRAM	3	140	2.14	
										
	Wo-FF			16384		Wo-FF+BRAM Delay	16384	
	LUT	22916	53200	43.08		LUT	7641	53200	14.36	
	LUTRAM	16460	17400	94.60		LUTRAM	1116	17400	6.41	
	FF	14014	106400	13.17		FF	5918	106400	5.56	
	DSP	24	220	10.91		DSP	24	220	10.91	
						BRAM	15	140	10.71	
										
	W-FF			16384		W-FF+BRAM Delay		16384	
	LUT	22951	53200	43.14		LUT	7661	53200	14.40	
	LUTRAM	16460	17400	94.60		LUTRAM	1116	17400	6.41	
	FF	14577	106400	13.70		FF	6261	106400	5.88	
	DSP	24	220	10.91		DSP	24	220	10.91	
						BRAM	15	140	10.71	
										
	Wo-FF			65536		Wo-FF+BRAM Delay	65536	
	Cannot Fit				LUT	8726	53200	16.40	
						LUTRAM	1118	17400	6.43	
						FF	6868	106400	6.45	
						DSP	28	220	12.73	
						BRAM	63	140	45.00	
										
	W-FF			65536		W-FF+BRAM Delay		65536	
	Cannot Fit				LUT	8751	53200	16.45	
						LUTRAM	1118	17400	6.43	
						FF	7312	106400	6.87	
						DSP	28	220	12.73	
						BRAM	63	140	45.00	



