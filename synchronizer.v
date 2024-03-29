//provide synch between FSM and FIFO modules



module synchronizer(input detect_add,write_enb_reg,clock,reset_n,read_enb_0,read_enb_1,read_enb_2,empty_0,empty_1,empty_2,full_0,full_1,full_2,[1:0]data_in,output reg valid_out_0,valid_out_1,valid_out_2, soft_reset_0,soft_reset_1,soft_reset_2,fifo_full,write_enb_0,write_enb_1,write_enb_2);
reg [4:0]count_30_1;
reg [4:0]count_30_2;
reg [4:0]count_30_3;

always@(negedge reset_n)
begin
if(!reset_n)
count_30_1 = 0;
count_30_2 = 0;
count_30_3 = 0;
soft_reset_0 = 0;
soft_reset_1 = 0;
soft_reset_2 = 0;
write_enb_0 =0;
write_enb_1 =0;
write_enb_2 =0;
end

always@(posedge clock)// mapping fifo based on data_in
begin
if((data_in == 2'b00)&&(detect_add)) fifo_full = full_0;
else if((data_in == 2'b01)&&(detect_add)) fifo_full = full_1;
else if((data_in == 2'b10)&&(detect_add)) fifo_full = full_2;
end

always@(posedge clock)// mapping write_enb based on data_in
begin
if((data_in == 2'b00)&&(write_enb_reg)) write_enb_0 = 1;
else if((data_in == 2'b01)&&(write_enb_reg)) write_enb_1 = 1;
else if((data_in == 2'b10)&&(write_enb_reg)) write_enb_2 = 1;
end

always@(posedge clock)// counting number of clock cycles for soft reset
begin
if(valid_out_0 && !read_enb_0 )count_30_1 = count_30_1 +1'b1;
else if(valid_out_1 && !read_enb_1 )count_30_2 = count_30_2 +1'b1;
else if(valid_out_2 && !read_enb_2 )count_30_3 = count_30_3 +1'b1;
end

always@(posedge clock)// soft reset
begin
if(count_30_1 == 5'd30 )soft_reset_0 = 1;
else if(count_30_2 == 5'd30 )soft_reset_1 = 1;
else if(count_30_3 == 5'd30 )soft_reset_2 = 1;
end
always@(negedge clock)
begin
if(!empty_0) valid_out_0 = 1;
else valid_out_0 = 0;
if(!empty_1) valid_out_1 = 1;
else valid_out_1 = 0;
if(!empty_2) valid_out_2 = 1;
else valid_out_2 = 0;
end
endmodule  
