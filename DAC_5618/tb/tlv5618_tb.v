`timescale 1ns/1ns

module tlv5616_tb;

reg clk;
reg rst_n;
reg start;
reg [15:0] data;

wire CS_N;
wire SCLK;
wire DIN;
wire set_done;

tlv5616 tlv5616(
                 .clk(clk),
                 .rst_n(rst_n),
               
                 .DAC_DATA(data),   // DAC 控制字
                 .Start(start),      //Enable of DAC_Module
                 .Set_Done(set_done),
               
                 .DAC_CS_N(CS_N),
                 .DAC_DIN(DIN),
                 .DAC_SCLK(SCLK),
                 .DAC_State()       
                 );
                 
initial clk = 1'b1;
always#10 clk=~clk;

initial 
       begin
	          rst_n = 0;
		        start = 0;
		        data = 0;
		        #200;
		        rst_n = 1;
		        #100;
		        start = 1;
		        data = 16'haaff;
		        #20;
		        start = 0;
		
		        #10000;
		        start = 1;
		        data = 16'habcd;
		        #20;
		        start = 0;
	
		        #10000;
		        start = 1;
		        data = 16'haa78;
		        #20;
		        start = 0;
		
		        #20000;
		        $stop;		 
	     end                 
