module TOP(
	input	clk,
	input	rst_n,
	input	square,
	input	squ_r0,
	input	squ_r1,
	output	tx
);

wire 	clk_100;
wire	[31:0]	cnt_clk;
wire	[31:0]	cnt_squ;
wire	[31:0]	cnt_pulse;
wire	[31:0]	cnt_time;

//-----------------------//
PLL_100M	PLL_100M_inst0 (
	.inclk0 ( clk ),
	.c0 	( clk_100 )
);
//-----------------------//
Freq_measure	Freq_measure_inst1(
	.clk_100M	(clk_100),
	.square		(square),
	.cnt_clk	(cnt_clk),	
	.cnt_squ	(cnt_squ),	
	.cnt_pulse	(cnt_pulse)
);
//----------------------------//
Time_measure	Time_measure_inst2(
	.clk		(clk_100),
	.rst_n		(rst_n),
	.squ_r0		(squ_r0),
	.squ_r1		(squ_r1),
	.cnt_time	(cnt_time)
);
//----------------------------//
uart_tx			uart_tx_inst3(
	.clk_100M	(clk_100),
	.cnt_clk	(cnt_clk),
	.cnt_square	(cnt_squ),
	.cnt_pulse	(cnt_pulse),
	.cnt_time	(cnt_time),
	.uart_tx_1	(tx)
);
endmodule

