module versatile_fifo_async_cmp ( wptr, rptr, fifo_empty, fifo_full, wclk, rclk, rst );
   parameter ADDR_WIDTH = 4;   
   parameter N = ADDR_WIDTH-1;
   parameter Q1 = 2'b00;
   parameter Q2 = 2'b01;
   parameter Q3 = 2'b11;
   parameter Q4 = 2'b10;
   parameter going_empty = 1'b0;
   parameter going_full  = 1'b1;
   input [N:0]  wptr, rptr;   
   output reg	fifo_empty;
   output       fifo_full;
   input 	wclk, rclk, rst;   
   wire direction;
   reg 	direction_set, direction_clr;
   wire async_empty, async_full;
   wire fifo_full2;
   reg  fifo_empty2;   
   always @ (wptr[N:N-1] or rptr[N:N-1])
     case ({wptr[N:N-1],rptr[N:N-1]})
       {Q1,Q2} : direction_set <= 1'b1;
       {Q2,Q3} : direction_set <= 1'b1;
       {Q3,Q4} : direction_set <= 1'b1;
       {Q4,Q1} : direction_set <= 1'b1;
       default : direction_set <= 1'b0;
     endcase
   always @ (wptr[N:N-1] or rptr[N:N-1] or rst)
     if (rst)
       direction_clr <= 1'b1;
     else
       case ({wptr[N:N-1],rptr[N:N-1]})
	 {Q2,Q1} : direction_clr <= 1'b1;
	 {Q3,Q2} : direction_clr <= 1'b1;
	 {Q4,Q3} : direction_clr <= 1'b1;
	 {Q1,Q4} : direction_clr <= 1'b1;
	 default : direction_clr <= 1'b0;
       endcase
    dff_sr dff_sr_dir( .aclr(direction_clr), .aset(direction_set), .clock(1'b1), .data(1'b1), .q(direction));
   assign async_empty = (wptr == rptr) && (direction==going_empty);
   assign async_full  = (wptr == rptr) && (direction==going_full);
    dff_sr dff_sr_empty0( .aclr(rst), .aset(async_full), .clock(wclk), .data(async_full), .q(fifo_full2));
    dff_sr dff_sr_empty1( .aclr(rst), .aset(async_full), .clock(wclk), .data(fifo_full2), .q(fifo_full));
   always @ (posedge rclk or posedge async_empty)
     if (async_empty)
       {fifo_empty, fifo_empty2} <= 2'b11;
     else
       {fifo_empty,fifo_empty2} <= {fifo_empty2,async_empty};   
endmodule 
module async_fifo_mq (
    d, fifo_full, write, write_enable, clk1, rst1,
    q, fifo_empty, read, read_enable, clk2, rst2
);
parameter a_hi_size = 4;
parameter a_lo_size = 4;
parameter nr_of_queues = 16;
parameter data_width = 36;
input [data_width-1:0] d;
output [0:nr_of_queues-1] fifo_full;
input                     write;
input  [0:nr_of_queues-1] write_enable;
input clk1;
input rst1;
output [data_width-1:0] q;
output [0:nr_of_queues-1] fifo_empty;
input                     read;
input  [0:nr_of_queues-1] read_enable;
input clk2;
input rst2;
wire [a_lo_size-1:0]  fifo_wadr_bin[0:nr_of_queues-1];
wire [a_lo_size-1:0]  fifo_wadr_gray[0:nr_of_queues-1];
wire [a_lo_size-1:0]  fifo_radr_bin[0:nr_of_queues-1];
wire [a_lo_size-1:0]  fifo_radr_gray[0:nr_of_queues-1];
reg [a_lo_size-1:0] wadr;
reg [a_lo_size-1:0] radr;
reg [data_width-1:0] wdata;
wire [data_width-1:0] wdataa[0:nr_of_queues-1];
genvar i;
integer j,k,l;
function [a_lo_size-1:0] onehot2bin;
input [0:nr_of_queues-1] a;
integer i;
begin
    onehot2bin = {a_lo_size{1'b0}};
    for (i=1;i<nr_of_queues;i=i+1) begin
        if (a[i])
            onehot2bin = i;
    end
end
endfunction
generate
    for (i=0;i<nr_of_queues;i=i+1) begin : fifo_adr
        gray_counter wadrcnt (
            .cke(write & write_enable[i]),
            .q(fifo_wadr_gray[i]),
            .q_bin(fifo_wadr_bin[i]),
            .rst(rst1),
            .clk(clk1));
        gray_counter radrcnt (
            .cke(read & read_enable[i]),
            .q(fifo_radr_gray[i]),
            .q_bin(fifo_radr_bin[i]),
            .rst(rst2),
            .clk(clk2));
	versatile_fifo_async_cmp
            #(.ADDR_WIDTH(a_lo_size))
            egresscmp ( 
                .wptr(fifo_wadr_gray[i]), 
		.rptr(fifo_radr_gray[i]), 
		.fifo_empty(fifo_empty[i]), 
		.fifo_full(fifo_full[i]), 
		.wclk(clk1), 
		.rclk(clk2), 
		.rst(rst1));
    end
endgenerate
always @*
begin
    wadr = {a_lo_size{1'b0}};
    for (j=0;j<nr_of_queues;j=j+1) begin
        wadr = (fifo_wadr_bin[j] & {a_lo_size{write_enable[j]}}) | wadr;
    end
end
always @*
begin
    radr = {a_lo_size{1'b0}};
    for (k=0;k<nr_of_queues;k=k+1) begin
        radr = (fifo_radr_bin[k] & {a_lo_size{read_enable[k]}}) | radr;
    end
end
vfifo_dual_port_ram_dc_sw # ( .DATA_WIDTH(data_width), .ADDR_WIDTH(a_hi_size+a_lo_size))
    dpram (
    .d_a(d),
    .adr_a({onehot2bin(write_enable),wadr}), 
    .we_a(write),
    .clk_a(clk1),
    .q_b(q),
    .adr_b({onehot2bin(read_enable),radr}),
    .clk_b(clk2) );
endmodule
`timescale 1ns/1ns
module delay (d, q, clk, rst);
   parameter width = 4;
   parameter depth = 3;
   input  [width-1:0] d;
   output [width-1:0] q;
   input              clk;
   input 	      rst;
   reg [width-1:0] dffs [1:depth];
   integer i;
   always @ (posedge clk or posedge rst)
     if (rst)
       for ( i=1; i <= depth; i=i+1)
	 dffs[i] <= {width{1'b0}};
     else
       begin
	  dffs[1] <= d;
	  for ( i=2; i <= depth; i=i+1 )
	    dffs[i] <= dffs[i-1];
       end
   assign q = dffs[depth];   
endmodule 
`timescale 1ns/1ns
module encode (
    fifo_empty_0, fifo_empty_1, fifo_empty_2, fifo_empty_3,
    fifo_sel, fifo_sel_domain
);
input  [0:15] fifo_empty_0, fifo_empty_1, fifo_empty_2, fifo_empty_3;
output [0:15] fifo_sel;
output [1:0]  fifo_sel_domain;
function [0:15] encode;
input [0:15] a;
input [0:15] b;
input [0:15] c;
input [0:15] d;
integer i;
begin
    if (!(&d))
        casex (d)
        16'b0xxxxxxxxxxxxxxx: encode = 16'b1000000000000000;
        16'b10xxxxxxxxxxxxxx: encode = 16'b0100000000000000;
        16'b110xxxxxxxxxxxxx: encode = 16'b0010000000000000;
        16'b1110xxxxxxxxxxxx: encode = 16'b0001000000000000;
        16'b11110xxxxxxxxxxx: encode = 16'b0000100000000000;
        16'b111110xxxxxxxxxx: encode = 16'b0000010000000000;
        16'b1111110xxxxxxxxx: encode = 16'b0000001000000000;
        16'b11111110xxxxxxxx: encode = 16'b0000000100000000;
        16'b111111110xxxxxxx: encode = 16'b0000000010000000;
        16'b1111111110xxxxxx: encode = 16'b0000000001000000;
        16'b11111111110xxxxx: encode = 16'b0000000000100000;
        16'b111111111110xxxx: encode = 16'b0000000000010000;
        16'b1111111111110xxx: encode = 16'b0000000000001000;
        16'b11111111111110xx: encode = 16'b0000000000000100;
        16'b111111111111110x: encode = 16'b0000000000000010;
        16'b1111111111111110: encode = 16'b0000000000000001;
        default:              encode = 16'b0000000000000000;
        endcase
    else if (!(&c))
        casex (c)
        16'b0xxxxxxxxxxxxxxx: encode = 16'b1000000000000000;
        16'b10xxxxxxxxxxxxxx: encode = 16'b0100000000000000;
        16'b110xxxxxxxxxxxxx: encode = 16'b0010000000000000;
        16'b1110xxxxxxxxxxxx: encode = 16'b0001000000000000;
        16'b11110xxxxxxxxxxx: encode = 16'b0000100000000000;
        16'b111110xxxxxxxxxx: encode = 16'b0000010000000000;
        16'b1111110xxxxxxxxx: encode = 16'b0000001000000000;
        16'b11111110xxxxxxxx: encode = 16'b0000000100000000;
        16'b111111110xxxxxxx: encode = 16'b0000000010000000;
        16'b1111111110xxxxxx: encode = 16'b0000000001000000;
        16'b11111111110xxxxx: encode = 16'b0000000000100000;
        16'b111111111110xxxx: encode = 16'b0000000000010000;
        16'b1111111111110xxx: encode = 16'b0000000000001000;
        16'b11111111111110xx: encode = 16'b0000000000000100;
        16'b111111111111110x: encode = 16'b0000000000000010;
        16'b1111111111111110: encode = 16'b0000000000000001;
        default:              encode = 16'b0000000000000000;
        endcase
    else if (!(&b))
        casex (b)
        16'b0xxxxxxxxxxxxxxx: encode = 16'b1000000000000000;
        16'b10xxxxxxxxxxxxxx: encode = 16'b0100000000000000;
        16'b110xxxxxxxxxxxxx: encode = 16'b0010000000000000;
        16'b1110xxxxxxxxxxxx: encode = 16'b0001000000000000;
        16'b11110xxxxxxxxxxx: encode = 16'b0000100000000000;
        16'b111110xxxxxxxxxx: encode = 16'b0000010000000000;
        16'b1111110xxxxxxxxx: encode = 16'b0000001000000000;
        16'b11111110xxxxxxxx: encode = 16'b0000000100000000;
        16'b111111110xxxxxxx: encode = 16'b0000000010000000;
        16'b1111111110xxxxxx: encode = 16'b0000000001000000;
        16'b11111111110xxxxx: encode = 16'b0000000000100000;
        16'b111111111110xxxx: encode = 16'b0000000000010000;
        16'b1111111111110xxx: encode = 16'b0000000000001000;
        16'b11111111111110xx: encode = 16'b0000000000000100;
        16'b111111111111110x: encode = 16'b0000000000000010;
        16'b1111111111111110: encode = 16'b0000000000000001;
        default:              encode = 16'b0000000000000000;
        endcase
    else
        casex (a)
        16'b0xxxxxxxxxxxxxxx: encode = 16'b1000000000000000;
        16'b10xxxxxxxxxxxxxx: encode = 16'b0100000000000000;
        16'b110xxxxxxxxxxxxx: encode = 16'b0010000000000000;
        16'b1110xxxxxxxxxxxx: encode = 16'b0001000000000000;
        16'b11110xxxxxxxxxxx: encode = 16'b0000100000000000;
        16'b111110xxxxxxxxxx: encode = 16'b0000010000000000;
        16'b1111110xxxxxxxxx: encode = 16'b0000001000000000;
        16'b11111110xxxxxxxx: encode = 16'b0000000100000000;
        16'b111111110xxxxxxx: encode = 16'b0000000010000000;
        16'b1111111110xxxxxx: encode = 16'b0000000001000000;
        16'b11111111110xxxxx: encode = 16'b0000000000100000;
        16'b111111111110xxxx: encode = 16'b0000000000010000;
        16'b1111111111110xxx: encode = 16'b0000000000001000;
        16'b11111111111110xx: encode = 16'b0000000000000100;
        16'b111111111111110x: encode = 16'b0000000000000010;
        16'b1111111111111110: encode = 16'b0000000000000001;
        default:              encode = 16'b0000000000000000;
        endcase
end
endfunction
assign fifo_sel = encode( fifo_empty_0, fifo_empty_1, fifo_empty_2, fifo_empty_3);
assign fifo_sel_domain = (!(&fifo_empty_3)) ? 2'b11 :
                         (!(&fifo_empty_2)) ? 2'b10 :
                         (!(&fifo_empty_1)) ? 2'b01 :
                         2'b00;
endmodule
`timescale 1ns/1ns
module decode (
    fifo_sel, fifo_sel_domain,
    fifo_we_0, fifo_we_1, fifo_we_2, fifo_we_3
);
input  [0:15] fifo_sel;
input  [1:0]  fifo_sel_domain;
output [0:15] fifo_we_0, fifo_we_1, fifo_we_2, fifo_we_3;
assign fifo_we_0 = (fifo_sel_domain == 2'b00) ? fifo_sel : {16{1'b0}};
assign fifo_we_1 = (fifo_sel_domain == 2'b01) ? fifo_sel : {16{1'b0}};
assign fifo_we_2 = (fifo_sel_domain == 2'b10) ? fifo_sel : {16{1'b0}};
assign fifo_we_3 = (fifo_sel_domain == 2'b11) ? fifo_sel : {16{1'b0}};
endmodule
module gray_counter ( cke, q, q_bin, rst, clk);
   parameter length = 4;
   input cke;
   output reg [length:1] q;
   output [length:1] q_bin;
   input rst;
   input clk;
   parameter clear_value = 0;
   reg  [length:1] qi;
   wire [length:1] q_next;
   assign q_next = qi + {{length-1{1'b0}},1'b1};
   always @ (posedge clk or posedge rst)
     if (rst)
       qi <= {length{1'b0}};
     else
     if (cke)
       qi <= q_next;
   always @ (posedge clk or posedge rst)
     if (rst)
       q <= {length{1'b0}};
     else
       if (cke)
         q <= (q_next>>1) ^ q_next;
   assign q_bin = qi;
endmodule
module egress_fifo (
    d, fifo_full, write, write_enable, clk1, rst1,
    q, fifo_empty, read_adr, read_data, read_enable, clk2, rst2
);
parameter a_hi_size = 4;
parameter a_lo_size = 4;
parameter nr_of_queues = 16;
parameter data_width = 36;
input [data_width*nr_of_queues-1:0] d;
output [0:nr_of_queues-1] fifo_full;
input                     write;
input  [0:nr_of_queues-1] write_enable;
input clk1;
input rst1;
output [data_width-1:0] q;
output [0:nr_of_queues-1] fifo_empty;
input                     read_adr, read_data;
input  [0:nr_of_queues-1] read_enable;
input clk2;
input rst2;
wire [a_lo_size-1:0]  fifo_wadr_bin[0:nr_of_queues-1];
wire [a_lo_size-1:0]  fifo_wadr_gray[0:nr_of_queues-1];
wire [a_lo_size-1:0]  fifo_radr_bin[0:nr_of_queues-1];
wire [a_lo_size-1:0]  fifo_radr_gray[0:nr_of_queues-1];
reg [a_lo_size-1:0] wadr;
reg [a_lo_size-1:0] radr;
reg [data_width-1:0] wdata;
wire [data_width-1:0] wdataa[0:nr_of_queues-1];
reg read_adr_reg;
reg [0:nr_of_queues-1] read_enable_reg;
genvar i;
integer j,k,l;
function [a_lo_size-1:0] onehot2bin;
input [0:nr_of_queues-1] a;
integer i;
begin
    onehot2bin = {a_lo_size{1'b0}};
    for (i=1;i<nr_of_queues;i=i+1) begin
        if (a[i])
            onehot2bin = i;
    end
end
endfunction
always @ (posedge clk2 or posedge rst2)
if (rst2)
    read_adr_reg <= 1'b0;
else
    read_adr_reg <= read_adr;
always @ (posedge clk2 or posedge rst2)
if (rst2)
    read_enable_reg <= {nr_of_queues{1'b0}};
else
    if (read_adr)
        read_enable_reg <= read_enable;
generate
    for (i=0;i<nr_of_queues;i=i+1) begin : fifo_adr
        gray_counter wadrcnt (
            .cke(write & write_enable[i]),
            .q(fifo_wadr_gray[i]),
            .q_bin(fifo_wadr_bin[i]),
            .rst(rst1),
            .clk(clk1));
        gray_counter radrcnt (
            .cke((read_adr_reg | read_data) & read_enable_reg[i]),
            .q(fifo_radr_gray[i]),
            .q_bin(fifo_radr_bin[i]),
            .rst(rst2),
            .clk(clk2));
	versatile_fifo_async_cmp
            #(.ADDR_WIDTH(a_lo_size))
            egresscmp ( 
                .wptr(fifo_wadr_gray[i]), 
		.rptr(fifo_radr_gray[i]), 
		.fifo_empty(fifo_empty[i]), 
		.fifo_full(fifo_full[i]), 
		.wclk(clk1), 
		.rclk(clk2), 
		.rst(rst1));
    end
endgenerate
always @*
begin
    wadr = {a_lo_size{1'b0}};
    for (j=0;j<nr_of_queues;j=j+1) begin
        wadr = (fifo_wadr_bin[j] & {a_lo_size{write_enable[j]}}) | wadr;
    end
end
always @*
begin
    radr = {a_lo_size{1'b0}};
    for (k=0;k<nr_of_queues;k=k+1) begin
        radr = (fifo_radr_bin[k] & {a_lo_size{read_enable_reg[k]}}) | radr;
    end
end
generate
    for (i=0;i<nr_of_queues;i=i+1) begin : vector2array
        assign wdataa[i] = d[(nr_of_queues-i)*data_width-1:(nr_of_queues-1-i)*data_width];
    end
endgenerate
always @*
begin
    wdata = {data_width{1'b0}};
    for (l=0;l<nr_of_queues;l=l+1) begin
        wdata = (wdataa[l] & {data_width{write_enable[l]}}) | wdata;
    end
end
vfifo_dual_port_ram_dc_sw # ( .DATA_WIDTH(data_width), .ADDR_WIDTH(a_hi_size+a_lo_size))
    dpram (
    .d_a(wdata),
    .adr_a({onehot2bin(write_enable),wadr}), 
    .we_a(write),
    .clk_a(clk1),
    .q_b(q),
    .adr_b({onehot2bin(read_enable_reg),radr}),
    .clk_b(clk2) );
endmodule
module vfifo_dual_port_ram_dc_sw
  (
   d_a,
   adr_a, 
   we_a,
   clk_a,
   q_b,
   adr_b,
   clk_b
   );
   parameter DATA_WIDTH = 32;
   parameter ADDR_WIDTH = 8;
   input [(DATA_WIDTH-1):0]      d_a;
   input [(ADDR_WIDTH-1):0] 	 adr_a;
   input [(ADDR_WIDTH-1):0] 	 adr_b;
   input 			 we_a;
   output [(DATA_WIDTH-1):0] 	 q_b;
   input 			 clk_a, clk_b;
   reg [(ADDR_WIDTH-1):0] 	 adr_b_reg;
   reg [DATA_WIDTH-1:0] ram [(1<<ADDR_WIDTH)-1:0] ;
   always @ (posedge clk_a)
   if (we_a)
     ram[adr_a] <= d_a;
   always @ (posedge clk_b)
   adr_b_reg <= adr_b;   
   assign q_b = ram[adr_b_reg];
endmodule 
module dff_sr ( aclr, aset, clock, data, q);
    input	  aclr;
    input	  aset;
    input	  clock;
    input	  data;
    output reg	  q;
   always @ (posedge clock or posedge aclr or posedge aset)
     if (aclr)
       q <= 1'b0;
     else if (aset)
       q <= 1'b1;
     else
       q <= data;
endmodule
module ref_counter ( zq, rst, clk);
   parameter length = 10;
   output reg zq;
   input rst;
   input clk;
   parameter clear_value = 0;
   parameter set_value = 0;
   parameter wrap_value = 417;
   reg  [length:1] qi;
   reg lfsr_fb;
   wire [length:1] q_next;
   reg [32:1] polynom;
   integer i;
   always @ (qi)
   begin
        case (length) 
         2: polynom = 32'b11;                               
         3: polynom = 32'b110;                              
         4: polynom = 32'b1100;                             
         5: polynom = 32'b10100;                            
         6: polynom = 32'b110000;                           
         7: polynom = 32'b1100000;                          
         8: polynom = 32'b10111000;                         
         9: polynom = 32'b100010000;                        
        10: polynom = 32'b1001000000;                       
        11: polynom = 32'b10100000000;                      
        12: polynom = 32'b100000101001;                     
        13: polynom = 32'b1000000001100;                    
        14: polynom = 32'b10000000010101;                   
        15: polynom = 32'b110000000000000;                  
        16: polynom = 32'b1101000000001000;                 
        17: polynom = 32'b10010000000000000;                
        18: polynom = 32'b100000010000000000;               
        19: polynom = 32'b1000000000000100011;              
        20: polynom = 32'b10000010000000000000;             
        21: polynom = 32'b101000000000000000000;            
        22: polynom = 32'b1100000000000000000000;           
        23: polynom = 32'b10000100000000000000000;          
        24: polynom = 32'b111000010000000000000000;         
        25: polynom = 32'b1001000000000000000000000;        
        26: polynom = 32'b10000000000000000000100011;       
        27: polynom = 32'b100000000000000000000010011;      
        28: polynom = 32'b1100100000000000000000000000;     
        29: polynom = 32'b10100000000000000000000000000;    
        30: polynom = 32'b100000000000000000000000101001;   
        31: polynom = 32'b1001000000000000000000000000000;  
        32: polynom = 32'b10000000001000000000000000000011; 
        default: polynom = 32'b0;
        endcase
        lfsr_fb = qi[length];
        for (i=length-1; i>=1; i=i-1) begin
            if (polynom[i])
                lfsr_fb = lfsr_fb  ~^ qi[i];
        end
    end
   assign q_next = (qi == wrap_value) ? {length{1'b0}} :{qi[length-1:1],lfsr_fb};
   always @ (posedge clk or posedge rst)
     if (rst)
       qi <= {length{1'b0}};
     else
       qi <= q_next;
   always @ (posedge clk or posedge rst)
     if (rst)
       zq <= 1'b1;
     else
       zq <= q_next == {length{1'b0}};
endmodule
`timescale 1ns/1ns
module fsm_sdr_16 (
    adr_i, we_i, bte_i, sel_i,
    fifo_empty, fifo_rd_adr, fifo_rd_data, count0,
    refresh_req, cmd_aref, cmd_read, state_idle,
    ba, a, cmd, dqm, dq_oe,
    sdram_clk, sdram_rst
);
parameter ba_size = 2;
parameter row_size = 13;
parameter col_size = 9;
input [ba_size+row_size+col_size-1:0] adr_i;
input we_i;
input [1:0] bte_i;
input [3:0] sel_i;
input  fifo_empty;
output fifo_rd_adr, fifo_rd_data;
output count0;
input refresh_req;
output reg cmd_aref; 
output reg cmd_read; 
output state_idle; 
output reg [1:0] ba;
output reg [12:0] a;
output reg [2:0] cmd;
output reg [1:0] dqm;
output reg dq_oe;
input sdram_clk, sdram_rst;
wire [ba_size-1:0] bank;
wire [row_size-1:0] row;
wire [col_size-1:0] col;
wire [12:0]         col_reg_a10_fix;
reg [4:0] counter;
reg [0:15] fifo_sel_reg_int;
reg [1:0]  fifo_sel_domain_reg_int;
reg [1:0]          ba_reg;  
reg [row_size-1:0] row_reg;
reg [col_size-1:0] col_reg;
reg                we_reg;
reg [1:0]          bte_reg;
reg [row_size-1:0] open_row[0:3];
reg [0:3]          open_ba;
wire current_bank_closed, current_row_open;
reg current_bank_closed_reg, current_row_open_reg;
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
parameter [2:0] init = 3'b000,
                idle = 3'b001,
                rfr  = 3'b010,
                adr  = 3'b011,
                pch  = 3'b100,
                act  = 3'b101,
                w4d  = 3'b110,
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
        {ba_reg,row_reg,col_reg,we_reg,bte_reg} <= {2'b00, {row_size{1'b0}}, {col_size{1'b0}}, 1'b0, 2'b00 };
    else
        if (state==adr & counter[1:0]==2'b10)
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
            else if (!fifo_empty)   next = adr;
            else                    next = idle;
    rfr:    if (counter==5'd5)      next = idle;
            else                    next = rfr;
    adr:    if (current_row_open_reg & (counter[1:0]==2'b11) & we_reg)  next = w4d;
            else if (current_row_open_reg & (counter[1:0]==2'b11))    next = rw;
            else if (current_bank_closed_reg & (counter[1:0]==2'b11)) next = act;
            else if ((counter[1:0]==2'b11))                       next = pch;
            else next = adr;
    pch:    if (counter[0])         next = act;
            else                    next = pch;
    act:    if (counter[1:0]==2'd2 & (!fifo_empty | !we_reg))       next = rw;
            else if (counter[1:0]==2'd2 & fifo_empty)   next = w4d;
            else                                        next = act;
    w4d:    if (!fifo_empty) next = rw;
            else             next = w4d;
    rw:     casex ({bte_reg,counter})
            {linear,5'bxxxx1},{beat4,5'bxx111},{beat8,5'bx1111},{beat16,5'b11111}: next =  idle;
            default: next = rw;
            endcase
    endcase
end
always @ (posedge sdram_clk or posedge sdram_rst)
begin
    if (sdram_rst)
        counter <= 5'd0;
    else
        if (state!=next)
            counter <= 5'd0;
        else
            if (~(state==rw & next==rw & fifo_empty & counter[0] & we_reg))
                counter <= counter + 5'd1;
end
assign count0 = counter[0];
parameter [0:0] init_wb = 1'b0;
parameter [2:0] init_cl = 3'b010;
parameter [0:0] init_bt = 1'b0;
parameter [2:0] init_bl = 3'b001;
assign col_reg_a10_fix = a10_fix(col_reg);
always @ (posedge sdram_clk or posedge sdram_rst)
begin
    if (sdram_rst) begin
        {ba,a,cmd} = {2'b00,13'd0,cmd_nop};
        dqm = 2'b11;
        cmd_aref = 1'b0;
        cmd_read = 1'b0;
        dq_oe = 1'b0;
        {open_ba,open_row[0],open_row[1],open_row[2],open_row[3]} <= {4'b0000,{row_size*4{1'b0}}};
    end else begin
        {ba,a,cmd} = {2'b00,13'd0,cmd_nop};
        dqm = 2'b11;
        cmd_aref = 1'b0;
        cmd_read = 1'b0;
        dq_oe = 1'b0;
        casex ({state,counter})
        {init,5'd3}, {rfr,5'd0}: begin
            {ba,a,cmd} = {2'b00, 13'b0010000000000, cmd_pch};
            open_ba[ba_reg] <= 1'b0;
            end
        {init,5'd7}, {init,5'd19}, {rfr,5'd2}:
            {ba,a,cmd,cmd_aref} = {2'b00, 13'd0, cmd_rfr,1'b1};  
        {init,5'd31}:
            {ba,a,cmd} = {2'b00,3'b000,init_wb,2'b00,init_cl,init_bt,init_bl, cmd_lmr};
        {pch,5'bxxxx0}: begin
            {ba,a,cmd} = {ba_reg,13'd0,cmd_pch};
            open_ba <= 4'b0000;
            end
        {act,5'd0}: begin
            {ba,a,cmd} = {ba_reg,(13'd0 | row_reg),cmd_act};
            {open_ba[ba_reg],open_row[ba_reg]} <= {1'b1,row_reg};
            end
        {rw,5'bxxxxx}:
            begin
                if (we_reg & !counter[0])
                    cmd = cmd_wr;
                else if (!counter[0])
                    {cmd,cmd_read} = {cmd_rd,1'b1};
                else
                    cmd = cmd_nop;
                if (we_reg & !counter[0])
                    dqm = ~sel_i[3:2];
                else if (we_reg & counter[0])
                    dqm = ~sel_i[1:0];
                else
                    dqm = 2'b00;
                if (we_reg)
                    dq_oe = 1'b1;
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
assign fifo_rd_adr = ((state==adr) & (counter[1:0]==2'b00)) ? 1'b1 : 1'b0;
assign fifo_rd_data = (state==w4d & !fifo_empty) ? 1'b1 :
                      ((state==rw & next==rw) & we_reg & !counter[0] & !fifo_empty) ? 1'b1 :
                      1'b0;
assign state_idle = (state==idle);
assign current_bank_closed = !(open_ba[bank]);
assign current_row_open = open_ba[bank] & (open_row[bank]==row);
always @ (posedge sdram_clk or posedge sdram_rst)
    if (sdram_rst)
        {current_bank_closed_reg, current_row_open_reg} <= {1'b1, 1'b0};
    else
        {current_bank_closed_reg, current_row_open_reg} <= {current_bank_closed, current_row_open};
endmodule
`timescale 1ns/1ns
module versatile_mem_ctrl_wb (
    wb_adr_i_v, wb_dat_i_v, wb_dat_o_v,
    wb_stb_i, wb_cyc_i, wb_ack_o,
    wb_clk, wb_rst,
    sdram_dat_o, sdram_fifo_empty, sdram_fifo_rd_adr, sdram_fifo_rd_data, sdram_fifo_re,
    sdram_dat_i, sdram_fifo_wr, sdram_fifo_we,
    sdram_clk, sdram_rst
);
parameter nr_of_wb_ports = 3;
input  [36*nr_of_wb_ports-1:0]  wb_adr_i_v;
input  [36*nr_of_wb_ports-1:0]  wb_dat_i_v;
input  [0:nr_of_wb_ports-1]     wb_stb_i;
input  [0:nr_of_wb_ports-1]     wb_cyc_i;
output [32*nr_of_wb_ports-1:0]  wb_dat_o_v;
output [0:nr_of_wb_ports-1]     wb_ack_o;
input                           wb_clk;
input                           wb_rst;
output [35:0]               sdram_dat_o;
output [0:nr_of_wb_ports-1] sdram_fifo_empty;
input                       sdram_fifo_rd_adr, sdram_fifo_rd_data;
input  [0:nr_of_wb_ports-1] sdram_fifo_re;
input  [31:0]               sdram_dat_i;
input                       sdram_fifo_wr;
input  [0:nr_of_wb_ports-1] sdram_fifo_we;
input                       sdram_clk;
input                       sdram_rst;
parameter linear       = 2'b00;
parameter wrap4        = 2'b01;
parameter wrap8        = 2'b10;
parameter wrap16       = 2'b11;
parameter classic      = 3'b000;
parameter endofburst   = 3'b111;
parameter idle = 2'b00;
parameter rd   = 2'b01;
parameter wr   = 2'b10;
reg [1:0] wb_state[0:nr_of_wb_ports-1];
wire [35:0] wb_adr_i[0:nr_of_wb_ports-1];
wire [35:0] wb_dat_i[0:nr_of_wb_ports-1];
wire [36*nr_of_wb_ports-1:0] egress_fifo_di;
wire [31:0] wb_dat_o;
wire [0:nr_of_wb_ports-1] wb_wr_ack, wb_rd_ack, wr_adr;
reg  [0:nr_of_wb_ports-1] wb_rd_ack_dly;
wire [0:nr_of_wb_ports-1] egress_fifo_full;
wire [0:nr_of_wb_ports-1] ingress_fifo_empty;
genvar i;
generate
    for (i=0;i<nr_of_wb_ports;i=i+1) begin : vector2array
        assign wb_adr_i[i] = wb_adr_i_v[(nr_of_wb_ports-i)*36-1:(nr_of_wb_ports-1-i)*36];
        assign wb_dat_i[i] = wb_dat_i_v[(nr_of_wb_ports-i)*36-1:(nr_of_wb_ports-1-i)*36];
        assign egress_fifo_di[(nr_of_wb_ports-i)*36-1:(nr_of_wb_ports-1-i)*36] = (wb_state[i]==idle) ? wb_adr_i[i] : wb_dat_i[i];
    end
endgenerate
generate
    assign wb_wr_ack[0] = ((wb_state[0]==idle | wb_state[0]==wr) & wb_cyc_i[0] & wb_stb_i[0] & !egress_fifo_full[0]);
    for (i=1;i<nr_of_wb_ports;i=i+1) begin : wr_ack
        assign wb_wr_ack[i] = (|(wb_wr_ack[0:i-1])) ? 1'b0 : ((wb_state[i]==idle | wb_state[i]==wr) & wb_cyc_i[i] & wb_stb_i[i] & !egress_fifo_full[i]);
    end
endgenerate
generate
    assign wb_rd_ack[0] = ((wb_state[0]==rd) & wb_cyc_i[0] & wb_stb_i[0] & !ingress_fifo_empty[0]);
    for (i=1;i<nr_of_wb_ports;i=i+1) begin : rd_ack
        assign wb_rd_ack[i] = (|(wb_rd_ack[0:i-1])) ? 1'b0 : ((wb_state[i]==rd) & wb_cyc_i[i] & wb_stb_i[i] & !ingress_fifo_empty[i]);
    end
endgenerate
always @ (posedge wb_clk or posedge wb_rst)
    if (wb_rst)
        wb_rd_ack_dly <= {nr_of_wb_ports{1'b0}};
    else
        wb_rd_ack_dly <= wb_rd_ack;
generate
    for (i=0;i<nr_of_wb_ports;i=i+1) begin : wb_ack
        assign wb_ack_o[i] = (wb_state[i]==wr & wb_wr_ack[i]) | wb_rd_ack_dly[i];
    end
endgenerate
generate
    for (i=0;i<nr_of_wb_ports;i=i+1) begin : fsm
        always @ (posedge wb_clk or posedge wb_rst)
        if (wb_rst)
            wb_state[i] <= idle;
        else
            case (wb_state[i])
            idle:
                if (wb_wr_ack[i] & wb_adr_i[i][5])
                    wb_state[i] <= wr;
                else if (wb_wr_ack[i])
                    wb_state[i] <= rd;
            rd:
                if ((wb_adr_i[i][2:0]==classic | wb_adr_i[i][2:0]==endofburst | wb_adr_i[i][4:3]==linear) & wb_ack_o[i])
                    wb_state[i] <= idle;
            wr:
                if ((wb_adr_i[i][2:0]==classic | wb_adr_i[i][2:0]==endofburst | wb_adr_i[i][4:3]==linear) & wb_ack_o[i])
                    wb_state[i] <= idle;
            default: ;
            endcase
    end
endgenerate
egress_fifo # (.a_hi_size(4),.a_lo_size(4),.nr_of_queues(nr_of_wb_ports),.data_width(36))
egress_FIFO(
    .d(egress_fifo_di), .fifo_full(egress_fifo_full), .write(|(wb_wr_ack)), .write_enable(wb_wr_ack),
    .q(sdram_dat_o), .fifo_empty(sdram_fifo_empty), .read_adr(sdram_fifo_rd_adr), .read_data(sdram_fifo_rd_data), .read_enable(sdram_fifo_re),
    .clk1(wb_clk), .rst1(wb_rst), .clk2(sdram_clk), .rst2(sdram_rst)
);
async_fifo_mq # (.a_hi_size(4),.a_lo_size(4),.nr_of_queues(nr_of_wb_ports),.data_width(32))
ingress_FIFO(
    .d(sdram_dat_i), .fifo_full(), .write(sdram_fifo_wr), .write_enable(sdram_fifo_we),
    .q(wb_dat_o), .fifo_empty(ingress_fifo_empty), .read(|(wb_rd_ack)), .read_enable(wb_rd_ack),
    .clk1(sdram_clk), .rst1(sdram_rst), .clk2(wb_clk), .rst2(wb_rst)
);
assign wb_dat_o_v = {nr_of_wb_ports{wb_dat_o}};
endmodule
`timescale 1ns/1ns
module versatile_mem_ctrl_top
  (
    wb_adr_i_0, wb_dat_i_0, wb_dat_o_0,
    wb_stb_i_0, wb_cyc_i_0, wb_ack_o_0,
    wb_adr_i_1, wb_dat_i_1, wb_dat_o_1,
    wb_stb_i_1, wb_cyc_i_1, wb_ack_o_1,
    wb_adr_i_2, wb_dat_i_2, wb_dat_o_2,
    wb_stb_i_2, wb_cyc_i_2, wb_ack_o_2,
    wb_adr_i_3, wb_dat_i_3, wb_dat_o_3,
    wb_stb_i_3, wb_cyc_i_3, wb_ack_o_3,
    wb_clk, wb_rst,
    ba_pad_o, a_pad_o, cs_n_pad_o, ras_pad_o, cas_pad_o, we_pad_o, dq_o, dqm_pad_o, dq_i, dq_oe, cke_pad_o,
   sdram_clk, sdram_rst
   );
    parameter nr_of_wb_clk_domains = 1;
    parameter nr_of_wb_ports_clk0  = 1;
    parameter nr_of_wb_ports_clk1  = 0;
    parameter nr_of_wb_ports_clk2  = 0;
    parameter nr_of_wb_ports_clk3  = 0;
    parameter ba_size = 2;
    parameter row_size = 13;
    parameter col_size = 9;
    parameter [2:0] cl = 3'b010; 
    input  [36*nr_of_wb_ports_clk0-1:0] wb_adr_i_0;
    input  [36*nr_of_wb_ports_clk0-1:0] wb_dat_i_0;
    output [32*nr_of_wb_ports_clk0-1:0] wb_dat_o_0;
    input  [0:nr_of_wb_ports_clk0-1]    wb_stb_i_0, wb_cyc_i_0, wb_ack_o_0;
    input  [36*nr_of_wb_ports_clk1-1:0] wb_adr_i_1;
    input  [36*nr_of_wb_ports_clk1-1:0] wb_dat_i_1;
    output [32*nr_of_wb_ports_clk1-1:0] wb_dat_o_1;
    input  [0:nr_of_wb_ports_clk1-1]    wb_stb_i_1, wb_cyc_i_1, wb_ack_o_1;
    input  [36*nr_of_wb_ports_clk2-1:0] wb_adr_i_2;
    input  [36*nr_of_wb_ports_clk2-1:0] wb_dat_i_2;
    output [32*nr_of_wb_ports_clk2-1:0] wb_dat_o_2;
    input  [0:nr_of_wb_ports_clk2-1]    wb_stb_i_2, wb_cyc_i_2, wb_ack_o_2;
    input  [36*nr_of_wb_ports_clk3-1:0] wb_adr_i_3;
    input  [36*nr_of_wb_ports_clk3-1:0] wb_dat_i_3;
    output [32*nr_of_wb_ports_clk3-1:0] wb_dat_o_3;
    input  [0:nr_of_wb_ports_clk3-1]    wb_stb_i_3, wb_cyc_i_3, wb_ack_o_3;
    input  [0:nr_of_wb_clk_domains-1]   wb_clk;
    input  [0:nr_of_wb_clk_domains-1]   wb_rst;
   output  [1:0]  ba_pad_o;
   output  [12:0] a_pad_o;
   output         cs_n_pad_o;
   output         ras_pad_o;
   output         cas_pad_o;
   output         we_pad_o;
   output reg [15:0] dq_o;
   output [1:0] dqm_pad_o;
   input  [15:0] dq_i;
   output        dq_oe;
   output        cke_pad_o;
    input        sdram_clk, sdram_rst;
    wire [0:15] fifo_empty[0:3];
    wire        current_fifo_empty;
    wire [0:15] fifo_re[0:3];
    wire [35:0] fifo_dat_o[0:3];
    wire [31:0] fifo_dat_i;
    wire [0:15] fifo_we[0:3];
    wire fifo_rd_adr, fifo_rd_data, fifo_wr, idle, count0;
    wire [0:15] fifo_sel_i, fifo_sel_dly;
    reg [0:15] fifo_sel_reg;
    wire [1:0]  fifo_sel_domain_i, fifo_sel_domain_dly;
    reg [1:0] fifo_sel_domain_reg;
    reg refresh_req;
    wire [35:0] tx_fifo_dat_o;   
generate   
    if (nr_of_wb_clk_domains > 0) begin    
        versatile_mem_ctrl_wb
        # (.nr_of_wb_ports(nr_of_wb_ports_clk0))
        wb0(
            .wb_adr_i_v(wb_adr_i_0),
            .wb_dat_i_v(wb_dat_i_0),
            .wb_dat_o_v(wb_dat_o_0),
            .wb_stb_i(wb_stb_i_0),
            .wb_cyc_i(wb_cyc_i_0),
            .wb_ack_o(wb_ack_o_0),
            .wb_clk(wb_clk[0]),
            .wb_rst(wb_rst[0]),
            .sdram_dat_o(fifo_dat_o[0]),
            .sdram_fifo_empty(fifo_empty[0][0:nr_of_wb_ports_clk0-1]),
            .sdram_fifo_rd_adr(fifo_rd_adr),
            .sdram_fifo_rd_data(fifo_rd_data),
            .sdram_fifo_re(fifo_re[0][0:nr_of_wb_ports_clk0-1]),
            .sdram_dat_i(fifo_dat_i),
            .sdram_fifo_wr(fifo_wr),
            .sdram_fifo_we(fifo_we[0][0:nr_of_wb_ports_clk0-1]),
            .sdram_clk(sdram_clk),
            .sdram_rst(sdram_rst) );
    end
    if (nr_of_wb_ports_clk0 < 16) begin
        assign fifo_empty[0][nr_of_wb_ports_clk0:15] = {(16-nr_of_wb_ports_clk0){1'b1}};
    end
endgenerate
generate   
    if (nr_of_wb_clk_domains > 1) begin    
        versatile_mem_ctrl_wb
        # (.nr_of_wb_ports(nr_of_wb_ports_clk1))
        wb1(
            .wb_adr_i_v(wb_adr_i_1),
            .wb_dat_i_v(wb_dat_i_1),
            .wb_dat_o_v(wb_dat_o_1),
            .wb_stb_i(wb_stb_i_1),
            .wb_cyc_i(wb_cyc_i_1),
            .wb_ack_o(wb_ack_o_1),
            .wb_clk(wb_clk[1]),
            .wb_rst(wb_rst[1]),
            .sdram_dat_o(fifo_dat_o[1]),
            .sdram_fifo_empty(fifo_empty[1][0:nr_of_wb_ports_clk1-1]),
            .sdram_fifo_rd_adr(fifo_rd_adr),
            .sdram_fifo_rd_data(fifo_rd_data),
            .sdram_fifo_re(fifo_re[1][0:nr_of_wb_ports_clk1-1]),
            .sdram_dat_i(fifo_dat_i),
            .sdram_fifo_wr(fifo_wr),
            .sdram_fifo_we(fifo_we[1][0:nr_of_wb_ports_clk1-1]),
            .sdram_clk(sdram_clk),
            .sdram_rst(sdram_rst) );
        if (nr_of_wb_ports_clk1 < 16) begin
            assign fifo_empty[1][nr_of_wb_ports_clk1:15] = {(16-nr_of_wb_ports_clk1){1'b1}};
        end
    end else begin
        assign fifo_empty[1] = {16{1'b1}};
        assign fifo_dat_o[1] = {36{1'b0}};
    end
endgenerate
generate   
    if (nr_of_wb_clk_domains > 2) begin    
        versatile_mem_ctrl_wb
        # (.nr_of_wb_ports(nr_of_wb_ports_clk1))
        wb2(
            .wb_adr_i_v(wb_adr_i_2),
            .wb_dat_i_v(wb_dat_i_2),
            .wb_dat_o_v(wb_dat_o_2),
            .wb_stb_i(wb_stb_i_2),
            .wb_cyc_i(wb_cyc_i_2),
            .wb_ack_o(wb_ack_o_2),
            .wb_clk(wb_clk[2]),
            .wb_rst(wb_rst[2]),
            .sdram_dat_o(fifo_dat_o[2]),
            .sdram_fifo_empty(fifo_empty[2][0:nr_of_wb_ports_clk2-1]),
            .sdram_fifo_rd_adr(fifo_rd_adr),
            .sdram_fifo_rd_data(fifo_rd_data),
            .sdram_fifo_re(fifo_re[2][0:nr_of_wb_ports_clk2-1]),
            .sdram_dat_i(fifo_dat_i),
            .sdram_fifo_wr(fifo_wr),
            .sdram_fifo_we(fifo_we[2][0:nr_of_wb_ports_clk2-1]),
            .sdram_clk(sdram_clk),
            .sdram_rst(sdram_rst) );
        if (nr_of_wb_ports_clk2 < 16) begin
            assign fifo_empty[2][nr_of_wb_ports_clk2:15] = {(16-nr_of_wb_ports_clk2){1'b1}};
        end
    end else begin
        assign fifo_empty[2] = {16{1'b1}};
        assign fifo_dat_o[2] = {36{1'b0}};
    end
endgenerate
generate   
    if (nr_of_wb_clk_domains > 3) begin    
        versatile_mem_ctrl_wb
        # (.nr_of_wb_ports(nr_of_wb_ports_clk3))
        wb3(
            .wb_adr_i_v(wb_adr_i_3),
            .wb_dat_i_v(wb_dat_i_3),
            .wb_dat_o_v(wb_dat_o_3),
            .wb_stb_i(wb_stb_i_3),
            .wb_cyc_i(wb_cyc_i_3),
            .wb_ack_o(wb_ack_o_3),
            .wb_clk(wb_clk[3]),
            .wb_rst(wb_rst[3]),
            .sdram_dat_o(fifo_dat_o[3]),
            .sdram_fifo_empty(fifo_empty[3][0:nr_of_wb_ports_clk3-1]),
            .sdram_fifo_rd_adr(fifo_rd_adr),
            .sdram_fifo_rd_data(fifo_rd_data),
            .sdram_fifo_re(fifo_re[3][0:nr_of_wb_ports_clk3-1]),
            .sdram_dat_i(fifo_dat_i),
            .sdram_fifo_wr(fifo_wr),
            .sdram_fifo_we(fifo_we[3][0:nr_of_wb_ports_clk3-1]),
            .sdram_clk(sdram_clk),
            .sdram_rst(sdram_rst) );
        if (nr_of_wb_ports_clk3 < 16) begin
            assign fifo_empty[3][nr_of_wb_ports_clk3:15] = {(16-nr_of_wb_ports_clk3){1'b1}};
        end
    end else begin
        assign fifo_empty[3] = {16{1'b1}};
        assign fifo_dat_o[3] = {36{1'b0}};
    end
endgenerate
encode encode0 (
    .fifo_empty_0(fifo_empty[0]), .fifo_empty_1(fifo_empty[1]), .fifo_empty_2(fifo_empty[2]), .fifo_empty_3(fifo_empty[3]),
    .fifo_sel(fifo_sel_i), .fifo_sel_domain(fifo_sel_domain_i)
);
always @ (posedge sdram_clk or posedge sdram_rst)
begin
    if (sdram_rst)
        {fifo_sel_reg,fifo_sel_domain_reg} <= {16'h0,2'b00};
    else
        if (idle)
            {fifo_sel_reg,fifo_sel_domain_reg} <= {fifo_sel_i,fifo_sel_domain_i};
end
decode decode0 (
    .fifo_sel(fifo_sel_reg), .fifo_sel_domain(fifo_sel_domain_reg),
    .fifo_we_0(fifo_re[0]), .fifo_we_1(fifo_re[1]), .fifo_we_2(fifo_re[2]), .fifo_we_3(fifo_re[3])
);
assign current_fifo_empty = (idle) ? (!(|fifo_sel_i)) : (|(fifo_empty[0] & fifo_re[0])) | (|(fifo_empty[1] & fifo_re[1])) | (|(fifo_empty[2] & fifo_re[2])) | (|(fifo_empty[3] & fifo_re[3]));
decode decode1 (
    .fifo_sel(fifo_sel_dly), .fifo_sel_domain(fifo_sel_domain_dly),
    .fifo_we_0(fifo_we[0]), .fifo_we_1(fifo_we[1]), .fifo_we_2(fifo_we[2]), .fifo_we_3(fifo_we[3])
);
    wire ref_cnt_zero;
    reg [15:0] dq_i_reg, dq_i_tmp_reg;
    reg [17:0] dq_o_tmp_reg;
    wire cmd_aref, cmd_read;
    ref_counter ref_counter0( .zq(ref_cnt_zero), .rst(sdram_rst), .clk(sdram_clk));
    always @ (posedge sdram_clk or posedge sdram_rst)
    if (sdram_rst)
        refresh_req <= 1'b0;
    else
        if (ref_cnt_zero)
            refresh_req <= 1'b1;
        else if (cmd_aref)
            refresh_req <= 1'b0;
    fsm_sdr_16 # ( 
		   .ba_size(ba_size), 
		   .row_size(row_size), 
		   .col_size(col_size), 
		   .init_cl(cl)
		   )
   fsm_sdr_16(
              .adr_i({fifo_dat_o[fifo_sel_domain_reg][ba_size+row_size+col_size+6-2:6],1'b0}),
              .we_i(fifo_dat_o[fifo_sel_domain_reg][5]),
              .bte_i(fifo_dat_o[fifo_sel_domain_reg][4:3]),
              .sel_i({fifo_dat_o[fifo_sel_domain_reg][3:2],dq_o_tmp_reg[1:0]}),
              .fifo_empty(current_fifo_empty), 
	      .fifo_rd_adr(fifo_rd_adr), 
	      .fifo_rd_data(fifo_rd_data),
              .state_idle(idle), 
	      .count0(count0),
              .refresh_req(refresh_req),
              .cmd_aref(cmd_aref), 
	      .cmd_read(cmd_read),
              .ba(ba_pad_o), .a(a_pad_o), 
	      .cmd({ras_pad_o, cas_pad_o, we_pad_o}), 
	      .dq_oe(dq_oe), 
	      .dqm(dqm_pad_o),
              .sdram_clk(sdram_clk), 
	      .sdram_rst(sdram_rst)
	      );
    assign cs_pad_o = 1'b0;
    assign cke_pad_o = 1'b1;
genvar i;
generate
    for (i=0; i < 16; i=i+1) begin : dly
        defparam delay0.depth=cl+2;   
        defparam delay0.width=1;
        delay delay0 (
            .d(fifo_sel_reg[i]),
            .q(fifo_sel_dly[i]),
            .clk(sdram_clk),
            .rst(sdram_rst)
        );
    end
    defparam delay1.depth=cl+2;   
    defparam delay1.width=2;
    delay delay1 (
        .d(fifo_sel_domain_reg),
        .q(fifo_sel_domain_dly),
        .clk(sdram_clk),
        .rst(sdram_rst)
    );
    defparam delay2.depth=cl+2;   
    defparam delay2.width=1;
    delay delay2 (
        .d(cmd_read),
        .q(fifo_wr),
        .clk(sdram_clk),
        .rst(sdram_rst)
    );    
endgenerate  
    assign cs_n_pad_o = 1'b0;
    assign cke_pad_o  = 1'b1;
    always @ (posedge sdram_clk or posedge sdram_rst)
     if (sdram_rst)
       {dq_i_reg, dq_i_tmp_reg} <= {16'h0000,16'h0000};
     else
       {dq_i_reg, dq_i_tmp_reg} <= {dq_i, dq_i_reg};
    assign fifo_dat_i = {dq_i_tmp_reg, dq_i_reg};
    always @ (posedge sdram_clk or posedge sdram_rst)
    if (sdram_rst)
        dq_o_tmp_reg <= 18'h0;
    else
        dq_o_tmp_reg <= {fifo_dat_o[fifo_sel_domain_reg][19:4],fifo_dat_o[fifo_sel_domain_reg][1:0]};
    always @ (posedge sdram_clk or posedge sdram_rst)
    if (sdram_rst)
        dq_o <= 16'h0000;
    else
        if (~count0)
            dq_o <= fifo_dat_o[fifo_sel_domain_reg][35:20];
        else
            dq_o <= dq_o_tmp_reg[17:2];
endmodule 
