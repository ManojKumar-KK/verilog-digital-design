module tb;
  reg [1:0] select;
  reg clk,rst;
  reg [2:0]addr;
  reg  wr_en;
  reg  rd_en;
  reg [7:0] data_in;
  wire [7:0] data_out;
  
  Decoder_Ram dut(select,clk,addr,wr_en,rd_en,rst,data_in,data_out);
  
  task write(
    input [7:0] d_in,
    input [1:0] s);
    begin
      @(posedge clk);
      wr_en=1; select=s;
      data_in=d_in;
      @(posedge clk);
      wr_en=0;
    end
  endtask
  
  task read( input [1:0] s);
    begin
      @(posedge clk);
      select=s; rd_en=1;
      @(posedge clk);
      rd_en=0;
    end
  endtask
  
  initial begin
    fork
      begin
        clk=0;
        forever #5 clk=~clk;
      end
      
      begin
        rst=1;
        data_in=0;
        wr_en=0;
        rd_en=0;
        select=0;
        
        @(posedge clk);
        #1 rst=0;
        addr=3'd0;
        write(10,1);
        write(20,2);
        write(30,3);
        write(50,0);
        
        @(posedge clk);
        read(0);
        read(1);
        read(2);
        read(3);
      end
      
      begin
        $dumpfile("dump.vcd");
        $dumpvars(0,tb);
        #400 $finish;
      end
    join
  end
endmodule
  
        
        
        
      