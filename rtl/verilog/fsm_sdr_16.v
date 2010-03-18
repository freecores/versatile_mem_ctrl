`timescale 1ns/1ns
module fsm_sdr_16 (
    adr_i, we_i, bte_i,
    fifo_sel_i, fifo_sel_domain_i,
    fifo_sel_reg, fifo_sel_domain_reg,
    fifo_empty, fifo_rd, count0,
    refresh_req, cmd_aref, cmd_read,
    ba, a, cmd, dq_oe,
    sdram_clk, sdram_rst
);

parameter ba_size = 2;
parameter row_size = 13;
parameter col_size = 9;

input [ba_size+row_size+col_size-1:0] adr_i;
input we_i;
input [1:0] bte_i;

input [0:15] fifo_sel_i;
input [1:0] fifo_sel_domain_i;
output [0:15] fifo_sel_reg;
output [1:0] fifo_sel_domain_reg;

input  fifo_empty;
output fifo_rd;
output count0;

input refresh_req;
output reg cmd_aref; // used for rerfresh ack
output reg cmd_read; // used for ingress fifo control

output reg [1:0] ba;
output reg [12:0] a;
output reg [2:0] cmd;
output reg dq_oe;

input sdram_clk, sdram_rst;

wire [ba_size-1:0] bank;
wire [row_size-1:0] row;
wire [col_size-1:0] col;
wire [12:0]         col_reg_a10_fix;
reg [4:0] counter;

reg [0:15] fifo_sel_reg_int;
reg [1:0]  fifo_sel_domain_reg_int;

// adr_reg {ba,row,col,we}
reg [1:0]          ba_reg;  
reg [row_size-1:0] row_reg;
reg [col_size-1:0] col_reg;
reg                we_reg;
reg [1:0]          bte_reg;

// to keep track of open rows per bank
reg [row_size-1:0] open_row[3:0];
reg [3:0]          open_ba;

parameter [1:0] linear = 2'b00,
                beat4  = 2'b01,
                beat8  = 2'b10,
                beat16 = 2'b11;

parameter [2:0] cmd_nop = 3'b111,
                cmd_act = 3'b011,
                cmd_rd  = 3'b101,
                cmd_wr  = 3'b100,
                cmd_pch = 3'b010,
                cmd_rfr = 3'b001,
                cmd_lmr = 3'b000;

// ctrl FSM
parameter [2:0] init = 3'b000,
                idle = 3'b001,
                rfr  = 3'b010,
                adr  = 3'b011,
                pch  = 3'b100,
                act  = 3'b101,
                nop  = 3'b110,
                rw   = 3'b111;
reg [2:0] state, next;

function [12:0] a10_fix;
input [col_size-1:0] a;
integer i;
begin
    for (i=0;i<13;i=i+1) begin
        if (i<10)
            if (i<col_size)
                a10_fix[i] = a[i];
            else
                a10_fix[i] = 1'b0;
        else if (i==10)
            a10_fix[i] = 1'b0;
        else
            if (i<col_size)
                a10_fix[i] = a[i-1];
            else
                a10_fix[i] = 1'b0;
    end
end
endfunction


assign {bank,row,col} = adr_i;
always @ (posedge sdram_clk or posedge sdram_rst)
    if (sdram_rst)
        {ba_reg,row_reg,col_reg,we_reg,bte_reg} <= {2'b00,{row_size{1'b0}},{col_size{1'b0}}};
    else
        if (state==adr & !counter[0])
            {ba_reg,row_reg,col_reg,we_reg,bte_reg} <= {bank,row,col,we_i,bte_i};
            
always @ (posedge sdram_clk or posedge sdram_rst)
if (sdram_rst)
    state <= init;
else
    state <= next;
    
always @*
begin
    next = 3'bx;
    case (state)
    init:   if (counter==5'd31)     next = idle;
            else                    next = init;
    idle:   if (refresh_req)        next = rfr;
            else if (|fifo_sel_i)   next = adr;
            else                    next = idle;
    rfr:    if (counter==5'd5)      next = idle;
            else                    next = rfr;
    adr:    if (open_ba[ba_reg] & (open_row[ba_reg]==row_reg) & counter[0])  next = rw;
            else if (!open_ba[ba_reg] & counter[0])                    next = act;
            else if (counter[0])                                      next = pch;
            else next = adr;
    pch:    if (counter[0])         next = act;
            else                    next = pch;
    act:    if (counter==5'd2)      next = rw;
            else                    next = act;
//    nop:    next = rw;
    rw:     case ({bte_reg,counter})
            {linear,5'd1},{beat4,5'd7},{beat8,5'd15},{beat16,5'd31}: next =  idle;
            default: next = rw;
            endcase
    endcase
end

// counter
always @ (posedge sdram_clk or posedge sdram_rst)
begin
    if (sdram_rst)
        counter <= 5'd0;
    else
        if (state!=next)
            counter <= 5'd0;
        else
            if (~(state==rw & fifo_empty & ~counter[0] & we_reg))
                counter <= counter + 5'd1;
end

always @ (posedge sdram_clk or posedge sdram_rst)
begin
    if (sdram_rst)
        {fifo_sel_reg_int,fifo_sel_domain_reg_int} <= {16'h0,2'b00};
    else
        if (state==idle)
            {fifo_sel_reg_int,fifo_sel_domain_reg_int} <= {fifo_sel_i,fifo_sel_domain_i};
end

assign {fifo_sel_reg,fifo_sel_domain_reg} = (state==idle) ? {fifo_sel_i,fifo_sel_domain_i} : {fifo_sel_reg_int,fifo_sel_domain_reg_int};

// LMR
// [12:10] reserved
// [9]     WB, write burst; 0 - programmed burst length, 1 - single location
// [8:7]   OP Mode, 2'b00
// [6:4]   CAS Latency; 3'b010 - 2, 3'b011 - 3
// [3]     BT, Burst Type; 1'b0 - sequential, 1'b1 - interleaved
// [2:0]   Burst length; 3'b000 - 1, 3'b001 - 2, 3'b010 - 4, 3'b011 - 8, 3'b111 - full page
parameter [0:0] init_wb = 1'b0;
parameter [2:0] init_cl = 3'b010;
parameter [0:0] init_bt = 1'b0;
parameter [2:0] init_bl = 3'b001;

// ba, a, cmd
// col_reg_a10 has bit [10] set to zero to disable auto precharge
assign col_reg_a10_fix = a10_fix(col_reg);

always @ (posedge sdram_clk or posedge sdram_rst)
begin
    if (sdram_rst)
        {ba,a,cmd,cmd_aref,cmd_read} = {2'b00,13'd0,cmd_nop,1'b0,1'b0};
    else begin
        {ba,a,cmd,cmd_aref,cmd_read} = {2'b00,13'd0,cmd_nop,1'b0,1'b0};
        casex ({state,counter})
        {init,5'd3}, {rfr,5'd0}:
            {ba,a,cmd} = {2'b00, 13'b0010000000000, cmd_pch};
        {init,5'd7}, {init,5'd19}, {rfr,5'd2}:
            {ba,a,cmd,cmd_aref} = {2'b00, 13'd0, cmd_rfr,1'b1};  
        {init,5'd31}:
            {ba,a,cmd} = {2'b00,3'b000,init_wb,2'b00,init_cl,init_bt,init_bl, cmd_lmr};
        {pch,5'bxxxx0}:
            {ba,a,cmd} = {ba_reg,13'd0,cmd_pch};
        {act,5'd0}:
            {ba,a,cmd} = {ba_reg,(13'd0 | row_reg),cmd_act};
        {rw,5'bxxxxx}:
            begin
                /*if (!counter[0] & !fifo_empty)
                    {cmd,cmd_read} = {{2'b10,!we_reg},~we_reg};
                else
                    cmd = cmd_nop;*/
                casex ({we_reg,counter[0],fifo_empty})
                {1'b0,1'b0,1'bx}: {cmd,cmd_read} = {cmd_rd,1'b1};
                {1'b1,1'b0,1'b0}: cmd = cmd_wr;
                endcase
                case (bte_reg)
                linear: {ba,a} = {ba_reg,col_reg_a10_fix};
                beat4:  {ba,a} = {ba_reg,col_reg_a10_fix[12:3],col_reg_a10_fix[2:0] + counter[2:0]};
                beat8:  {ba,a} = {ba_reg,col_reg_a10_fix[12:4],col_reg_a10_fix[3:0] + counter[3:0]};
                beat16: {ba,a} = {ba_reg,col_reg_a10_fix[12:5],col_reg_a10_fix[4:0] + counter[4:0]};
                endcase
            end
        endcase
    end
end

// rd_adr goes high when next adr is fetched from sync RAM and during write burst
assign fifo_rd = ((state==idle) & (next==adr)) ? 1'b1 :
                 ((state==rw) & we_reg & !counter[0] & !fifo_empty) ? 1'b1 :
                 1'b0;

assign count0 = counter[0];

//assign dq_oe = (state==rw);
always @ (posedge sdram_clk or posedge sdram_rst)
    if (sdram_rst)
        dq_oe <= 1'b0;
    else
        dq_oe <= ((state==rw & we_reg & ~counter[0] & !fifo_empty) | (state==rw & we_reg & counter[0]));
            
always @ (posedge sdram_clk or posedge sdram_rst)
if (sdram_rst)
    {open_ba,open_row[0],open_row[1],open_row[2],open_row[3]} <= {4'b0000,{row_size*4{1'b0}}};
else
    casex ({ba,a[10],cmd})
    {2'bxx,1'b1,cmd_pch}: open_ba <= 4'b0000;
    {2'b00,1'b0,cmd_pch}: open_ba[0] <= 1'b0;
    {2'b01,1'b0,cmd_pch}: open_ba[1] <= 1'b0;
    {2'b10,1'b0,cmd_pch}: open_ba[2] <= 1'b0;
    {2'b11,1'b0,cmd_pch}: open_ba[3] <= 1'b0;
    {2'b00,1'bx,cmd_act}: {open_ba[0],open_row[0]} <= {1'b1,row_reg};
    {2'b01,1'bx,cmd_act}: {open_ba[1],open_row[1]} <= {1'b1,row_reg};
    {2'b10,1'bx,cmd_act}: {open_ba[2],open_row[2]} <= {1'b1,row_reg};
    {2'b11,1'bx,cmd_act}: {open_ba[3],open_row[3]} <= {1'b1,row_reg};
    endcase

endmodule
