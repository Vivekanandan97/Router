module fifo(input clock,reset_n,write_enb,soft_reset,read_enb,lfd_state,[7:0]data_in,output reg empty,full,reg[7:0]data_out);

reg[8:0]memory[15:0];
reg complete_d_read;
reg [5:0]count;
reg [5:0]addr_1;
reg [5:0]addr;
reg [5:0]count_v;
reg [7:2]payload_length;
reg [8:0]header_m;
reg start_write;

always @(negedge clock or negedge reset_n ) // reset logic and inputs of router sensitive to falling edge of the clock
if(!reset_n)
begin
full <= 0;
empty <=1;
start_write =0;
addr <=0;
addr_1 <=0;
data_out <=0;
complete_d_read=1;
count <=0;
end


always @(posedge soft_reset ) // soft reset 
begin
full <= 0;
empty <=1;
start_write =0;
addr <=0;
addr_1 <=0;
complete_d_read=1;
count <=0;
data_out <=0;
end

always @(posedge clock) // writing data
begin

 
if(lfd_state)start_write =1;// first time latch for writing
if(write_enb && !full) 
begin
    if(start_write)
    begin
      empty = 0;
      memory[addr] = {1'b1,data_in}; // 9th bit is 1 for header byte and Zero for other
      if(memory[addr] >= 9'b10000000)    // greater than 256 (for checking Header)
        begin
         complete_d_read = 0;
         header_m[8:0] = memory[addr];  // moving header value 
         payload_length = header_m[7:2]; 
         count <= payload_length +1'b1; // to add PARITY in data length
        end
      addr = addr+1;
       if(addr == 16)full =1;
       else  full = 0;
     end 

end    
end

always@(posedge clock)// reading data
begin
 
if(!empty && read_enb && !complete_d_read ) 
 begin
   data_out = memory[addr_1];
   addr_1 = addr_1+ 1'b1;
   count = count - 1'b1;
   if(count == 1)complete_d_read=1;
 end 

end

always@(posedge clock)
begin
//if(!count && complete_d_read) data_out = 1'bz; // high impedance when all data is read
end


endmodule
