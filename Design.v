module FIFO(clk, rst, buf_in, buf_out, wr_en, rd_en, buf_empty, buf_full, fifo_counter);
  input rst, clk, wr_en, rd_en;
  input  [7:0] buf_in;
  output reg [7:0] buf_out;
  output buf_empty, buf_full;
  output reg [7:0] fifo_counter;
  reg[1:0] rd_ptr, wr_ptr;
  reg [7:0] buf_mem [3:0];
 
  //whenever counter udates firstly we will check and update the status flags
  assign buf_empty =(fifo_counter==0);
  assign buf_full =(fifo_counter==4);
  
  always@(posedge clk or negedge rst)	//manages fifo counter
    begin
      if(!rst)
        fifo_counter<=0;
      else if((!buf_full && wr_en) && (!buf_empty && rd_en))	//reading and writing at the same time 
        fifo_counter <= fifo_counter;
      else if(!buf_full && wr_en)	//writin
        fifo_counter <= fifo_counter+1;
      else if(!buf_empty && rd_en)	//reading
        fifo_counter <= fifo_counter-1;
      else if(rd_en && wr_en)
        fifo_counter<=fifo_counter; 
      else
        fifo_counter <= fifo_counter;	// not reading or writing
    end
  
  always@(posedge clk or negedge rst)	//fetch data from fifo
    begin
      if(!rst)
        buf_out<=0;
      else
        begin
          if(rd_en && !buf_empty)
            buf_out<=buf_mem[rd_ptr];
          //buf_out<= buf_out;
        end
    end
  
  always @(posedge clk)	//writing in fifo
    begin
      if(wr_en && !buf_full)
        buf_mem[wr_ptr]<= buf_in;
      else
        buf_mem[wr_ptr]<=buf_mem[wr_ptr];
    end
  
  always @(posedge clk or negedge rst)
    begin
      if(!rst)
      	begin
          wr_ptr<=0;
          rd_ptr<=0;
        end
      else
        begin
          if(!buf_full && wr_en)
            wr_ptr<=wr_ptr+1;
          else
            wr_ptr<= wr_ptr;
          
          if(!buf_empty && rd_en)
            rd_ptr<=rd_ptr+1;
          else
            rd_ptr<= rd_ptr;
        end
    end
endmodule
          
    
