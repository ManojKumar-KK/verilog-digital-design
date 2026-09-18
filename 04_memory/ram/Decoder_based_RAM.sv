module decoder( input [1:0] d_in ,output reg [3:0] d_out);
  always@(*)begin
    d_out=4'b0;
    case(d_in)
      2'b00: d_out[0]=1;
      2'b01: d_out[1]=1;
      2'b10: d_out[2]=1;
      2'b11: d_out[3]=1;
    endcase
  end
endmodule

module ram_8x8(
  input cs,
  input clk,
  input rst,
  input wr_en,
  input rd_en,
  input [2:0] addr,
  input [7:0] data_in,
  output reg [7:0] data_out);
  
  reg [7:0] RAM [7:0];
  
  always@(posedge clk)begin
    if(rst)
      data_out<=0;
    else if(wr_en && cs)
      RAM[addr]<=data_in;
    else if(rd_en && cs)
      data_out<=RAM[addr];
    else 
      data_out<=0;
  end
endmodule
     

module Decoder_Ram(
  input [1:0] select,
  input clk,
  input [2:0] addr,
  input wr_en,
  input rd_en,
  input  rst,
  input [7:0] data_in,
  output reg [7:0] data_out);
  
  wire [3:0] cs;
  wire [7:0] data_out0;
  wire [7:0] data_out1;
  wire [7:0] data_out2;
  wire [7:0] data_out3;
  
  decoder d1(.d_in(select),.d_out(cs));
  
  ram_8x8 r1(.cs(cs[0]),.clk(clk),.rst(rst),.wr_en(wr_en),.rd_en(rd_en),.addr(addr),.data_in(data_in),.data_out(data_out0));
  ram_8x8 r2(.cs(cs[1]),.clk(clk),.rst(rst),.wr_en(wr_en),.rd_en(rd_en),.addr(addr),.data_in(data_in),.data_out(data_out1));
  ram_8x8 r3(.cs(cs[2]),.clk(clk),.rst(rst),.wr_en(wr_en),.rd_en(rd_en),.addr(addr),.data_in(data_in),.data_out(data_out2));
                                   ram_8x8 r4(.cs(cs[3]),.clk(clk),.rst(rst),.wr_en(wr_en),.rd_en(rd_en),.addr(addr),.data_in(data_in),.data_out(data_out3));
  
  always@(*) begin
    case(select)
      2'b00: data_out=data_out0;
      2'b01: data_out=data_out1;
      2'b10: data_out=data_out2;
      2'b11: data_out=data_out3;
    endcase
  end
endmodule
                                              
  
      
