module tlv5618 (
               clk,
               rst_n,
               
               DAC_DATA,   // DAC 控制字
               Start,      //Enable of DAC_Module
               Set_Done,
               
               DAC_CS_N,
               DAC_DIN,
               DAC_SCLK,
               DAC_State                                                                         
                );
                
parameter fCLK = 10'd50;
parameter DIV_PARAM = 10'd2;

input clk;
input rst_n;
input [15:0] DAC_DATA;
input Start;

output Set_Done;

output reg DAC_CS_N;
output reg DAC_DIN;
output reg DAC_SCLK;
output     DAC_State;

assign DAC_State = DAC_CS_N ;
 
reg [15:0] r_DAC_DATA;
reg [3:0] DIV_CNT; //分频计算器；

reg SCLK2X; //2倍SCLK的采样时钟

reg [5:0] SCLK_GEN_CNT; //生成顺序序列计数器

reg en; //转换使能信号    

//生成2倍SCLK使能时钟计数器

always@(posedge clk or negedge rst_n)
      begin
      	   if(!rst_n)
      	     en <= 1'b0;
      	   else if(Start)
      	          en <= 1'b1;
      	   else if(Set_Done)
      	         en <= 1'b0;
      	   else
      	        en <= en ;      	              	      	
      end
      
// 生成两倍SCLK使能时钟计数器      
always@(posedge clk or negedge rst_n)      
    begin
    	   if(!rst_n)
    	    DIV_CNT <= 4'd0;
    	   else if(en)
    	         begin
    	         	    if(DIV_CNT == (DIV_PARAM - 1'b1))
    	         	       DIV_CNT <= 4'd0;
    	         	    else 
    	         	        DIV_CNT <= DIV_CNT + 1'b1; 
    	         end
    	   else 
    	       DIV_CNT <= 4'd0;
    end

//生成两倍SCLK使能时钟计数器  
always@(posedge clk or negedge rst_n)
     begin
     	    if(!rst_n)
     	      SCLK2X <= 1'b0;
     	    else if(en && (DIV_CNT = (DIV_PARAM - 1'b1)))
     	          SCLK2X <= 1'b1;
     	    else
     	        SCLK2X <= 1'b0;     	
     end
     
//生成序列计数器
always@(posedge clk or negedge rst_n)
      begin
      	   if(!rst_n)
      	    SCLK_GEN_CNT <= 6'd0;
      	   else if(SCLK2X && en)
      	          begin
      	          	   if(SCLK_GEN_CNT == 6'd32)
      	          	     SCLK_GEN_CNT <= 6'd0;    
      	          	   else
      	          	     SCLK_GEN_CNT <= SCLK_GEN_CNT + 1'b1;          	     
      	          end        	          
      	    else
      	          SCLK_GEN_CNT <= SCLK_GEN_CNT ;                                          	                	
      end
      
//  依序将数据移动到DAC芯片上

always@(posedge clk or negedge rst_n)
      begin
             if(!rst_n)
               begin
               	    DAC_DIN <= 1'b1;
               	    DAC_SCLK <= 1'b0;
               	    r_DAC_DATA <= 16'd0;
               end  
             else
                 begin
                 	    if(Start) //接收到开始命令时，寄存DAC_DATA值
                 	     r_DAC_DATA <= DAC_DATA ;
                 	    if(!Set_Done && SCLK2X)
                 	      begin
                 	      	   if(!SCLK_GEN_CNT[0]) // 偶数
                 	      	     begin
                 	      	     	    DAC_SCLK <= 1'b1;
                 	      	     	    DAC_DIN <= r_DAC_DATA[15];
                 	      	     	    r_DAC_DATA <= r_DAC_DATA << 1;
                 	      	     end
                 	      	   else //奇数
                 	      	       DAC_SCLK <= 1'b0;
                 	      end
                 end   	                                         	
      end      
      
always@(posedge clk or negedge rst_n)
      begin
      	   if(!rst_n)
      	     begin
      	     	    DAC_CS_N <= 1'b1;      	     	    
      	     end
      	   else if(en && SCLK2X)
      	         DAC_CS_N <= SCLK_GEN_CNT[5];
      	   else
      	       DAC_CS_N <= DAC_CS_N;  
      end      
      
assign Set_Done = SCLK_GEN_CNT[5] && SCLK2X ;

endmodule      
            






     




           