module fsm(input clock,reset_n,pkt_valid,parity_done,soft_reset_0,soft_reset_1,soft_reset_2,fifo_full,low_pkt_valid,fifo_empty_0,fifo_empty_1,
fifo_empty_2,[1:0]data_in,output reg busy,detect_add,ld_state,laf_state,full_state,lfd_state ,write_enb_reg,rst_int_reg);

reg [2:0]p_s;
reg [2:0] n_s;
reg [1:0]addr;
parameter decode_address = 3'b000;
parameter load_first_data = 3'b001;
parameter load_data = 3'b010;
parameter wait_till_empty= 3'b011;
parameter fifo_full_state = 3'b100;
parameter load_parity = 3'b101;
parameter load_after_full = 3'b110;
parameter check_parity_error = 3'b111;

always@(negedge clock or negedge reset_n)
begin
if(!reset_n ||soft_reset_0 || soft_reset_1 || soft_reset_2) p_s <= decode_address;
else p_s <= n_s;
end

always@(posedge clock )
begin
if(pkt_valid) addr<=data_in;

end

always@(negedge clock)
begin
busy =0;
detect_add =0;
ld_state =0;
laf_state =0;
lfd_state =0;
write_enb_reg =0;
rst_int_reg =0;
full_state =0;


case(p_s)
decode_address : begin
                 detect_add <=1;
                 if((pkt_valid && (data_in[1:0] ==2'b00) && fifo_empty_0) |(pkt_valid & (data_in[1:0] ==2'b01) && fifo_empty_1) | (pkt_valid && (data_in[1:0] ==2'b10) && fifo_empty_2))
                 n_s <= load_first_data;
                 else if((pkt_valid && (data_in[1:0] == 2'b00) && !fifo_empty_0) |(pkt_valid && (data_in[1:0] ==2'b01) && !fifo_empty_1) | (pkt_valid && (data_in[1:0] ==2'b10) && !fifo_empty_2)) 
                 n_s <= wait_till_empty;                
                 else 
                 n_s <= decode_address;
                 end

load_first_data : begin 
                  busy <=1;
                  lfd_state <=1;
                  n_s <= load_data;
                  end               

load_data       : begin 
                  busy <=0;
                  ld_state <=1;
                  write_enb_reg <=1;
                  if(fifo_full)n_s <= fifo_full_state;
                  else if(!fifo_full && !pkt_valid)n_s <= load_parity;
                  else  n_s <= load_data;
                  end 

fifo_full_state : begin 
                  busy <=1;
                  full_state <=1;
                  write_enb_reg <=0;
                  if(!fifo_full)n_s <= load_after_full;
                  else n_s <= fifo_full_state;
                  end 
                  
load_after_full : begin 
                  busy <=1;
                  laf_state <=1;
                  write_enb_reg <=1;
                  if(!parity_done && !low_pkt_valid)n_s <= load_data;
                  else if(!parity_done && low_pkt_valid) n_s <= load_parity;
                  else if(parity_done ) n_s <=decode_address;
                  else n_s <= load_after_full;
                  end                   
  
load_parity      :begin 
                  busy <=1;
                  write_enb_reg <=1;
                  n_s <= check_parity_error;
                  end                  

wait_till_empty  :begin 
                  busy <=1;
                  write_enb_reg <=0;
                  if((fifo_empty_0 && (addr == 0))||(fifo_empty_1 && (addr == 1))||(fifo_empty_2 && (addr == 2))) n_s <= load_first_data;
                  else n_s <= wait_till_empty;
                  end 
 
check_parity_error  :begin 
                      busy <=1;
                      rst_int_reg =1;
                      if(!fifo_full) n_s <= decode_address;
                      else if(fifo_full) n_s <= fifo_full_state;
                      else n_s <=check_parity_error;
                     end 
                  
                  
endcase
end
endmodule
