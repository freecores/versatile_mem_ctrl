//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Versatile memory controller                                 ////
////                                                              ////
////  Description                                                 ////
////  A modular wishbone compatible memory controller with support////
////  for various types of memory configurations                  ////
////                                                              ////
////  To Do:                                                      ////
////   - add support for additional SDRAM variants                ////
////                                                              ////
////  Author(s):                                                  ////
////      - Michael Unneback, unneback@opencores.org              ////
////        ORSoC AB                                              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2009 Authors and OPENCORES.ORG                 ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
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
   output reg	fifo_empty, fifo_full;
   input 	wclk, rclk, rst;   
   
   reg 	direction, direction_set, direction_clr;
   
   wire async_empty, async_full;
   reg 	fifo_full2, fifo_empty2;   
   
   // direction_set
   always @ (wptr[N:N-1] or rptr[N:N-1])
     case ({wptr[N:N-1],rptr[N:N-1]})
       {Q1,Q2} : direction_set <= 1'b1;
       {Q2,Q3} : direction_set <= 1'b1;
       {Q3,Q4} : direction_set <= 1'b1;
       {Q4,Q1} : direction_set <= 1'b1;
       default : direction_set <= 1'b0;
     endcase

   // direction_clear
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
     
   always @ (posedge direction_set or posedge direction_clr)
     if (direction_clr)
       direction <= going_empty;
     else
       direction <= going_full;

   assign async_empty = (wptr == rptr) && (direction==going_empty);
   assign async_full  = (wptr == rptr) && (direction==going_full);

   always @ (posedge wclk or posedge rst or posedge async_full)
     if (rst)
       {fifo_full, fifo_full2} <= 2'b00;
     else if (async_full)
       {fifo_full, fifo_full2} <= 2'b11;
     else
       {fifo_full, fifo_full2} <= {fifo_full2, async_full};

   always @ (posedge rclk or posedge async_empty)
     if (async_empty)
       {fifo_empty, fifo_empty2} <= 2'b11;
     else
       {fifo_empty,fifo_empty2} <= {fifo_empty2,async_empty};   
   
endmodule // async_comp
module vfifo_dual_port_ram_dc_dw
  (
   d_a,
   q_a,
   adr_a, 
   we_a,
   clk_a,
   q_b,
   adr_b,
   d_b, 
   we_b,
   clk_b
   );
   parameter DATA_WIDTH = 36;
   parameter ADDR_WIDTH = 8;
   input [(DATA_WIDTH-1):0]      d_a;
   input [(ADDR_WIDTH-1):0] 	 adr_a;
   input [(ADDR_WIDTH-1):0] 	 adr_b;
   input 			 we_a;
   output [(DATA_WIDTH-1):0] 	 q_b;
   input [(DATA_WIDTH-1):0] 	 d_b;
   output reg [(DATA_WIDTH-1):0] q_a;
   input 			 we_b;
   input 			 clk_a, clk_b;
   reg [(DATA_WIDTH-1):0] 	 q_b;   
   reg [DATA_WIDTH-1:0] ram [(1<<ADDR_WIDTH)-1:0] ;
   always @ (posedge clk_a)
     begin 
	q_a <= ram[adr_a];
	if (we_a)
	     ram[adr_a] <= d_a;
     end 
   always @ (posedge clk_b)
     begin 
	  q_b <= ram[adr_b];
	if (we_b)
	  ram[adr_b] <= d_b;
     end
endmodule 
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Versatile memory controller                                 ////
////                                                              ////
////  Description                                                 ////
////  A modular wishbone compatible memory controller with support////
////  for various types of memory configurations                  ////
////                                                              ////
////  To Do:                                                      ////
////   - add support for additional SDRAM variants                ////
////                                                              ////
////  Author(s):                                                  ////
////      - Michael Unneback, unneback@opencores.org              ////
////        ORSoC AB                                              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2009 Authors and OPENCORES.ORG                 ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
module fifo_adr_counter
  (
    output reg [5:1] q,
    output [5:1]    q_bin,
    input cke,
    input clk,
    input rst
   );
   reg [5:1] qi;
   wire [5:1] q_next;   
   assign q_next =
   qi + 5'd1;
   always @ (posedge clk or posedge rst)
     if (rst)
       qi <= 5'd0;
     else
   if (cke)
     qi <= q_next;
   always @ (posedge clk or posedge rst)
     if (rst)
       q <= 5'h0;
     else
       if (cke)
	 q <= (q_next>>1) ^ q_next;
   assign q_bin = qi;
endmodule
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Versatile memory controller                                 ////
////                                                              ////
////  Description                                                 ////
////  A modular wishbone compatible memory controller with support////
////  for various types of memory configurations                  ////
////                                                              ////
////  To Do:                                                      ////
////   - add support for additional SDRAM variants                ////
////                                                              ////
////  Author(s):                                                  ////
////      - Michael Unneback, unneback@opencores.org              ////
////        ORSoC AB                                              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2009 Authors and OPENCORES.ORG                 ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
module ctrl_counter
  (
    input clear,
    input cke,
    output reg zq,
    input clk,
    input rst
   );
   parameter wrap_value = 5'h1f;
   reg [5:1] qi;
   wire [5:1] q_next;   
   assign q_next =
       clear ? 5'd0 :
	   (qi == wrap_value) ? 5'd0 :
	     {qi[4:1],~(qi[5]^qi[1])};
   always @ (posedge clk or posedge rst)
     if (rst)
       qi <= 5'd0;
     else
   if (cke)
     qi <= q_next;
   always @ (posedge clk or posedge rst)
     if (rst)
       zq <= 1'b1;
     else
       if (cke)
	 zq <= q_next == 5'd0;
endmodule
`include "versatile_mem_ctrl_defines.v"

module fifo
  (
   // A side
   input [35:0]  a_dat_i,
   input 	 a_we_i,
   input  [2:0]  a_fifo_sel_i,
   output [7:0]  a_fifo_full_o,
   input 	 a_clk,
   // B side
   output [35:0] b_dat_o,
   input 	 b_re_i,
   input [2:0]   b_fifo_sel_i,
   output [7:0]  b_fifo_empty_o,
   input 	 b_clk,
   // Common
   input 	 rst 	 
   );

   wire [4:0] 	 wadr0, radr0;
   wire [4:0]	 wadr1, radr1;
   wire [4:0]	 wadr2, radr2;
   wire [4:0]	 wadr3, radr3;
   wire [4:0]	 wadr4, radr4;
   wire [4:0]	 wadr5, radr5;
   wire [4:0]	 wadr6, radr6;
   wire [4:0]	 wadr7, radr7;
   
`ifdef PORT0
   wire [4:0] 	 wptr0, rptr0;
`endif
`ifdef PORT1
   wire [4:0] 	 wptr1, rptr1;
`endif
`ifdef PORT2
   wire [4:0] 	 wptr2, rptr2;
`endif
`ifdef PORT3
   wire [4:0] 	 wptr3, rptr3;
`endif
`ifdef PORT4
   wire [4:0] 	 wptr4, rptr4;
`endif
`ifdef PORT5
   wire [4:0] 	 wptr5, rptr5;
`endif
`ifdef PORT6
   wire [4:0] 	 wptr6, rptr6;
`endif
`ifdef PORT7
   wire [4:0] 	 wptr7, rptr7;
`endif
   
   wire [7:0] 	 dpram_a_a, dpram_a_b;   

   // WB#0
`ifdef PORT0
   fifo_adr_counter wptr0_cnt
     (
      .q(wptr0),
      .q_bin(wadr0),
      .cke(a_we_i & (a_fifo_sel_i==3'h0)),
      .clk(a_clk),
      .rst(rst)
      );

   fifo_adr_counter rptr0_cnt
     (
      .q(rptr0),
      .q_bin(radr0),
      .cke(b_re_i & (b_fifo_sel_i==3'h0)),
      .clk(b_clk),
      .rst(rst)
      );

  versatile_fifo_async_cmp
    #
    (
     .ADDR_WIDTH(5)
     )
    cmp0
    ( 
      .wptr(wptr0), 
      .rptr(rptr0), 
      .fifo_empty(b_fifo_empty_o[0]), 
      .fifo_full(a_fifo_full_o[0]), 
      .wclk(a_clk), 
      .rclk(b_clk), 
      .rst(rst)
      );
`else // !`ifdef PORT0
   assign wptr0 = 5'h0;
   assign wadr0 = 5'h0;
   assign rptr0 = 5'h0;
   assign radr0 = 5'h0;
   assign a_fifo_full_o[0] = 1'b0;
   assign b_fifo_empty_o[0] = 1'b1;
`endif // !`ifdef PORT0
   
   // WB#1
`ifdef PORT1
   fifo_adr_counter wptr1_cnt
     (
      .q(wptr1),
      .q_bin(wadr1),
      .cke(a_we_i & (a_fifo_sel_i==3'h1)),
      .clk(a_clk),
      .rst(rst)
      );

   fifo_adr_counter rptr1_cnt
     (
      .q(rptr1),
      .q_bin(radr1),
      .cke(b_re_i & (b_fifo_sel_i==3'h1)),
      .clk(b_clk),
      .rst(rst)
      );

  versatile_fifo_async_cmp
    #
    (
     .ADDR_WIDTH(5)
     )
    cmp1
    ( 
      .wptr(wptr1), 
      .rptr(rptr1), 
      .fifo_empty(b_fifo_empty_o[1]), 
      .fifo_full(a_fifo_full_o[1]), 
      .wclk(a_clk), 
      .rclk(b_clk), 
      .rst(rst)
      );
`else // !`ifdef PORT1
   assign wptr1 = 5'h0;
   assign wadr1 = 5'h0;
   assign rptr1 = 5'h0;
   assign radr1 = 5'h0;
   assign a_fifo_full_o[1] = 1'b0;
   assign b_fifo_empty_o[1] = 1'b1;
`endif // !`ifdef PORT1
   
   // WB#2
`ifdef PORT2
   fifo_adr_counter wptr2_cnt
     (
      .q(wptr2),
      .q_bin(wadr2),
      .cke(a_we_i & (a_fifo_sel_i==3'h2)),
      .clk(a_clk),
      .rst(rst)
      );

   fifo_adr_counter rptr2_cnt
     (
      .q(rptr2),
      .q_bin(radr2),
      .cke(b_re_i & (b_fifo_sel_i==3'h2)),
      .clk(b_clk),
      .rst(rst)
      );

  versatile_fifo_async_cmp
    #
    (
     .ADDR_WIDTH(5)
     )
    cmp2
    ( 
      .wptr(wptr2), 
      .rptr(rptr2), 
      .fifo_empty(b_fifo_empty_o[2]), 
      .fifo_full(a_fifo_full_o[2]), 
      .wclk(a_clk), 
      .rclk(b_clk), 
      .rst(rst)
      );
`else // !`ifdef PORT2
   assign wptr2 = 5'h0;
   assign wadr2 = 5'h0;
   assign rptr2 = 5'h0;
   assign radr2 = 5'h0;
   assign a_fifo_full_o[2] = 1'b0;
   assign b_fifo_empty_o[2] = 1'b1;
`endif // !`ifdef PORT2
   
   // WB#3
`ifdef PORT3
   fifo_adr_counter wptr3_cnt
     (
      .q(wptr3),
      .q_bin(wadr3),
      .cke(a_we_i & (a_fifo_sel_i==3'h3)),
      .clk(a_clk),
      .rst(rst)
      );

   fifo_adr_counter rptr3_cnt
     (
      .q(rptr3),
      .q_bin(radr3),
      .cke(b_re_i & (b_fifo_sel_i==3'h3)),
      .clk(b_clk),
      .rst(rst)
      );

  versatile_fifo_async_cmp
    #
    (
     .ADDR_WIDTH(5)
     )
    cmp3
    ( 
      .wptr(wptr3), 
      .rptr(rptr3), 
      .fifo_empty(b_fifo_empty_o[3]), 
      .fifo_full(a_fifo_full_o[3]), 
      .wclk(a_clk), 
      .rclk(b_clk), 
      .rst(rst)
      );
`else // !`ifdef PORT3
   assign wptr3 = 5'h0;
   assign wadr3 = 5'h0;
   assign rptr3 = 5'h0;
   assign radr3 = 5'h0;
   assign a_fifo_full_o[3] = 1'b0;
   assign b_fifo_empty_o[3] = 1'b1;
`endif // !`ifdef PORT3
   
   // WB#4
`ifdef PORT4
   fifo_adr_counter wptr4_cnt
     (
      .q(wptr4),
      .q_bin(wadr4),
      .cke(a_we_i & (a_fifo_sel_i==3'h4)),
      .clk(a_clk),
      .rst(rst)
      );

   fifo_adr_counter rptr4_cnt
     (
      .q(rptr4),
      .q_bin(radr4),
      .cke(b_re_i & (b_fifo_sel_i==3'h4)),
      .clk(b_clk),
      .rst(rst)
      );

  versatile_fifo_async_cmp
    #
    (
     .ADDR_WIDTH(5)
     )
    cmp4
    ( 
      .wptr(wptr4), 
      .rptr(rptr4), 
      .fifo_empty(b_fifo_empty_o[4]), 
      .fifo_full(a_fifo_full_o[4]), 
      .wclk(a_clk), 
      .rclk(b_clk), 
      .rst(rst)
      );
`else // !`ifdef PORT4
   assign wptr4 = 5'h0;
   assign wadr4 = 5'h0;
   assign rptr4 = 5'h0;
   assign radr4 = 5'h0;
   assign a_fifo_full_o[4] = 1'b0;
   assign b_fifo_empty_o[4] = 1'b1;
`endif // !`ifdef PORT4
   
   // WB#5
`ifdef PORT5
   fifo_adr_counter wptr5_cnt
     (
      .q(wptr5),
      .q_bin(wadr5),
      .cke(a_we_i & (a_fifo_sel_i==3'h5)),
      .clk(a_clk),
      .rst(rst)
      );

   fifo_adr_counter rptr5_cnt
     (
      .q(rptr5),
      .q_bin(radr5),
      .cke(b_re_i & (b_fifo_sel_i==3'h5)),
      .clk(b_clk),
      .rst(rst)
      );

  versatile_fifo_async_cmp
    #
    (
     .ADDR_WIDTH(5)
     )
    cmp5
    ( 
      .wptr(wptr5), 
      .rptr(rptr5), 
      .fifo_empty(b_fifo_empty_o[5]), 
      .fifo_full(a_fifo_full_o[5]), 
      .wclk(a_clk), 
      .rclk(b_clk), 
      .rst(rst)
      );
`else // !`ifdef PORT5
   assign wptr5 = 5'h0;
   assign wadr5 = 5'h0;
   assign rptr5 = 5'h0;
   assign radr5 = 5'h0;
   assign a_fifo_full_o[5] = 1'b0;
   assign b_fifo_empty_o[5] = 1'b1;
`endif // !`ifdef PORT5
   
   // WB#6
`ifdef PORT6
   fifo_adr_counter wptr6_cnt
     (
      .q(wptr6),
      .q_bin(wadr6),
      .cke(a_we_i & (a_fifo_sel_i==3'h6)),
      .clk(a_clk),
      .rst(rst)
      );

   fifo_adr_counter rptr6_cnt
     (
      .q(rptr6),
      .q_bin(radr6),
      .cke(b_re_i & (b_fifo_sel_i==3'h6)),
      .clk(b_clk),
      .rst(rst)
      );

  versatile_fifo_async_cmp
    #
    (
     .ADDR_WIDTH(5)
     )
    cmp6
    ( 
      .wptr(wptr6), 
      .rptr(rptr6), 
      .fifo_empty(b_fifo_empty_o[6]), 
      .fifo_full(a_fifo_full_o[6]), 
      .wclk(a_clk), 
      .rclk(b_clk), 
      .rst(rst)
      );
`else // !`ifdef PORT6
   assign wptr6 = 5'h0;
   assign wadr6 = 5'h0;
   assign rptr6 = 5'h0;
   assign radr6 = 5'h0;
   assign a_fifo_full_o[6] = 1'b0;
   assign b_fifo_empty_o[6] = 1'b1;
`endif // !`ifdef PORT6
   
   // WB#7
`ifdef PORT7
   fifo_adr_counter wptr7_cnt
     (
      .q(wptr7),
      .q_bin(wadr7),
      .cke(a_we_i & (a_fifo_sel_i==3'h7)),
      .clk(a_clk),
      .rst(rst)
      );

   fifo_adr_counter rptr7_cnt
     (
      .q(rptr7),
      .q_bin(radr7),
      .cke(b_re_i & (b_fifo_sel_i==3'h7)),
      .clk(b_clk),
      .rst(rst)
      );

  versatile_fifo_async_cmp
    #
    (
     .ADDR_WIDTH(5)
     )
    cmp7
    ( 
      .wptr(wptr7), 
      .rptr(rptr7), 
      .fifo_empty(b_fifo_empty_o[7]), 
      .fifo_full(a_fifo_full_o[7]), 
      .wclk(a_clk), 
      .rclk(b_clk), 
      .rst(rst)
      );
`else // !`ifdef PORT7
   assign wptr7 = 5'h0;
   assign wadr7 = 5'h0;
   assign rptr7 = 5'h0;
   assign radr7 = 5'h0;
   assign a_fifo_full_o[7] = 1'b0;
   assign b_fifo_empty_o[7] = 1'b1;
`endif // !`ifdef PORT7
   
   assign dpram_a_a = (a_fifo_sel_i==3'd0) ? {a_fifo_sel_i,wadr0} :
		      (a_fifo_sel_i==3'd1) ? {a_fifo_sel_i,wadr1} :
		      (a_fifo_sel_i==3'd2) ? {a_fifo_sel_i,wadr2} :
		      (a_fifo_sel_i==3'd3) ? {a_fifo_sel_i,wadr3} :
		      (a_fifo_sel_i==3'd4) ? {a_fifo_sel_i,wadr4} :
		      (a_fifo_sel_i==3'd5) ? {a_fifo_sel_i,wadr5} :
		      (a_fifo_sel_i==3'd6) ? {a_fifo_sel_i,wadr6} :
		                             {a_fifo_sel_i,wadr7} ;

   assign dpram_a_b = (b_fifo_sel_i==3'd0) ? {b_fifo_sel_i,radr0} :
		      (b_fifo_sel_i==3'd1) ? {b_fifo_sel_i,radr1} :
		      (b_fifo_sel_i==3'd2) ? {b_fifo_sel_i,radr2} :
		      (b_fifo_sel_i==3'd3) ? {b_fifo_sel_i,radr3} :
		      (b_fifo_sel_i==3'd4) ? {b_fifo_sel_i,radr4} :
		      (b_fifo_sel_i==3'd5) ? {b_fifo_sel_i,radr5} :
		      (b_fifo_sel_i==3'd6) ? {b_fifo_sel_i,radr6} :
		                             {b_fifo_sel_i,radr7} ;
		      

`ifdef ACTEL
   TwoPortRAM_256x36 dpram
     (
      .WD(a_dat_i),
      .RD(b_dat_o),
      .WEN(a_we_i),
      //.REN(b_re_i),
      .REN(1'b1),
      .WADDR(dpram_a_a),
      .RADDR(dpram_a_b),
      .WCLK(a_clk),
      .RCLK(b_clk)
      );   
`else		        
   vfifo_dual_port_ram_dc_dw
/*     #
     (
      .ADDR_WIDTH(8),
      .DATA_WIDTH(36)
      )*/
     dpram
     (
      .d_a(a_dat_i),
      .q_a(),
      .adr_a(dpram_a_a), 
      .we_a(a_we_i),
      .clk_a(a_clk),
      .q_b(b_dat_o),
      .adr_b(dpram_a_b),
      .d_b(36'h0), 
      .we_b(1'b0),
      .clk_b(b_clk)
      );
`endif
endmodule // sd_fifo
`define EOB (!(|cti) | &cti)
module fifo_fill (
  output reg wbs_flag,
  output reg we_req,
  input wire ack,
  input wire [1:0] bte,
  input wire clk,
  input wire [2:0] cti,
  input wire cyc,
  input wire rst,
  input wire stb,
  input wire we,
  input wire we_ack 
);
  
  
  

  // state bits
  parameter 
  idle    = 13, 
  state1  = 11, 
  state10 = 15, 
  state11 = 8, 
  state12 = 10, 
  state13 = 1, 
  state14 = 3, 
  state15 = 14, 
  state16 = 6, 
  state2  = 5, 
  state3  = 4, 
  state4  = 7, 
  state5  = 2, 
  state6  = 12, 
  state7  = 16, 
  state8  = 0, 
  state9  = 9; 
  
  reg [16:0] state;
  reg [16:0] nextstate;
  
  // comb always block
  always @* begin
    nextstate = 17'b00000000000000000;
    wbs_flag = 1'b0; // default
    we_req = we & stb; // default
    case (1'b1) // synopsys parallel_case full_case
      state[idle]   : begin
        wbs_flag = 1'b1;
        we_req = cyc & stb;
        if (cyc & stb & we_ack) begin
          nextstate[state1] = 1'b1;
        end
        else begin
          nextstate[idle] = 1'b1; // Added because implied_loopback is true
        end
      end
      state[state1] : begin
        if (`EOB & ack) begin
          nextstate[idle] = 1'b1;
        end
        else if (ack) begin
          nextstate[state2] = 1'b1;
        end
        else begin
          nextstate[state1] = 1'b1; // Added because implied_loopback is true
        end
      end
      state[state10]: begin
        if (`EOB & ack) begin
          nextstate[idle] = 1'b1;
        end
        else if (ack) begin
          nextstate[state11] = 1'b1;
        end
        else begin
          nextstate[state10] = 1'b1; // Added because implied_loopback is true
        end
      end
      state[state11]: begin
        if (`EOB & ack) begin
          nextstate[idle] = 1'b1;
        end
        else if (ack) begin
          nextstate[state12] = 1'b1;
        end
        else begin
          nextstate[state11] = 1'b1; // Added because implied_loopback is true
        end
      end
      state[state12]: begin
        if (`EOB & ack) begin
          nextstate[idle] = 1'b1;
        end
        else if (ack) begin
          nextstate[state13] = 1'b1;
        end
        else begin
          nextstate[state12] = 1'b1; // Added because implied_loopback is true
        end
      end
      state[state13]: begin
        if (`EOB & ack) begin
          nextstate[idle] = 1'b1;
        end
        else if (ack) begin
          nextstate[state14] = 1'b1;
        end
        else begin
          nextstate[state13] = 1'b1; // Added because implied_loopback is true
        end
      end
      state[state14]: begin
        if (`EOB & ack) begin
          nextstate[idle] = 1'b1;
        end
        else if (ack) begin
          nextstate[state15] = 1'b1;
        end
        else begin
          nextstate[state14] = 1'b1; // Added because implied_loopback is true
        end
      end
      state[state15]: begin
        if (`EOB & ack) begin
          nextstate[idle] = 1'b1;
        end
        else if (ack) begin
          nextstate[state16] = 1'b1;
        end
        else begin
          nextstate[state15] = 1'b1; // Added because implied_loopback is true
        end
      end
      state[state16]: begin
        if (ack) begin
          nextstate[idle] = 1'b1;
        end
        else begin
          nextstate[state16] = 1'b1; // Added because implied_loopback is true
        end
      end
      state[state2] : begin
        if (`EOB & ack) begin
          nextstate[idle] = 1'b1;
        end
        else if (ack) begin
          nextstate[state3] = 1'b1;
        end
        else begin
          nextstate[state2] = 1'b1; // Added because implied_loopback is true
        end
      end
      state[state3] : begin
        if (`EOB & ack) begin
          nextstate[idle] = 1'b1;
        end
        else if (ack) begin
          nextstate[state4] = 1'b1;
        end
        else begin
          nextstate[state3] = 1'b1; // Added because implied_loopback is true
        end
      end
      state[state4] : begin
        if (`EOB & ack) begin
          nextstate[idle] = 1'b1;
        end
        else if ((bte==2'b01) & ack) begin
          nextstate[idle] = 1'b1;
        end
        else if (ack) begin
          nextstate[state5] = 1'b1;
        end
        else begin
          nextstate[state4] = 1'b1; // Added because implied_loopback is true
        end
      end
      state[state5] : begin
        if (`EOB & ack) begin
          nextstate[idle] = 1'b1;
        end
        else if (ack) begin
          nextstate[state6] = 1'b1;
        end
        else begin
          nextstate[state5] = 1'b1; // Added because implied_loopback is true
        end
      end
      state[state6] : begin
        if (`EOB & ack) begin
          nextstate[idle] = 1'b1;
        end
        else if (ack) begin
          nextstate[state7] = 1'b1;
        end
        else begin
          nextstate[state6] = 1'b1; // Added because implied_loopback is true
        end
      end
      state[state7] : begin
        if (`EOB & ack) begin
          nextstate[idle] = 1'b1;
        end
        else if (ack) begin
          nextstate[state8] = 1'b1;
        end
        else begin
          nextstate[state7] = 1'b1; // Added because implied_loopback is true
        end
      end
      state[state8] : begin
        if (`EOB & ack) begin
          nextstate[idle] = 1'b1;
        end
        else if ((bte==2'b10) & ack) begin
          nextstate[idle] = 1'b1;
        end
        else if (ack) begin
          nextstate[state9] = 1'b1;
        end
        else begin
          nextstate[state8] = 1'b1; // Added because implied_loopback is true
        end
      end
      state[state9] : begin
        if (`EOB & ack) begin
          nextstate[idle] = 1'b1;
        end
        else if (ack) begin
          nextstate[state10] = 1'b1;
        end
        else begin
          nextstate[state9] = 1'b1; // Added because implied_loopback is true
        end
      end
    endcase
  end
  
  // sequential always block
  always @(posedge clk or posedge rst) begin
    if (rst)
      state <= 17'b00000000000000001 << idle;
    else
      state <= nextstate;
  end
  
  // This code allows you to see state names in simulation
  `ifndef SYNTHESIS
  reg [55:0] statename;
  always @* begin
    case (1)
      state[idle]   :
        statename = "idle";
      state[state1] :
        statename = "state1";
      state[state10]:
        statename = "state10";
      state[state11]:
        statename = "state11";
      state[state12]:
        statename = "state12";
      state[state13]:
        statename = "state13";
      state[state14]:
        statename = "state14";
      state[state15]:
        statename = "state15";
      state[state16]:
        statename = "state16";
      state[state2] :
        statename = "state2";
      state[state3] :
        statename = "state3";
      state[state4] :
        statename = "state4";
      state[state5] :
        statename = "state5";
      state[state6] :
        statename = "state6";
      state[state7] :
        statename = "state7";
      state[state8] :
        statename = "state8";
      state[state9] :
        statename = "state9";
      default:
        statename = "XXXXXXX";
    endcase
  end
  `endif

  
endmodule

module inc_adr
  (
   input  [3:0] adr_i,
   input  [2:0] cti_i,
   input  [1:0] bte_i,
   input  init,
   input  inc,
   output reg [3:0] adr_o,
   output reg done,
   input clk,
   input rst
   );

   reg 	 init_i;
   
   reg [1:0] bte;
   reg [3:0] cnt;

   // delay init one clock cycle to be able to read from mem
   always @ (posedge clk or posedge rst)
     if (rst)
       init_i <= 1'b0;
     else
       init_i <= init;
   
   // bte
   always @ (posedge clk or posedge rst)
     if (rst)
       bte <= 2'b00;
     else
       if (init_i)
	 bte <= bte_i;

   // adr_o
   always @ (posedge clk or posedge rst)
     if (rst)
       adr_o <= 4'd0;
     else
       if (init_i)
	 adr_o <= adr_i;
       else
	 if (inc)
	   case (bte)
	     2'b01: adr_o <= {adr_o[3:2], adr_o[1:0] + 2'd1};
	     2'b10: adr_o <= {adr_o[3], adr_o[2:0] + 3'd1};
	     default: adr_o <= adr_o + 4'd1;
	   endcase // case (bte)
   
   
   // done
   always @ (posedge clk or posedge rst)
     if (rst)
       {done,cnt} <= {1'b0,4'd0};
     else
       if (init_i)
	 begin
	    done <= ({bte_i,cti_i} == {2'b00,3'b000});
	    case (bte_i)
	      2'b01: cnt <= 4'd12;
	      2'b10: cnt <= 4'd8;
	      2'b11: cnt <= 4'd0;
	      default: cnt <= adr_i;
	    endcase
	 end
       else
	 if (inc)
	   {done,cnt} <= cnt + 4'd1;

endmodule // inc_adr

   //////////////////////////////////////////////////////////////////////
////                                                              ////
////  Versatile memory controller                                 ////
////                                                              ////
////  Description                                                 ////
////  A modular wishbone compatible memory controller with support////
////  for various types of memory configurations                  ////
////                                                              ////
////  To Do:                                                      ////
////   - add support for additional SDRAM variants                ////
////                                                              ////
////  Author(s):                                                  ////
////      - Michael Unneback, unneback@opencores.org              ////
////        ORSoC AB                                              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2009 Authors and OPENCORES.ORG                 ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
module ref_counter
  (
    output reg zq,
    input clk,
    input rst
   );
   parameter wrap_value = 10'h287;
   reg [10:1] qi;
   wire [10:1] q_next;   
   assign q_next =
	   (qi == wrap_value) ? 10'd0 :
	     {qi[9:1],~(qi[10]^qi[7])};
   always @ (posedge clk or posedge rst)
     if (rst)
       qi <= 10'd0;
     else
     qi <= q_next;
   always @ (posedge clk or posedge rst)
     if (rst)
       zq <= 1'b1;
     else
	 zq <= q_next == 10'd0;
endmodule
 `timescale 1ns/1ns
module sdr_16 (
  output reg [14:0] a,
  output reg adr_inc,
  output reg adr_init,
  output reg [2:0] cmd,
  output reg cs_n,
  output reg [15:0] dq,
  output reg dq_oe,
  output reg [1:0] dqm,
  output reg fifo_re,
  output reg read,
  output reg ref_ack,
  input wire [3:0] burst_adr,
  input wire done,
  input wire [7:0] fifo_empty,
  input wire [2:0] fifo_sel,
  input wire ref_req,
  input wire sdram_clk,
  input wire [35:0] tx_fifo_dat_o,
  input wire wb_rst 
);
  parameter 
  IDLE      = 18, 
  ACT_ROW   = 14, 
  AREF      = 13, 
  ARF1      = 17, 
  ARF2      = 20, 
  AWAIT_CMD = 12, 
  LMR       = 5, 
  NOP1      = 1, 
  NOP10     = 10, 
  NOP2      = 15, 
  NOP3      = 16, 
  NOP4      = 11, 
  NOP5      = 9, 
  NOP6      = 7, 
  NOP7      = 2, 
  NOP8      = 0, 
  NOP9      = 8, 
  PRE       = 6, 
  PRECHARGE = 19, 
  READ      = 4, 
  WRITE     = 3; 
  reg [20:0] state;
  reg [20:0] nextstate;
  always @* begin
    nextstate = 21'b000000000000000000000;
    adr_inc = 1'b0; 
    adr_init = 1'b0; 
    fifo_re = 1'b0; 
    ref_ack = 1'b0; 
    case (1'b1) 
      state[IDLE]     : begin
        begin
          nextstate[PRE] = 1'b1;
        end
      end
      state[ACT_ROW]  : begin
        fifo_re = 1'b1;
        if (tx_fifo_dat_o[5]) begin
          nextstate[NOP9] = 1'b1;
        end
        else begin
          nextstate[NOP4] = 1'b1;
        end
      end
      state[AREF]     : begin
        ref_ack = 1'b1;
        begin
          nextstate[AWAIT_CMD] = 1'b1;
        end
      end
      state[ARF1]     : begin
        ref_ack = 1'b1;
        begin
          nextstate[NOP2] = 1'b1;
        end
      end
      state[ARF2]     : begin
        ref_ack = 1'b1;
        begin
          nextstate[NOP3] = 1'b1;
        end
      end
      state[AWAIT_CMD]: begin
        adr_init = !(&fifo_empty);
        if (ref_req) begin
          nextstate[AREF] = 1'b1;
        end
        else if (!(&fifo_empty)) begin
          nextstate[ACT_ROW] = 1'b1;
        end
        else begin
          nextstate[AWAIT_CMD] = 1'b1; 
        end
      end
      state[LMR]      : begin
        ref_ack = 1'b1;
        begin
          nextstate[AWAIT_CMD] = 1'b1;
        end
      end
      state[NOP1]     : begin
        if (ref_req) begin
          nextstate[ARF1] = 1'b1;
        end
        else begin
          nextstate[NOP1] = 1'b1; 
        end
      end
      state[NOP10]    : begin
        adr_init = 1'b1;
        begin
          nextstate[PRECHARGE] = 1'b1;
        end
      end
      state[NOP2]     : begin
        if (ref_req) begin
          nextstate[ARF2] = 1'b1;
        end
        else begin
          nextstate[NOP2] = 1'b1; 
        end
      end
      state[NOP3]     : begin
        if (ref_req) begin
          nextstate[LMR] = 1'b1;
        end
        else begin
          nextstate[NOP3] = 1'b1; 
        end
      end
      state[NOP4]     : begin
        begin
          nextstate[NOP8] = 1'b1;
        end
      end
      state[NOP5]     : begin
        if (!fifo_empty[fifo_sel]) begin
          nextstate[WRITE] = 1'b1;
        end
        else begin
          nextstate[NOP5] = 1'b1; 
        end
      end
      state[NOP6]     : begin
        if (done) begin
          nextstate[NOP10] = 1'b1;
        end
        else begin
          nextstate[READ] = 1'b1;
        end
      end
      state[NOP7]     : begin
        adr_inc = !done & !fifo_empty[fifo_sel];
        fifo_re = !done & !fifo_empty[fifo_sel];
        if (done) begin
          nextstate[NOP10] = 1'b1;
        end
        else if (!fifo_empty[fifo_sel]) begin
          nextstate[WRITE] = 1'b1;
        end
        else begin
          nextstate[NOP7] = 1'b1; 
        end
      end
      state[NOP8]     : begin
        begin
          nextstate[READ] = 1'b1;
        end
      end
      state[NOP9]     : begin
        begin
          nextstate[NOP5] = 1'b1;
        end
      end
      state[PRE]      : begin
        ref_ack = 1'b1;
        begin
          nextstate[NOP1] = 1'b1;
        end
      end
      state[PRECHARGE]: begin
        begin
          nextstate[AWAIT_CMD] = 1'b1;
        end
      end
      state[READ]     : begin
        adr_inc = !done;
        begin
          nextstate[NOP6] = 1'b1;
        end
      end
      state[WRITE]    : begin
        fifo_re = 1'b1;
        begin
          nextstate[NOP7] = 1'b1;
        end
      end
    endcase
  end
  always @(posedge sdram_clk or posedge wb_rst) begin
    if (wb_rst)
      state <= 21'b000000000000000000001 << IDLE;
    else
      state <= nextstate;
  end
  always @(posedge sdram_clk or posedge wb_rst) begin
    if (wb_rst) begin
      a[14:0] <= 15'd0;
      cmd[2:0] <= 3'b111;
      cs_n <= 1'b1;
      dq[15:0] <= 16'h0000;
      dq_oe <= 1'b0;
      dqm[1:0] <= 2'b11;
      read <= 1'b0;
    end
    else begin
      a[14:0] <= 15'd0; 
      cmd[2:0] <= 3'b111; 
      cs_n <= 1'b0; 
      dq[15:0] <= 16'h0000; 
      dq_oe <= 1'b0; 
      dqm[1:0] <= 2'b11; 
      read <= 1'b0; 
      case (1'b1) 
        nextstate[IDLE]     : begin
          cs_n <= 1'b1;
        end
        nextstate[ACT_ROW]  : begin
          a[14:0] <= {tx_fifo_dat_o[28:27],tx_fifo_dat_o[26:14]};
          cmd[2:0] <= 3'b011;
        end
        nextstate[AREF]     : begin
          a[14:0] <= a;
          cmd[2:0] <= 3'b001;
        end
        nextstate[ARF1]     : begin
          a[14:0] <= a;
          cmd[2:0] <= 3'b001;
        end
        nextstate[ARF2]     : begin
          a[14:0] <= a;
          cmd[2:0] <= 3'b001;
        end
        nextstate[AWAIT_CMD]: begin
          a[14:0] <= a;
          cs_n <= 1'b1;
        end
        nextstate[LMR]      : begin
          a[14:0] <= {2'b00,3'b000,1'b0,2'b00,3'd2,1'b0,3'b001};
          cmd[2:0] <= 3'b000;
        end
        nextstate[NOP1]     : begin
          a[14:0] <= a;
        end
        nextstate[NOP10]    : begin
          a[14:0] <= a;
        end
        nextstate[NOP2]     : begin
          a[14:0] <= a;
        end
        nextstate[NOP3]     : begin
          a[14:0] <= a;
        end
        nextstate[NOP4]     : begin
          a[14:0] <= {tx_fifo_dat_o[28:27],{4'b0000,tx_fifo_dat_o[13:10],burst_adr,1'b0}};
        end
        nextstate[NOP5]     : begin
          a[14:0] <= a;
        end
        nextstate[NOP6]     : begin
          a[14:0] <= a;
          dqm[1:0] <= 2'b00;
        end
        nextstate[NOP7]     : begin
          a[14:0] <= a;
          dq[15:0] <= tx_fifo_dat_o[19:4];
          dq_oe <= 1'b1;
          dqm[1:0] <= !tx_fifo_dat_o[1:0];
        end
        nextstate[NOP8]     : begin
          a[14:0] <= a;
        end
        nextstate[NOP9]     : begin
          a[14:0] <= {tx_fifo_dat_o[28:27],{4'b0000,tx_fifo_dat_o[13:10],burst_adr,1'b0}};
        end
        nextstate[PRE]      : begin
          a[14:0] <= {2'b00,13'b0010000000000};
          cmd[2:0] <= 3'b010;
        end
        nextstate[PRECHARGE]: begin
          a[14:0] <= {2'b00,13'b0010000000000};
          cmd[2:0] <= 3'b010;
        end
        nextstate[READ]     : begin
          a[14:0] <= {a[14:5],burst_adr,1'b0};
          cmd[2:0] <= 3'b101;
          dqm[1:0] <= 2'b00;
          read <= 1'b1;
        end
        nextstate[WRITE]    : begin
          a[14:0] <= {a[14:5],burst_adr,1'b0};
          cmd[2:0] <= 3'b100;
          dq[15:0] <= tx_fifo_dat_o[35:20];
          dq_oe <= 1'b1;
          dqm[1:0] <= !tx_fifo_dat_o[3:2];
        end
      endcase
    end
  end
  reg [71:0] statename;
  always @* begin
    case (1)
      state[IDLE]     :
        statename = "IDLE";
      state[ACT_ROW]  :
        statename = "ACT_ROW";
      state[AREF]     :
        statename = "AREF";
      state[ARF1]     :
        statename = "ARF1";
      state[ARF2]     :
        statename = "ARF2";
      state[AWAIT_CMD]:
        statename = "AWAIT_CMD";
      state[LMR]      :
        statename = "LMR";
      state[NOP1]     :
        statename = "NOP1";
      state[NOP10]    :
        statename = "NOP10";
      state[NOP2]     :
        statename = "NOP2";
      state[NOP3]     :
        statename = "NOP3";
      state[NOP4]     :
        statename = "NOP4";
      state[NOP5]     :
        statename = "NOP5";
      state[NOP6]     :
        statename = "NOP6";
      state[NOP7]     :
        statename = "NOP7";
      state[NOP8]     :
        statename = "NOP8";
      state[NOP9]     :
        statename = "NOP9";
      state[PRE]      :
        statename = "PRE";
      state[PRECHARGE]:
        statename = "PRECHARGE";
      state[READ]     :
        statename = "READ";
      state[WRITE]    :
        statename = "WRITE";
      default  :
        statename = "XXXXXXXXX";
    endcase
  end
endmodule
`timescale 1ns/1ns
module delay
  (
   input  [3:0] d,
   output [3:0] q,
   input        clk,
   input 	rst
   );

   parameter depth = 3;
   reg [3:0] dffs [1:depth];

   integer i;
   
   always @ (posedge clk or posedge rst)
     if (rst)
       for ( i=1; i <= depth; i=i+1)
	 dffs[i] <= 4'h0;
     else
       begin
	  dffs[1] <= d;
	  for ( i=2; i <= depth; i=i+1 )
	    dffs[i] <= dffs[i-1];
       end

   assign q = dffs[depth];   
   
endmodule //delay

   `include "versatile_mem_ctrl_defines.v"
`ifdef SDR_16
 `include "sdr_16_defines.v"
`endif

module wb_sdram_ctrl_top
  (
   // wishbone i/f
`ifdef PORT0
   input  [31:0] wbs0_dat_i,
   output [31:0] wbs0_dat_o,
   input  [31:2] wbs0_adr_i,
   input  [3:0]  wbs0_sel_i,
   input  [2:0]  wbs0_cti_i,
   input  [1:0]  wbs0_bte_i,
   input         wbs0_we_i,
   input         wbs0_cyc_i,
   input         wbs0_stb_i,
   output        wbs0_ack_o,
`endif
`ifdef PORT1
   input  [31:0] wbs1_dat_i,
   output [31:0] wbs1_dat_o,
   input  [31:2] wbs1_adr_i,
   input  [3:0]  wbs1_sel_i,
   input  [2:0]  wbs1_cti_i,
   input  [1:0]  wbs1_bte_i,
   input         wbs1_we_i,
   input         wbs1_cyc_i,
   input         wbs1_stb_i,
   output        wbs1_ack_o,
`endif
`ifdef PORT2
   input  [31:0] wbs2_dat_i,
   output [31:0] wbs2_dat_o,
   input  [31:2] wbs2_adr_i,
   input  [3:0]  wbs2_sel_i,
   input  [2:0]  wbs2_cti_i,
   input  [1:0]  wbs2_bte_i,
   input         wbs2_we_i,
   input         wbs2_cyc_i,
   input         wbs2_stb_i,
   output        wbs2_ack_o,
`endif
`ifdef PORT3
   input  [31:0] wbs3_dat_i,
   output [31:0] wbs3_dat_o,
   input  [31:2] wbs3_adr_i,
   input  [3:0]  wbs3_sel_i,
   input  [2:0]  wbs3_cti_i,
   input  [1:0]  wbs3_bte_i,
   input         wbs3_we_i,
   input         wbs3_cyc_i,
   input         wbs3_stb_i,
   output        wbs3_ack_o,
`endif
`ifdef PORT4
   input  [31:0] wbs4_dat_i,
   output [31:0] wbs4_dat_o,
   input  [31:2] wbs4_adr_i,
   input  [3:0]  wbs4_sel_i,
   input  [2:0]  wbs4_cti_i,
   input  [1:0]  wbs4_bte_i,
   input         wbs4_we_i,
   input         wbs4_cyc_i,
   input         wbs4_stb_i,
   output        wbs4_ack_o,
`endif
`ifdef PORT5
   input  [31:0] wbs5_dat_i,
   output [31:0] wbs5_dat_o,
   input  [31:2] wbs5_adr_i,
   input  [3:0]  wbs5_sel_i,
   input  [2:0]  wbs5_cti_i,
   input  [1:0]  wbs5_bte_i,
   input         wbs5_we_i,
   input         wbs5_cyc_i,
   input         wbs5_stb_i,
   output        wbs5_ack_o,
`endif
`ifdef PORT6
   input  [31:0] wbs6_dat_i,
   output [31:0] wbs6_dat_o,
   input  [31:2] wbs6_adr_i,
   input  [3:0]  wbs6_sel_i,
   input  [2:0]  wbs6_cti_i,
   input  [1:0]  wbs6_bte_i,
   input         wbs6_we_i,
   input         wbs6_cyc_i,
   input         wbs6_stb_i,
   output        wbs6_ack_o,
`endif
`ifdef PORT7
   input  [31:0] wbs7_dat_i,
   output [31:0] wbs7_dat_o,
   input  [31:2] wbs7_adr_i,
   input  [3:0]  wbs7_sel_i,
   input  [2:0]  wbs7_cti_i,
   input  [1:0]  wbs7_bte_i,
   input         wbs7_we_i,
   input         wbs7_cyc_i,
   input         wbs7_stb_i,
   output        wbs7_ack_o,
`endif //  `ifdef PORT7
`ifdef SDR_16
   output [1:0] ba_pad_o,
   output [12:0] a_pad_o,
   output cs_n_pad_o,
   output ras_pad_o,
   output cas_pad_o,
   output we_pad_o,
   output [15:0] dq_o,
   output [1:0] dqm_pad_o,
   input  [15:0] dq_i,
   output dq_oe,
   output cke_pad_o,
`endif
   input wb_clk,
   input wb_rst,
   // SDRAM signals
   input sdram_clk
   );

   wire [35:0] tx_fifo_dat_i, tx_fifo_dat_o;
   wire tx_fifo_we, tx_fifo_re;
   wire [2:0] tx_fifo_a_sel_i, tx_fifo_b_sel_i;
   reg [2:0]  tx_fifo_b_sel_i_cur;
   wire [7:0] tx_fifo_full, tx_fifo_empty;

   wire [35:0] rx_fifo_dat_i, rx_fifo_dat_o;
   wire        rx_fifo_we, rx_fifo_re;
   wire [2:0]  rx_fifo_a_sel_i, rx_fifo_b_sel_i;
   wire [7:0]  rx_fifo_full, rx_fifo_empty;   
   
   wire [3:0] burst_adr;
   wire       adr_init, adr_inc;
   
   wire        ref_zf, ref_ack;
   reg 	       ref_req;
   
`ifdef PORT0
   reg 	       wbs0_ack_re;
`endif
`ifdef PORT1
   reg 	       wbs1_ack_re;
`endif
`ifdef PORT2
   reg 	       wbs2_ack_re;
`endif
`ifdef PORT3
   reg 	       wbs3_ack_re;
`endif
`ifdef PORT4
   reg 	       wbs4_ack_re;
`endif
`ifdef PORT5
   reg 	       wbs5_ack_re;
`endif
`ifdef PORT6
   reg 	       wbs6_ack_re;
`endif
`ifdef PORT7
   reg 	       wbs7_ack_re;
`endif
   
// counters to keep track of fifo fill

`ifdef PORT0
   wire wbs0_flag, we_req0;
   fifo_fill cnt0
     (
      .wbs_flag(wbs0_flag),
      .we_req(we_req0),
      .bte(wbs0_bte_i),
      .cti(wbs0_cti_i),
      .cyc(wbs0_cyc_i),
      .stb(wbs0_stb_i),
      .we(wbs0_we_i),
      .we_ack((tx_fifo_a_sel_i==3'd0) & tx_fifo_we),
      .ack(wbs0_ack_o),
      .clk(wb_clk),
      .rst(wb_rst)
      );
   
   /*
ctrl_counter cnt0
  (
   .clear((&wbs0_cti_i | !(|wbs0_cti_i)) & (!wbs0_flag | !wbs0_we_i)),
   .cke(((tx_fifo_a_sel_i==3'd0)&tx_fifo_we) | wbs0_ack_o),
   .zq(wbs0_flag),
   .clk(wb_clk),
   .rst(wb_rst)
   );
    */
`endif

`ifdef PORT1
   wire wbs1_flag, we_req1;
   fifo_fill cnt1
     (
      .wbs_flag(wbs1_flag),
      .we_req(we_req1),
      .bte(wbs1_bte_i),
      .cti(wbs1_cti_i),
      .cyc(wbs1_cyc_i),
      .stb(wbs1_stb_i),
      .we(wbs1_we_i),
      .we_ack((tx_fifo_a_sel_i==3'd1) & tx_fifo_we),
      .ack(wbs1_ack_o),
      .clk(wb_clk),
      .rst(wb_rst)
      );
 /*
   wire wbs1_flag;
ctrl_counter cnt1
  (
   .clear((&wbs1_cti_i | !(|wbs1_cti_i)) & (!wbs1_flag | !wbs1_we_i)),
   .cke(((tx_fifo_a_sel_i==3'd1)&tx_fifo_we) | wbs1_ack_o),
   .zq(wbs1_flag),
   .clk(wb_clk),
   .rst(wb_rst)
   );
 */
`endif

`ifdef PORT2
   wire wbs2_flag, we_req2;
   fifo_fill cnt2
     (
      .wbs_flag(wbs2_flag),
      .we_req(we_req2),
      .bte(wbs2_bte_i),
      .cti(wbs2_cti_i),
      .cyc(wbs2_cyc_i),
      .stb(wbs2_stb_i),
      .we(wbs2_we_i),
      .we_ack((tx_fifo_a_sel_i==3'd2) & tx_fifo_we),
      .ack(wbs2_ack_o),
      .clk(wb_clk),
      .rst(wb_rst)
      );
    
   /*
   wire wbs2_flag;
ctrl_counter cnt2
  (
   .clear((&wbs2_cti_i | !(|wbs2_cti_i)) & (!wbs2_flag | !wbs2_we_i)),
   .cke(((tx_fifo_a_sel_i==3'd2)&tx_fifo_we) | wbs2_ack_o),
   .zq(wbs2_flag),
   .clk(wb_clk),
   .rst(wb_rst)
   );
    */
`endif

`ifdef PORT3
   wire wbs3_flag, we_req3;
   fifo_fill cnt3
     (
      .wbs_flag(wbs3_flag),
      .we_req(we_req3),
      .bte(wbs3_bte_i),
      .cti(wbs3_cti_i),
      .cyc(wbs3_cyc_i),
      .stb(wbs3_stb_i),
      .we(wbs3_we_i),
      .we_ack((tx_fifo_a_sel_i==3'd3) & tx_fifo_we),
      .ack(wbs3_ack_o),
      .clk(wb_clk),
      .rst(wb_rst)
      );
    /*
   wire wbs3_flag;
ctrl_counter cnt3
  (
   .clear((&wbs3_cti_i | !(|wbs3_cti_i)) & (!wbs3_flag | !wbs3_we_i)),
   .cke(((tx_fifo_a_sel_i==3'd3)&tx_fifo_we) | wbs3_ack_o),
   .zq(wbs0_flag),
   .clk(wb_clk),
   .rst(wb_rst)
   );
    */
`endif

`ifdef PORT4
   
   wire wbs4_flag, we_req4;
   fifo_fill cnt4
     (
      .wbs_flag(wbs4_flag),
      .we_req(we_req4),
      .bte(wbs4_bte_i),
      .cti(wbs4_cti_i),
      .cyc(wbs4_cyc_i),
      .stb(wbs4_stb_i),
      .we(wbs4_we_i),
      .we_ack((tx_fifo_a_sel_i==3'd4) & tx_fifo_we),
      .ack(wbs4_ack_o),
      .clk(wb_clk),
      .rst(wb_rst)
      );
/*
   wire wbs4_flag;
ctrl_counter cnt4
  (
   .clear((&wbs4_cti_i | !(|wbs4_cti_i)) & (!wbs4_flag | !wbs4_we_i)),
   .cke(((tx_fifo_a_sel_i==3'd4)&tx_fifo_we) | wbs4_ack_o),
   .zq(wbs4_flag),
   .clk(wb_clk),
   .rst(wb_rst)
   );
 */
`endif

`ifdef PORT5
   wire wbs5_flag, we_req5;
   fifo_fill cnt0
     (
      .wbs_flag(wbs5_flag),
      .we_req(we_req5),
      .bte(wbs5_bte_i),
      .cti(wbs5_cti_i),
      .cyc(wbs5_cyc_i),
      .stb(wbs5_stb_i),
      .we(wbs5_we_i),
      .we_ack((tx_fifo_a_sel_i==3'd5) & tx_fifo_we),
      .ack(wbs5_ack_o),
      .clk(wb_clk),
      .rst(wb_rst)
      );
    /*
   wire wbs5_flag;
ctrl_counter cnt5
  (
   .clear((&wbs5_cti_i | !(|wbs5_cti_i)) & (!wbs5_flag | !wbs5_we_i)),
   .cke(((tx_fifo_a_sel_i==3'd5)&tx_fifo_we) | wbs5_ack_o),
   .zq(wbs5_flag),
   .clk(wb_clk),
   .rst(wb_rst)
   );
    */
`endif

`ifdef PORT6
   wire wbs6_flag, we_req6;
   fifo_fill cnt6
     (
      .wbs_flag(wbs6_flag),
      .we_req(we_req6),
      .bte(wbs6_bte_i),
      .cti(wbs6_cti_i),
      .cyc(wbs6_cyc_i),
      .stb(wbs6_stb_i),
      .we(wbs6_we_i),
      .we_ack((tx_fifo_a_sel_i==3'd6) & tx_fifo_we),
      .ack(wbs6_ack_o),
      .clk(wb_clk),
      .rst(wb_rst)
      );
    
   /*
   wire wbs6_flag;
ctrl_counter cnt6
  (
   .clear((&wbs6_cti_i | !(|wbs6_cti_i)) & (!wbs6_flag | !wbs6_we_i)),
   .cke(((tx_fifo_a_sel_i==3'd6)&tx_fifo_we) | wbs6_ack_o),
   .zq(wbs6_flag),
   .clk(wb_clk),
   .rst(wb_rst)
   );
    */
`endif

`ifdef PORT7
   wire wbs7_flag, we_req7;
   fifo_fill cnt7
     (
      .wbs_flag(wbs7_flag),
      .we_req(we_req7),
      .bte(wbs7_bte_i),
      .cti(wbs7_cti_i),
      .cyc(wbs7_cyc_i),
      .stb(wbs7_stb_i),
      .we(wbs7_we_i),
      .we_ack((tx_fifo_a_sel_i==3'd7) & tx_fifo_we),
      .ack(wbs7_ack_o),
      .clk(wb_clk),
      .rst(wb_rst)
      );
    
   /*
   wire wbs7_flag;
ctrl_counter cnt7
  (
   .clear((&wbs7_cti_i | !(|wbs7_cti_i)) & (!wbs7_flag | !wbs7_we_i)),
   .cke(((tx_fifo_a_sel_i==3'd7)&tx_fifo_we) | wbs7_ack_o),
   .zq(wbs7_flag),
   .clk(wb_clk),
   .rst(wb_rst)
   );
    */
`endif

// priority order - ongoing,4,5,6,7,0,1,2,3
assign {tx_fifo_a_sel_i,tx_fifo_we} 
  =
	      /*
`ifdef PORT4 
    (!wbs4_flag & wbs4_stb_i & !tx_fifo_full[4]) ? {3'd4,1'b1} :
`endif
`ifdef PORT5
    (!wbs5_flag & wbs5_stb_i & !tx_fifo_full[5]) ? {3'd5,1'b1} :
`endif
`ifdef PORT6
    (!wbs6_flag & wbs6_stb_i & !tx_fifo_full[6]) ? {3'd6,1'b1} :
`endif
`ifdef PORT7
    (!wbs7_flag & wbs7_stb_i & !tx_fifo_full[7]) ? {3'd7,1'b1} :
`endif
`ifdef PORT0
    (!wbs0_flag & we_req0 & !tx_fifo_full[0]) ? {3'd0,1'b1} :
`endif
`ifdef PORT1
    (!wbs1_flag & wbs1_stb_i & !tx_fifo_full[1]) ? {3'd1,1'b1} :
`endif
`ifdef PORT2
    (!wbs2_flag & wbs2_stb_i & !tx_fifo_full[2]) ? {3'd2,1'b1} :
`endif
`ifdef PORT3
    (!wbs3_flag & wbs3_stb_i & !tx_fifo_full[3]) ? {3'd3,1'b1} :
`endif
	       */
`ifdef PORT4 
    (we_req4 & !tx_fifo_full[4]) ? {3'd4,1'b1} :
`endif
`ifdef PORT5
    (we_req5 & !tx_fifo_full[5]) ? {3'd5,1'b1} :
`endif
`ifdef PORT6
    (we_req6 & !tx_fifo_full[6]) ? {3'd6,1'b1} :
`endif
`ifdef PORT7
    (we_req7 & !tx_fifo_full[7]) ? {3'd7,1'b1} :
`endif
`ifdef PORT0
    (we_req0 & !tx_fifo_full[0]) ? {3'd0,1'b1} :
`endif
`ifdef PORT1
    (we_req1 & !tx_fifo_full[1]) ? {3'd1,1'b1} :
`endif
`ifdef PORT2
    (we_req2 & !tx_fifo_full[2]) ? {3'd2,1'b1} :
`endif
`ifdef PORT3
    (we_req3 & !tx_fifo_full[3]) ? {3'd3,1'b1} :
`endif
    {3'd0,1'b0};

// tx_fifo dat_i mux
assign tx_fifo_dat_i
  =
`ifdef PORT0
   (tx_fifo_a_sel_i==3'd0) &  wbs0_flag ? {wbs0_adr_i,wbs0_we_i,wbs0_bte_i,wbs0_cti_i} :
   (tx_fifo_a_sel_i==3'd0) & !wbs0_flag ? {wbs0_dat_i,wbs0_sel_i} :
`endif
`ifdef PORT1
   (tx_fifo_a_sel_i==3'd1) &  wbs1_flag ? {wbs1_adr_i,wbs1_we_i,wbs1_bte_i,wbs1_cti_i} :
   (tx_fifo_a_sel_i==3'd1) & !wbs1_flag ? {wbs1_dat_i,wbs1_sel_i} :
`endif
`ifdef PORT2
   (tx_fifo_a_sel_i==3'd2) &  wbs2_flag ? {wbs2_adr_i,wbs2_we_i,wbs2_bte_i,wbs2_cti_i} :
   (tx_fifo_a_sel_i==3'd2) & !wbs2_flag ? {wbs2_dat_i,wbs2_sel_i} :
`endif
`ifdef PORT3
   (tx_fifo_a_sel_i==3'd3) &  wbs3_flag ? {wbs3_adr_i,wbs3_we_i,wbs3_bte_i,wbs3_cti_i} :
   (tx_fifo_a_sel_i==3'd3) & !wbs3_flag ? {wbs3_dat_i,wbs3_sel_i} :
`endif
`ifdef PORT4
   (tx_fifo_a_sel_i==3'd4) &  wbs4_flag ? {wbs4_adr_i,wbs4_we_i,wbs4_bte_i,wbs4_cti_i} :
   (tx_fifo_a_sel_i==3'd4) & !wbs4_flag ? {wbs4_dat_i,wbs4_sel_i} :
`endif
`ifdef PORT5
   (tx_fifo_a_sel_i==3'd5) &  wbs5_flag ? {wbs5_adr_i,wbs5_we_i,wbs5_bte_i,wbs5_cti_i} :
   (tx_fifo_a_sel_i==3'd5) & !wbs5_flag ? {wbs5_dat_i,wbs5_sel_i} :
`endif
`ifdef PORT6
   (tx_fifo_a_sel_i==3'd6) &  wbs6_flag ? {wbs6_adr_i,wbs6_we_i,wbs6_bte_i,wbs6_cti_i} :
   (tx_fifo_a_sel_i==3'd6) & !wbs6_flag ? {wbs6_dat_i,wbs6_sel_i} :
`endif
`ifdef PORT7
   (tx_fifo_a_sel_i==3'd7) &  wbs7_flag ? {wbs7_adr_i,wbs7_we_i,wbs7_bte_i,wbs7_cti_i} :
   (tx_fifo_a_sel_i==3'd7) & !wbs7_flag ? {wbs7_dat_i,wbs7_sel_i} :
`endif
   {wbs0_adr_i,wbs0_we_i,wbs0_bte_i,wbs0_cti_i};

   fifo tx_fifo
     (
      // A side (wb)
      .a_dat_i(tx_fifo_dat_i),
      .a_we_i(tx_fifo_we),
      .a_fifo_sel_i(tx_fifo_a_sel_i),
      .a_fifo_full_o(tx_fifo_full),
      .a_clk(wb_clk),
      // B side (sdram)
      .b_dat_o(tx_fifo_dat_o),
      .b_re_i(tx_fifo_re),
      .b_fifo_sel_i(tx_fifo_b_sel_i),
      .b_fifo_empty_o(tx_fifo_empty),
      .b_clk(sdram_clk),
      // misc
      .rst(wb_rst) 	 
      );
   
   assign tx_fifo_b_sel_i
     = 
       (adr_init & !tx_fifo_empty[4]) ? 3'd4 :
       (adr_init & !tx_fifo_empty[5]) ? 3'd5 :
       (adr_init & !tx_fifo_empty[6]) ? 3'd6 :
       (adr_init & !tx_fifo_empty[7]) ? 3'd7 :
       (adr_init & !tx_fifo_empty[0]) ? 3'd0 :
       (adr_init & !tx_fifo_empty[1]) ? 3'd1 :
       (adr_init & !tx_fifo_empty[2]) ? 3'd2 :
       (adr_init & !tx_fifo_empty[3]) ? 3'd3 :
       tx_fifo_b_sel_i_cur;

   always @ (posedge sdram_clk or posedge wb_rst)
     if (wb_rst)
       tx_fifo_b_sel_i_cur <= 3'd0;
     else if (adr_init)
       tx_fifo_b_sel_i_cur <= tx_fifo_b_sel_i;
   
   
   inc_adr inc_adr0
     (
      .adr_i(tx_fifo_dat_o[9:6]),
      .bte_i(tx_fifo_dat_o[4:3]),
      .cti_i(tx_fifo_dat_o[2:0]),
      .init(adr_init),
      .inc(adr_inc),
      .adr_o(burst_adr),
      .done(done),
      .clk(sdram_clk),
      .rst(wb_rst)
      );

   ref_counter ref_counter0
     (
      .zq(ref_zf),
      .clk(sdram_clk),
      .rst(wb_rst)
      );

   always @ (posedge sdram_clk or posedge wb_rst)
     if (wb_rst)
       ref_req <= 1'b1;
     else
       if (ref_zf)
	 ref_req <= 1'b1;
       else if (ref_ack)
	 ref_req <= 1'b0;
   

`ifdef SDR_16
   wire read;
   reg [15:0] dq_i_reg, dq_i_tmp_reg;   
      
   // SDR SDRAM 16 FSM
   sdr_16 sdr_16_0
     (
      .adr_inc(adr_inc),
      .adr_init(adr_init),
      .fifo_re(tx_fifo_re),
      .tx_fifo_dat_o(tx_fifo_dat_o),
      .burst_adr(burst_adr),
      .done(done),
      .fifo_empty(tx_fifo_empty),
      .fifo_sel(tx_fifo_b_sel_i_cur),
      .read(read),
      // refresh
      .ref_req(ref_req),
      .ref_ack(ref_ack),
      // sdram
      .dq(dq_o),
      .dqm(dqm_pad_o),
      .dq_oe(dq_oe),
      .a({ba_pad_o,a_pad_o}),
      .cmd({ras_pad_o,cas_pad_o,we_pad_o}),
      .cs_n(cs_n_pad_o),
      .sdram_clk(sdram_clk),
      .wb_rst(wb_rst)
      );
   
   assign cke_pad_o = 1'b1;

   defparam delay0.depth=`CL+2;   
   delay delay0
     (
      .d({read,tx_fifo_b_sel_i_cur}),
      .q({rx_fifo_we,rx_fifo_a_sel_i}),
      .clk(sdram_clk),
      .rst(wb_rst)
      );

   always @ (posedge sdram_clk or posedge wb_rst)
     if (wb_rst)
       {dq_i_reg, dq_i_tmp_reg} <= {16'h0000,16'h0000};
     else
       {dq_i_reg, dq_i_tmp_reg} <= {dq_i, dq_i_reg};

   assign rx_fifo_dat_i = {dq_i_tmp_reg, dq_i_reg, 4'h0};
   
`endif //  `ifdef SDR_16

   // receiving side FIFO
   fifo rx_fifo
     (
      // A side (sdram)
      .a_dat_i(rx_fifo_dat_i),
      .a_we_i(rx_fifo_we),
      .a_fifo_sel_i(rx_fifo_a_sel_i),
      .a_fifo_full_o(rx_fifo_full),
      .a_clk(sdram_clk),
      // B side (wb)
      .b_dat_o(rx_fifo_dat_o),
      .b_re_i(rx_fifo_re),
      .b_fifo_sel_i(rx_fifo_b_sel_i),
      .b_fifo_empty_o(rx_fifo_empty),
      .b_clk(wb_clk),
      // misc
      .rst(wb_rst) 	 
      );

   // WB/FIFO readout priority
   // 4,5,6,7,0,1,2,3
   assign {rx_fifo_re, rx_fifo_b_sel_i} = 
`ifdef PORT4
     !rx_fifo_empty[4] & wbs4_stb_i ? {1'b1,3'd4} :
`endif		    	    		       
`ifdef PORT5	    	    		       
     !rx_fifo_empty[5] & wbs5_stb_i ? {1'b1,3'd5} :
`endif		    	    		       
`ifdef PORT6	    	    		       
     !rx_fifo_empty[6] & wbs6_stb_i ? {1'b1,3'd6} :
`endif		    	    		       
`ifdef PORT7	    	    		       
     !rx_fifo_empty[7] & wbs7_stb_i ? {1'b1,3'd7} :
`endif		    	    		       
`ifdef PORT0	    	    		       
     !rx_fifo_empty[0] & wbs0_stb_i ? {1'b1,3'd0} :
`endif		    	    		       
`ifdef PORT1	    	    		       
     !rx_fifo_empty[1] & wbs1_stb_i ? {1'b1,3'd1} :
`endif		    	    		       
`ifdef PORT2	    	    		       
     !rx_fifo_empty[2] & wbs2_stb_i ? {1'b1,3'd2} :
`endif		    	    		       
`ifdef PORT3	    	    		       
     !rx_fifo_empty[3] & wbs3_stb_i ? {1'b1,3'd3} :
`endif
       {1'b0,3'd4};

   // ack read
   // delay one cycle to compensate for synchronous FIFO readout
   always @ (posedge wb_clk or posedge wb_rst)
     if (wb_rst)
       begin
`ifdef PORT0
	  wbs0_ack_re <= 1'b0;
`endif
`ifdef PORT1
	  wbs1_ack_re <= 1'b0;
`endif
`ifdef PORT2
	  wbs2_ack_re <= 1'b0;
`endif
`ifdef PORT3
	  wbs3_ack_re <= 1'b0;
`endif
`ifdef PORT4
	  wbs4_ack_re <= 1'b0;
`endif
`ifdef PORT5
	  wbs5_ack_re <= 1'b0;
`endif
`ifdef PORT6
	  wbs6_ack_re <= 1'b0;
`endif
`ifdef PORT7
	  wbs7_ack_re <= 1'b0;
`endif
       end
     else
       begin
`ifdef PORT0
	  wbs0_ack_re <= rx_fifo_re & (rx_fifo_b_sel_i == 3'd0);
`endif
`ifdef PORT1
	  wbs1_ack_re <= rx_fifo_re & (rx_fifo_b_sel_i == 3'd1);
`endif
`ifdef PORT2
	  wbs2_ack_re <= rx_fifo_re & (rx_fifo_b_sel_i == 3'd2);
`endif
`ifdef PORT3
	  wbs3_ack_re <= rx_fifo_re & (rx_fifo_b_sel_i == 3'd3);
`endif
`ifdef PORT4
	  wbs4_ack_re <= rx_fifo_re & (rx_fifo_b_sel_i == 3'd4);
`endif
`ifdef PORT5
	  wbs5_ack_re <= rx_fifo_re & (rx_fifo_b_sel_i == 3'd5);
`endif
`ifdef PORT6
	  wbs6_ack_re <= rx_fifo_re & (rx_fifo_b_sel_i == 3'd6);
`endif
`ifdef PORT7
	  wbs7_ack_re <= rx_fifo_re & (rx_fifo_b_sel_i == 3'd7);
`endif
       end
   
   // ack
`ifdef PORT0
   assign wbs0_dat_o = rx_fifo_dat_o[35:4];
   assign wbs0_ack_o = (!wbs0_flag & tx_fifo_we & (tx_fifo_a_sel_i  == 3'd0)) | wbs0_ack_re;
`endif
`ifdef PORT1
   assign wbs1_dat_o = rx_fifo_dat_o[35:4];
   assign wbs1_ack_o = (!wbs1_flag & tx_fifo_we & (tx_fifo_a_sel_i  == 3'd1)) | wbs1_ack_re;
`endif
`ifdef PORT2
   assign wbs2_dat_o = rx_fifo_dat_o[35:4];
   assign wbs2_ack_o = (!wbs2_flag & tx_fifo_we & (tx_fifo_a_sel_i  == 3'd2)) | wbs2_ack_re;
`endif
`ifdef PORT3
   assign wbs3_dat_o = rx_fifo_dat_o[35:4];
   assign wbs3_ack_o = (!wbs3_flag & tx_fifo_we & (tx_fifo_a_sel_i  == 3'd3)) | wbs3_ack_re;
`endif
`ifdef PORT4
   assign wbs4_dat_o = rx_fifo_dat_o[35:4];
   assign wbs4_ack_o = (!wbs4_flag & tx_fifo_we & (tx_fifo_a_sel_i  == 3'd4)) | wbs4_ack_re;
`endif
`ifdef PORT5
   assign wbs5_dat_o = rx_fifo_dat_o[35:4];
   assign wbs5_ack_o = (!wbs5_flag & tx_fifo_we & (tx_fifo_a_sel_i  == 3'd5)) | wbs5_ack_re;
`endif
`ifdef PORT6
   assign wbs6_dat_o = rx_fifo_dat_o[35:4];
   assign wbs6_ack_o = (!wbs6_flag & tx_fifo_we & (tx_fifo_a_sel_i  == 3'd6)) | wbs6_ack_re;
`endif
`ifdef PORT7
   assign wbs7_dat_o = rx_fifo_dat_o[35:4];
   assign wbs7_ack_o = (!wbs7_flag & tx_fifo_we & (tx_fifo_a_sel_i  == 3'd7)) | wbs7_ack_re;   
`endif
   
endmodule // wb_sdram_ctrl_top
