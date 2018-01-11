module DAC_5618_Top (
                    clk,
                    rst_n,
                    key,
                    DAC_CS_N,
                    DAC_SCLK,
                    DAC_DIN
                     );
                     
input clk;
input rst_n;
input key;

output DAC_CS_N;
output DAC_SCLK;
output DAC_DIN;

wire [15:0] DAC_DATA;
wire start;
wire key_flag,key_state;

assign start = key_flag && !key_state ;
assign DAC_DATA = 16'b1100_0111_1111_1111;
key_filter key_filter(
                      .clk(clk),
                      .rst_n(rst_n),
                      .key_in(key),
                      .key_flag(key_flag),
                      .key_state(key_state)
                      );  
                      
tlv5618 tlv5618(
		          .clk(clk),     		//模块时钟50M
		          .rst_n(rst_n),   		//模块复位
		
		          .DAC_DATA(DAC_DATA),		//DAC控制字
		          .Start(start),   		//模块使能
		          .Set_Done(), 	//一次数据更新完成标志
		
		          .DAC_CS_N(DAC_CS_N),    	//TLV5618的CS_N接口
		          .DAC_DIN(DAC_DIN),     	//TLV5618的DIN接口
		          .DAC_SCLK(DAC_SCLK),    	//TLV5618的SCLK接口
		          .DAC_State()			//工作状态标志信号
		           
					  );                                                            
endmodule                                   