module four_bit_parallel_d_ff(input dp_clk,dp_rst,[3:0] in,output reg [3:0] dp_out);
  
  always@(posedge dp_clk or posedge dp_rst)begin
    if(dp_rst)
      dp_out<=0;
    else begin
      dp_out[0] <= in[0];
      dp_out[1] <= in[1];
      dp_out[2] <= in[2];
      dp_out[3] <= in[3];
    end
   end
endmodule
                  
                  

module asyn_fifo
  #(parameter fifo_depth=8,
    parameter fifo_width=32)
  (input write_clk,
   input write_rst,
   input write_en,
   input [fifo_width-1:0] data_in,
   input read_clk,
   input read_rst,
   input read_en,
   output reg [fifo_width-1:0]data_out);
  wire full,empty;
  
  localparam fifo_depth_log=$clog2(fifo_depth);
  
  reg[fifo_depth_log:0] write_ptr_wclk;
  reg[fifo_depth_log:0] write_ptr_rclk;
  reg[fifo_depth_log:0] read_ptr_rclk;
  reg[fifo_depth_log:0] read_ptr_wclk;
  
  wire[fifo_depth_log:0] f_gray_rd;
  wire[fifo_depth_log:0] f1_gray_rd;
  wire[fifo_depth_log:0] f2_gray_rd;
  
  wire[fifo_depth_log:0] f_gray_wtr;
  wire[fifo_depth_log:0] f1_gray_wtr;
  wire[fifo_depth_log:0] f2_gray_wtr;
  
  wire[fifo_depth_log:0] stored_gray_read;
  wire[fifo_depth_log:0] stored_gray_wtr;
  
  reg [fifo_width-1:0] fifo [fifo_depth-1:0];
  
  function [fifo_depth_log:0] gray_code( input [fifo_depth_log:0] bin);
      begin
        gray_code[0]=bin[0] ^ bin[1];
        gray_code[1]=bin[1] ^ bin[2];
        gray_code[2]=bin[2] ^ bin[3];
        gray_code[3]=bin[3];
      end
  endfunction
  
  function [fifo_depth_log:0] binary(input [fifo_depth_log:0] gray);
    begin
      binary[3]=gray[3];
      binary[2]=gray[2]^ binary[3];
      binary[1]=gray[1]^ binary[2];
      binary[0]=gray[0]^ binary[1];
    end
  endfunction
  
  //to read_block

assign   stored_gray_wtr = gray_code(write_ptr_wclk);
  four_bit_parallel_d_ff     dprf1(.dp_clk(write_clk),.dp_rst(write_rst),.in(stored_gray_wtr),.dp_out(f_gray_wtr));
   four_bit_parallel_d_ff dprf2(.dp_clk(read_clk),.dp_rst(read_rst),.in(f_gray_wtr),.dp_out(f1_gray_wtr));
   four_bit_parallel_d_ff dprf3(.dp_clk(read_clk),.dp_rst(read_rst),.in(f1_gray_wtr),.dp_out(f2_gray_wtr));
 assign  write_ptr_rclk=binary(f2_gray_wtr);
    
                                
  //to write block
 assign stored_gray_read=gray_code(read_ptr_rclk);
    four_bit_parallel_d_ff dpwf1(.dp_clk(read_clk),.dp_rst(read_rst),.in(stored_gray_read),.dp_out(f_gray_rd));
    four_bit_parallel_d_ff dpwf2(.dp_clk(write_clk),.dp_rst(write_rst),.in(f_gray_rd),.dp_out(f1_gray_rd));
    four_bit_parallel_d_ff dpwf3(.dp_clk(write_clk),.dp_rst(write_rst),.in(f1_gray_rd),.dp_out(f2_gray_rd));
assign read_ptr_wclk=binary(f2_gray_rd); 
    
  
  // write
  always@(posedge write_clk or posedge write_rst)begin
    if(write_rst)
      write_ptr_wclk<=0;
    else if(write_en && !full) begin
      fifo[write_ptr_wclk[fifo_depth_log-1:0]]<=data_in;
      write_ptr_wclk<=write_ptr_wclk+1;
    end
  end
  
  
  //read
  always@(posedge read_clk or posedge read_rst)begin
    if(read_rst)
      read_ptr_rclk<=0;
    else if(read_en && !empty) begin
      data_out<=fifo[read_ptr_rclk[fifo_depth_log-1:0]];
      read_ptr_rclk<=read_ptr_rclk+1;
    end
  end
                                                                                         
assign full=(read_ptr_wclk=={~write_ptr_wclk[fifo_depth_log],write_ptr_wclk[fifo_depth_log-1:0]});
assign empty=(read_ptr_rclk==write_ptr_rclk);
endmodule
                                                                                        
                                                                                          
                                                                                          
                                     

  
   
