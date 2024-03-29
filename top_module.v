`timescale 1ns / 1ps


module router(input clock,reset_n,read_enb_0,read_enb_1,read_enb_2,pkt_valid,[7:0]data_in,output valid_out_0,valid_out_1,valid_out_2,busy,error,[7:0]data_out_0, [7:0]data_out_1,[7:0]data_out_2 );

wire parity_done,soft_reset_0,soft_reset_1,soft_reset_2,fifo_full,low_pkt_vaid,fifo_empty_0,fifo_empty_1,fifo_empty_2,detect_add,ld_state,laf_state,full_state,lfd_state ,write_enb_reg,rst_int_reg,write_enb_0,write_enb_1,write_enb_2,empty_0,empty_1,empty_2,low_pkt_valid;
wire [1:0]data_in_w;
wire [7:0]dout_w;


//fsm instantiated

fsm fsm(.clock(clock),.reset_n(reset_n),.pkt_valid(pkt_valid),.parity_done(parity_done),.soft_reset_0(soft_reset_0),.soft_reset_1(soft_reset_1),.soft_reset_2(soft_reset_2),.fifo_full(fifo_full),.low_pkt_valid(low_pkt_valid),.fifo_empty_0(fifo_empty_0),.fifo_empty_1(fifo_empty_1),
.fifo_empty_2(fifo_empty_2),.data_in(data_in_w), .busy(busy),.detect_add(detect_add),.ld_state(ld_state),.laf_state(laf_state),.full_state(full_state),.lfd_state (lfd_state),.write_enb_reg(write_enb_reg),.rst_int_reg(rst_int_reg));

//synchronizer instantiated

synchronizer synchronizer(.detect_add(detect_add),.write_enb_reg(write_enb_reg),.clock(clock),.reset_n(reset_n),.read_enb_0(read_enb_0),.read_enb_1(read_enb_1),.read_enb_2(read_enb_2),.empty_0(fifo_empty_0),.empty_1(fifo_empty_1),.empty_2(fifo_empty_2),.full_0(full_0),.full_1(full_1),.full_2(full_2),.data_in(data_in_w),
.soft_reset_0(soft_reset_0),.soft_reset_1(soft_reset_1),.soft_reset_2(soft_reset_2),.fifo_full(fifo_full),.write_enb_0(write_enb_0),.write_enb_1(write_enb_1),.write_enb_2(write_enb_2),.valid_out_0(valid_out_0),.valid_out_1(valid_out_1),.valid_out_2(valid_out_2));

//Register instantiated
register register(.clock(clock),.reset_n(reset_n),.pkt_valid(pkt_valid),.fifo_full(fifo_full),.rst_int_reg(rst_int_reg),.detect_add(detect_add),.ld_state(ld_state),.laf_state(laf_state),.full_state(full_state),.lfd_state(lfd_state),.data_in(data_in),.parity_done(parity_done),.low_pkt_valid(low_pkt_valid),.err(error),.dout(dout_w),.data_addr(data_in_w));

//fifo instantiated

fifo fifo_0(.clock(clock),.reset_n(reset_n),.write_enb(write_enb_0),.soft_reset(soft_reset_0),.read_enb(read_enb_0),.lfd_state (lfd_state),.data_in(dout_w),.empty(fifo_empty_0),.full(full_0),.data_out(data_out_0));

fifo fifo_1(.clock(clock),.reset_n(reset_n),.write_enb(write_enb_1),.soft_reset(soft_reset_1),.read_enb(read_enb_1),.lfd_state (lfd_state),.data_in(dout_w),.empty(fifo_empty_1),.full(full_1),.data_out(data_out_1));

fifo fifo_2(.clock(clock),.reset_n(reset_n),.write_enb(write_enb_2),.soft_reset(soft_reset_2),.read_enb(read_enb_2),.lfd_state (lfd_state),.data_in(dout_w),.empty(fifo_empty_2),.full(full_2),.data_out(data_out_2));
endmodule








