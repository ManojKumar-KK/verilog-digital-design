module tb;
  parameter fifo_depth=8;
  parameter fifo_width=32;
  reg write_clk,write_rst,write_en,read_clk,read_rst,read_en;
  reg [fifo_width-1:0] data_in;
  wire [fifo_width-1:0] data_out;
  integer i;
  
  asyn_fifo #(fifo_depth,fifo_width) dut(write_clk,write_rst,write_en,data_in,read_clk,read_rst,read_en,data_out);
  
  task write_data (input [fifo_width-1:0] d_in);
    begin
      @(posedge write_clk);
      write_en=1;
      data_in=d_in;
      @(posedge write_clk);
      write_en=0;
    end
  endtask
  
  task read_data ();
    begin
      @(posedge read_clk);
      read_en=1;
      @(posedge read_clk);
      read_en=0;
    end
  endtask
  
  initial begin
    fork
      begin
        write_clk=0;
      forever #5 write_clk=~write_clk;
      end
      
      begin
        read_clk=0;
        forever #6 read_clk=~read_clk;
      end
      
      begin
        write_rst=1;
        read_rst=1;
        write_en=0;
        read_en=0;
        data_in=0;
      end
      
      begin
        @(posedge write_clk or read_clk);
        write_rst=0;read_rst=0;
        write_data(10);
        write_data(110);
        write_data(1110);
        
        read_data();
        read_data();
        read_data();
        
        for(i=0;i<=fifo_depth-1;i=i+1) begin
          write_data(2**i);
          read_data();
        end
        
        for(i=0;i<=fifo_depth-1;i=i+1) begin
          write_data(2**i);
        end
        
        for(i=0;i<fifo_depth-1;i=i+1)begin
          read_data();
        end
        
      end
      
      begin
        $dumpfile("dump.vcd");
        $dumpvars(0,tb);
        #700 $finish;
      end
    join
  end
endmodule
        
      
      
