module register(input clock,reset_n,pkt_valid,fifo_full,rst_int_reg,detect_add,ld_state,laf_state,full_state,lfd_state,input[7:0]data_in,output reg parity_done,low_pkt_valid,err,reg [7:0]dout,reg[1:0]data_addr);
reg [7:0]header_r,hold_r;
reg [7:0]packet_parity;
reg packet_parity_loaded;
reg [7:0]internal_parity;
reg header_latch;
reg header_parity_generated;

always@(posedge clock or negedge reset_n)
begin
if(!reset_n)
begin
dout <=0;
err <=0;
parity_done <=0;
low_pkt_valid <= 0;
header_r <=0;
hold_r <=0;
header_parity_generated <= 0;

internal_parity <=0;
header_latch <= 0;
end
end

always@(posedge clock)
begin
if((ld_state &&  !fifo_full && !pkt_valid)||(laf_state && low_pkt_valid && !parity_done)) parity_done <=1;

if(rst_int_reg) low_pkt_valid<=0;

if(detect_add) parity_done <=0;

if(ld_state && !pkt_valid ) low_pkt_valid <= 1; //

if(detect_add && pkt_valid && !header_latch )
begin
 header_r = data_in;//header
 data_addr = data_in[1:0];//data address
 header_latch =1;
end 

if(lfd_state) dout <= header_r;//header given to output

if(ld_state && !fifo_full) dout <= data_in;// payload

if(ld_state && fifo_full) hold_r <= data_in; // holding data while fifo full

if(laf_state)dout <= hold_r;// giving back the hold data after fifo full is resumed

if(ld_state && !pkt_valid )begin packet_parity_loaded =1; packet_parity <=data_in;end// receiving packet parity

if(packet_parity_loaded &&(packet_parity ==internal_parity) && parity_done)err = 0;// error check
else if(packet_parity_loaded &&(packet_parity !=internal_parity) && parity_done) err = 1;
end

always@(negedge clock)
begin
if(detect_add && pkt_valid && !full_state && !header_parity_generated)begin internal_parity = internal_parity ^ data_in;header_parity_generated =1;end// header parity generation
if(ld_state && pkt_valid && !full_state) internal_parity = internal_parity ^ data_in;  // payload parity generation
end


endmodule 
