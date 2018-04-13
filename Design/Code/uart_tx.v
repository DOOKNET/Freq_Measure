module	uart_tx(
	input		clk_100M,
	input		[31:0]	cnt_clk,
	input		[31:0]	cnt_square,
	input		[31:0]	cnt_pulse,
	input		[31:0]	cnt_time,
	output		uart_tx_1
);

parameter	BPS = 12'd868;		//波特率为921600 (100M/115200 = 868)
parameter	BPS_2 = 12'd434;	//波特率为115200时的分频计数值的一半，用于数据采样;在数据的中间点时刻采样，数据最稳定

reg	[11:0] 	cnt = 12'd0;		//分频计数
reg 	clk_bps = 1'b0;		//波特率时钟寄存器,clk_bps的高电平为接收或者发送数据位的中间采样点

//------------------------波特率计数------------------------
always @ (posedge clk_100M)
begin
	if(cnt == BPS) 	
		cnt <= 12'd0;			//波特率计数清零
	else 														
		cnt <= cnt + 1'b1;		//波特率时钟计数启动
end

always @ (posedge clk_100M)
begin
	if(cnt == BPS_2) 	
		clk_bps <= 1'b1;		// clk_bps高电平为接收数据位的中间采样点,同时也作为发送数据的数据改变点,只持续“一个系统时钟周期”
	else 										
		clk_bps <= 1'b0;
end

//切换数据信号
reg	[3:0] 	num1 = 4'd0; 
reg	flag = 1'b0;
reg	flag_r1 = 1'b0;
reg	flag_r2 = 1'b0;
wire	flag_nege;
always @ (posedge clk_100M)
begin
	if(num1 < 4'd10)
		flag <= 1'b0;
	else
		flag <= 1'b1;
end

always @ (posedge clk_100M)
begin
	flag_r1 <= flag;
	flag_r2 <= flag_r1;
end
assign	flag_nege = ~flag_r1 & flag_r2;		//检测上升沿

//-----------------------------------------------
reg		[4:0]	num = 5'd1;
reg		[7:0]	tx_data;
always @ (posedge clk_100M)
begin
	if((|cnt_clk) == 1) begin//按位或，cnt3_r不全为零时可以发送
		if(flag_nege == 1'b1)begin 
			case(num)
				5'd1	:	begin tx_data <= cnt_clk[7:0];		num <= num + 1'b1; end
				5'd2	:	begin tx_data <= cnt_clk[15:8];		num <= num + 1'b1; end
				5'd3	:	begin tx_data <= cnt_clk[23:16];	num <= num + 1'b1; end
				5'd4	:	begin tx_data <= cnt_clk[31:24];	num <= num + 1'b1; end
				5'd5	:	begin tx_data <= cnt_square[7:0];	num <= num + 1'b1; end
				5'd6	:	begin tx_data <= cnt_square[15:8];	num <= num + 1'b1; end
				5'd7	:	begin tx_data <= cnt_square[23:16];	num <= num + 1'b1; end
				5'd8	:	begin tx_data <= cnt_square[31:24];	num <= num + 1'b1; end
				5'd9	:	begin tx_data <= cnt_pulse[7:0];	num <= num + 1'b1; end
				5'd10	:	begin tx_data <= cnt_pulse[15:8];	num <= num + 1'b1; end
				5'd11	:	begin tx_data <= cnt_pulse[23:16];	num <= num + 1'b1; end
				5'd12	:	begin tx_data <= cnt_pulse[31:24];	num <= num + 1'b1; end
				5'd13	:	begin tx_data <= cnt_time[7:0];		num <= num + 1'b1; end
				5'd14	:	begin tx_data <= cnt_time[15:8];	num <= num + 1'b1; end
				5'd15	:	begin tx_data <= cnt_time[23:16];	num <= num + 1'b1; end
				5'd16	:	begin tx_data <= cnt_time[31:24];	num <= num + 1'b1; end


				5'd17	:	begin tx_data <= 8'h0A;			num <= num + 1'b1; end
				
				5'd18	:	begin tx_data <= 8'h0D;			num <= 5'd1;	 end
				default :begin	num <= 5'd1;		 	end     
			endcase	
		end
	end
	
end

//-------------------------------------------------------------------------------------------
reg 	uart_tx_r = 1'b1;//初始状态为高电平
always @ (posedge clk_100M)
begin
	if(clk_bps == 1'b1) begin
		case (num1)
			4'd0: 	begin uart_tx_r <= 1'b0;		num1 <= num1 + 1'b1;end //发送起始位
			4'd1: 	begin uart_tx_r <= tx_data[0];	num1 <= num1 + 1'b1;end //发送bit0
			4'd2: 	begin uart_tx_r <= tx_data[1];	num1 <= num1 + 1'b1;end //发送bit1
			4'd3: 	begin uart_tx_r <= tx_data[2];	num1 <= num1 + 1'b1;end //发送bit2
			4'd4: 	begin uart_tx_r <= tx_data[3];	num1 <= num1 + 1'b1;end //发送bit3
			4'd5: 	begin uart_tx_r <= tx_data[4];	num1 <= num1 + 1'b1;end //发送bit4
			4'd6: 	begin uart_tx_r <= tx_data[5];	num1 <= num1 + 1'b1;end //发送bit5
			4'd7: 	begin uart_tx_r <= tx_data[6];	num1 <= num1 + 1'b1;end //发送bit6
			4'd8: 	begin uart_tx_r <= tx_data[7];	num1 <= num1 + 1'b1;end //发送bit7
			4'd9: 	begin uart_tx_r <= 1'b0;		num1 <= num1 + 1'b1;end //发送检验位
			4'd10: 	begin uart_tx_r <= 1'b1;		num1 <= 4'd0;		end //发送结束位
			default:begin uart_tx_r <= 1'b1;		num1 <= 4'd0;		end
		endcase
		end
end

assign	uart_tx_1 = uart_tx_r;


endmodule
