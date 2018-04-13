module Time_measure(
	input	clk,
	input	rst_n,
	input	squ_r0,
	input	squ_r1,
	output	reg	[31:0]	cnt_time
);

//---------检测上升沿-------------//
reg 	squ_reg0;
reg 	squ_reg1;
reg 	squ_reg2;
reg 	squ_reg3;
wire	squ_pose0;
wire	squ_pose1;
always @(posedge clk or negedge rst_n) begin
	if(!rst_n)	begin
		squ_reg0 <= 0;
		squ_reg1 <= 0;
		squ_reg2 <= 0;
		squ_reg3 <= 0;
	end
	else	begin
		squ_reg0 <= squ_r0;
		squ_reg1 <= squ_reg0;
		squ_reg2 <= squ_r1;
		squ_reg3 <= squ_reg2;
	end
end
assign	squ_pose0 = squ_reg0 & ~squ_reg1;
assign	squ_pose1 = squ_reg2 & ~squ_reg3;

//-----------计数-----------//
reg		[1:0]	i;
reg		[31:0]	cnt;
reg		[31:0]	cnt_r0;
always @(posedge clk or negedge rst_n) begin
	if(!rst_n)	begin
		i <= 2'd01;
		cnt <= 0;
		cnt_r0 <= 0;
	end
	else	begin
		case (i)
		2'b01:
			if(squ_pose0)	begin
				i <= 2'b10;
			end
			else	i <= 2'b01;
		2'b10:
			if(squ_pose1)	begin
				cnt_r0 <= cnt;
				cnt <= 0;
				i <= 2'b01;
			end
			else	cnt <= cnt + 1;
		default: i <= 2'b01;
		endcase
	end
end

reg		[31:0]	cnt_reg;
always @(posedge clk or negedge rst_n) begin
	if(!rst_n)	begin
		cnt_time <= 0;
		cnt_reg <= 0;
	end
	else if(cnt_reg == 32'd99_999_999)	begin	//100M*0.5=50_000_000
		cnt_time <= cnt_r0;
		cnt_reg	<= 0;
	end
	else	begin
		cnt_reg <= cnt_reg + 1;
	end
end

endmodule
