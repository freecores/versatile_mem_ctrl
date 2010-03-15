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
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Versatile counter                                           ////
////                                                              ////
////  Description                                                 ////
////  Versatile counter, a reconfigurable binary, gray or LFSR    ////
////  counter                                                     ////
////                                                              ////
////  To Do:                                                      ////
////   - add LFSR with more taps                                  ////
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
   output reg	fifo_empty;
   output       fifo_full;
   input 	wclk, rclk, rst;   
   
   reg 	direction, direction_set, direction_clr;
      
   wire tmp_direction;   // MF

   wire async_empty, async_full;
   wire fifo_full2;
   reg  fifo_empty2;   
   
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

`ifndef GENERATE_DIRECTION_AS_LATCH
    //dff_sr dff_sr_dir( .aclr(direction_clr), .aset(direction_set), .clock(1'b1), .data(1'b1), .q(direction));
    dff_sr dff_sr_dir( .aclr(direction_clr), .aset(direction_set), .clock(1'b1), .data(1'b1), .q(tmp_direction));
    always @ (tmp_direction)
      direction <= tmp_direction;
`endif

`ifdef GENERATE_DIRECTION_AS_LATCH
   always @ (posedge direction_set or posedge direction_clr)
     if (direction_clr)
       direction <= going_empty;
     else
       direction <= going_full;
`endif

   assign async_empty = (wptr == rptr) && (direction==going_empty);
   assign async_full  = (wptr == rptr) && (direction==going_full);

    dff_sr dff_sr_empty0( .aclr(rst), .aset(async_full), .clock(wclk), .data(async_full), .q(fifo_full2));
    dff_sr dff_sr_empty1( .aclr(rst), .aset(async_full), .clock(wclk), .data(fifo_full2), .q(fifo_full));

/*
   always @ (posedge wclk or posedge rst or posedge async_full)
     if (rst)
       {fifo_full, fifo_full2} <= 2'b00;
     else if (async_full)
       {fifo_full, fifo_full2} <= 2'b11;
     else
       {fifo_full, fifo_full2} <= {fifo_full2, async_full};
*/
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
////  Versatile counter                                           ////
////                                                              ////
////  Description                                                 ////
////  Versatile counter, a reconfigurable binary, gray or LFSR    ////
////  counter                                                     ////
////                                                              ////
////  To Do:                                                      ////
////   - add LFSR with more taps                                  ////
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

// GRAY counter
module fifo_adr_counter ( cke, q, q_bin, rst, clk);

   parameter length = 5;
   input cke;
   output reg [length:1] q;
   output [length:1] q_bin;
   input rst;
   input clk;

   parameter clear_value = 0;
   parameter set_value = 0;
   parameter wrap_value = 9;

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
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Versatile counter                                           ////
////                                                              ////
////  Description                                                 ////
////  Versatile counter, a reconfigurable binary, gray or LFSR    ////
////  counter                                                     ////
////                                                              ////
////  To Do:                                                      ////
////   - add LFSR with more taps                                  ////
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

// LFSR counter
module ctrl_counter ( clear, cke, zq, rst, clk);

   parameter length = 5;
   input clear;
   input cke;
   output reg zq;
   input rst;
   input clk;

   parameter clear_value = 0;
   parameter set_value = 0;
   parameter wrap_value = 31;

   reg  [length:1] qi;
   reg lfsr_fb;
   wire [length:1] q_next;
   reg [32:1] polynom;
   integer i;

   always @ (qi)
   begin
        case (length) 
         2: polynom = 32'b11;                               // 0x3
         3: polynom = 32'b110;                              // 0x6
         4: polynom = 32'b1100;                             // 0xC
         5: polynom = 32'b10100;                            // 0x14
         6: polynom = 32'b110000;                           // 0x30
         7: polynom = 32'b1100000;                          // 0x60
         8: polynom = 32'b10111000;                         // 0xb8
         9: polynom = 32'b100010000;                        // 0x110
        10: polynom = 32'b1001000000;                       // 0x240
        11: polynom = 32'b10100000000;                      // 0x500
        12: polynom = 32'b100000101001;                     // 0x829
        13: polynom = 32'b1000000001100;                    // 0x100C
        14: polynom = 32'b10000000010101;                   // 0x2015
        15: polynom = 32'b110000000000000;                  // 0x6000
        16: polynom = 32'b1101000000001000;                 // 0xD008
        17: polynom = 32'b10010000000000000;                // 0x12000
        18: polynom = 32'b100000010000000000;               // 0x20400
        19: polynom = 32'b1000000000000100011;              // 0x40023
        20: polynom = 32'b10000010000000000000;             // 0x82000
        21: polynom = 32'b101000000000000000000;            // 0x140000
        22: polynom = 32'b1100000000000000000000;           // 0x300000
        23: polynom = 32'b10000100000000000000000;          // 0x420000
        24: polynom = 32'b111000010000000000000000;         // 0xE10000
        25: polynom = 32'b1001000000000000000000000;        // 0x1200000
        26: polynom = 32'b10000000000000000000100011;       // 0x2000023
        27: polynom = 32'b100000000000000000000010011;      // 0x4000013
        28: polynom = 32'b1100100000000000000000000000;     // 0xC800000
        29: polynom = 32'b10100000000000000000000000000;    // 0x14000000
        30: polynom = 32'b100000000000000000000000101001;   // 0x20000029
        31: polynom = 32'b1001000000000000000000000000000;  // 0x48000000
        32: polynom = 32'b10000000001000000000000000000011; // 0x80200003
        default: polynom = 32'b0;
        endcase
        lfsr_fb = qi[length];
        for (i=length-1; i>=1; i=i-1) begin
            if (polynom[i])
                lfsr_fb = lfsr_fb  ~^ qi[i];
        end
    end
   assign q_next =  clear ? {length{1'b0}} :{qi[length-1:1],lfsr_fb};

   always @ (posedge clk or posedge rst)
     if (rst)
       qi <= {length{1'b0}};
     else
     if (cke)
       qi <= q_next;



   always @ (posedge clk or posedge rst)
     if (rst)
       zq <= 1'b1;
     else
     if (cke)
       zq <= q_next == {length{1'b0}};
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
  idle    = 0, 
  state1  = 1, 
  state10 = 2, 
  state11 = 3, 
  state12 = 4, 
  state13 = 5, 
  state14 = 6, 
  state15 = 7, 
  state16 = 8, 
  state2  = 9, 
  state3  = 10, 
  state4  = 11, 
  state5  = 12, 
  state6  = 13, 
  state7  = 14, 
  state8  = 15, 
  state9  = 16; 
  
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
    case (1'b1)
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
////  Versatile counter                                           ////
////                                                              ////
////  Description                                                 ////
////  Versatile counter, a reconfigurable binary, gray or LFSR    ////
////  counter                                                     ////
////                                                              ////
////  To Do:                                                      ////
////   - add LFSR with more taps                                  ////
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

// LFSR counter
module ref_counter ( zq, rst, clk);

   parameter length = 10;
   output reg zq;
   input rst;
   input clk;

   parameter clear_value = 0;
   parameter set_value = 0;
   parameter wrap_value = 592;

   reg  [length:1] qi;
   reg lfsr_fb;
   wire [length:1] q_next;
   reg [32:1] polynom;
   integer i;

   always @ (qi)
   begin
        case (length) 
         2: polynom = 32'b11;                               // 0x3
         3: polynom = 32'b110;                              // 0x6
         4: polynom = 32'b1100;                             // 0xC
         5: polynom = 32'b10100;                            // 0x14
         6: polynom = 32'b110000;                           // 0x30
         7: polynom = 32'b1100000;                          // 0x60
         8: polynom = 32'b10111000;                         // 0xb8
         9: polynom = 32'b100010000;                        // 0x110
        10: polynom = 32'b1001000000;                       // 0x240
        11: polynom = 32'b10100000000;                      // 0x500
        12: polynom = 32'b100000101001;                     // 0x829
        13: polynom = 32'b1000000001100;                    // 0x100C
        14: polynom = 32'b10000000010101;                   // 0x2015
        15: polynom = 32'b110000000000000;                  // 0x6000
        16: polynom = 32'b1101000000001000;                 // 0xD008
        17: polynom = 32'b10010000000000000;                // 0x12000
        18: polynom = 32'b100000010000000000;               // 0x20400
        19: polynom = 32'b1000000000000100011;              // 0x40023
        20: polynom = 32'b10000010000000000000;             // 0x82000
        21: polynom = 32'b101000000000000000000;            // 0x140000
        22: polynom = 32'b1100000000000000000000;           // 0x300000
        23: polynom = 32'b10000100000000000000000;          // 0x420000
        24: polynom = 32'b111000010000000000000000;         // 0xE10000
        25: polynom = 32'b1001000000000000000000000;        // 0x1200000
        26: polynom = 32'b10000000000000000000100011;       // 0x2000023
        27: polynom = 32'b100000000000000000000010011;      // 0x4000013
        28: polynom = 32'b1100100000000000000000000000;     // 0xC800000
        29: polynom = 32'b10100000000000000000000000000;    // 0x14000000
        30: polynom = 32'b100000000000000000000000101001;   // 0x20000029
        31: polynom = 32'b1001000000000000000000000000000;  // 0x48000000
        32: polynom = 32'b10000000001000000000000000000011; // 0x80200003
        default: polynom = 32'b0;
        endcase
        lfsr_fb = qi[length];
        for (i=length-1; i>=1; i=i-1) begin
            if (polynom[i])
                lfsr_fb = lfsr_fb  ~^ qi[i];
        end
    end
   assign q_next = {qi[length-1:1],lfsr_fb};

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
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Versatile counter                                           ////
////                                                              ////
////  Description                                                 ////
////  Versatile counter, a reconfigurable binary, gray or LFSR    ////
////  counter                                                     ////
////                                                              ////
////  To Do:                                                      ////
////   - add LFSR with more taps                                  ////
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

// BINARY counter
module ref_delay_counter ( cke, zq, rst, clk);

   parameter length = 6;
   input cke;
   output reg zq;
   input rst;
   input clk;

   parameter clear_value = 0;
   parameter set_value = 0;
   parameter wrap_value = 12;

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
       zq <= 1'b1;
     else
     if (cke)
       zq <= q_next == {length{1'b0}};
endmodule
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Versatile counter                                           ////
////                                                              ////
////  Description                                                 ////
////  Versatile counter, a reconfigurable binary, gray or LFSR    ////
////  counter                                                     ////
////                                                              ////
////  To Do:                                                      ////
////   - add LFSR with more taps                                  ////
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

// BINARY counter
module pre_delay_counter ( cke, zq, rst, clk);

   parameter length = 2;
   input cke;
   output reg zq;
   input rst;
   input clk;

   parameter clear_value = 0;
   parameter set_value = 0;
   parameter wrap_value = 2;

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
       zq <= 1'b1;
     else
     if (cke)
       zq <= q_next == {length{1'b0}};
endmodule
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Versatile counter                                           ////
////                                                              ////
////  Description                                                 ////
////  Versatile counter, a reconfigurable binary, gray or LFSR    ////
////  counter                                                     ////
////                                                              ////
////  To Do:                                                      ////
////   - add LFSR with more taps                                  ////
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

// BINARY counter
module burst_length_counter ( cke, zq, rst, clk);

   parameter length = 3;
   input cke;
   output reg zq;
   input rst;
   input clk;

   parameter clear_value = 0;
   parameter set_value = 0;
   parameter wrap_value = 3;

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
       zq <= 1'b1;
     else
     if (cke)
       zq <= q_next == {length{1'b0}};
endmodule
 `timescale 1ns/1ns
module sdr_16 (
  output reg [14:0] a,
  output reg adr_inc,
  output reg adr_init,
  output reg [2:0] cmd,
  output reg cs_n,
  output reg dq_hi,
  output reg dq_lo,
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
  IDLE      = 0, 
  ACT_ROW   = 1, 
  AREF      = 2, 
  ARF1      = 3, 
  ARF2      = 4, 
  AWAIT_CMD = 5, 
  LMR       = 6, 
  NOP1      = 7, 
  NOP10     = 8, 
  NOP2      = 9, 
  NOP3      = 10, 
  NOP4      = 11, 
  NOP5      = 12, 
  NOP6      = 13, 
  NOP7      = 14, 
  NOP8      = 15, 
  NOP9      = 16, 
  PRE       = 17, 
  PRECHARGE = 18, 
  READ      = 19, 
  WRITE     = 20; 
  reg [20:0] state;
  reg [20:0] nextstate;
  always @* begin
    nextstate = 21'b000000000000000000000;
    adr_inc = 1'b0; 
    adr_init = 1'b0; 
    dq_hi = 1'b0; 
    dq_lo = 1'b0; 
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
        dq_hi = 1'b1;
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
        dq_lo = 1'b1;
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
      dq_oe <= 1'b0;
      dqm[1:0] <= 2'b11;
      read <= 1'b0;
    end
    else begin
      a[14:0] <= 15'd0; 
      cmd[2:0] <= 3'b111; 
      cs_n <= 1'b0; 
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
          dq_oe <= 1'b1;
          dqm[1:0] <= !tx_fifo_dat_o[3:2];
        end
      endcase
    end
  end
  reg [71:0] statename;
  always @* begin
    case (1'b1)
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
module ddr_16 (
  output reg [14:0] a,
  output reg adr_init,
  output reg bl_en,
  output reg [2:0] cmd,
  output reg cs_n,
  output reg [12:0] cur_row,
  output reg fifo_re,
  output reg read,
  output reg ref_ack,
  output reg ref_delay,
  output reg write,
  input wire bl_ack,
  input wire [3:0] burst_adr,
  input wire [7:0] fifo_empty,
  input wire fifo_re_d,
  input wire [2:0] fifo_sel,
  input wire ref_delay_ack,
  input wire ref_req,
  input wire sdram_clk,
  input wire [35:0] tx_fifo_dat_o,
  input wire wb_rst 
);
  parameter 
  IDLE        = 0, 
  ACT_ROW     = 1, 
  AREF        = 2, 
  AREF_0      = 3, 
  AREF_1      = 4, 
  AWAIT_CMD   = 5, 
  LEMR2       = 6, 
  LEMR3       = 7, 
  LEMR_0      = 8, 
  LEMR_1      = 9, 
  LEMR_2      = 10, 
  LMR_0       = 11, 
  LMR_1       = 12, 
  NOP0        = 13, 
  NOP1        = 14, 
  NOP10       = 15, 
  NOP11       = 16, 
  NOP12       = 17, 
  NOP14       = 18, 
  NOP15       = 19, 
  NOP2        = 20, 
  NOP20       = 21, 
  NOP21       = 22, 
  NOP22       = 23, 
  NOP3        = 24, 
  NOP30       = 25, 
  NOP31       = 26, 
  NOP32       = 27, 
  NOP4        = 28, 
  NOP5        = 29, 
  NOP6        = 30, 
  NOP7        = 31, 
  NOP8        = 32, 
  NOP9        = 33, 
  NOP_tRFC    = 34, 
  NOP_tWR     = 35, 
  PRECHARGE   = 36, 
  PRE_0       = 37, 
  PRE_1       = 38, 
  READ_ADDR   = 39, 
  READ_BURST  = 40, 
  WRITE_ADDR  = 41, 
  WRITE_BURST = 42; 
  reg [42:0] state;
  reg [42:0] nextstate;
  always @* begin
    nextstate = 43'b0000000000000000000000000000000000000000000;
    adr_init = 1'b0; 
    bl_en = 1'b0; 
    fifo_re = 1'b0; 
    read = 1'b0; 
    ref_ack = 1'b0; 
    ref_delay = 1'b0; 
    write = 1'b0; 
    case (1'b1) 
      state[IDLE]       : begin
        begin
          nextstate[NOP0] = 1'b1;
        end
      end
      state[ACT_ROW]    : begin
        if (tx_fifo_dat_o[5]) begin
          nextstate[NOP14] = 1'b1;
        end
        else begin
          nextstate[NOP15] = 1'b1;
        end
      end
      state[AREF]       : begin
        ref_ack = 1'b1;
        ref_delay = 1'b1;
        begin
          nextstate[NOP_tRFC] = 1'b1;
        end
      end
      state[AREF_0]     : begin
        ref_ack = 1'b1;
        begin
          nextstate[NOP7] = 1'b1;
        end
      end
      state[AREF_1]     : begin
        ref_ack = 1'b1;
        begin
          nextstate[NOP8] = 1'b1;
        end
      end
      state[AWAIT_CMD]  : begin
        adr_init = !(&fifo_empty);
        if (ref_req) begin
          nextstate[AREF] = 1'b1;
        end
        else if (!(&fifo_empty)) begin
          nextstate[NOP12] = 1'b1;
        end
        else begin
          nextstate[AWAIT_CMD] = 1'b1; 
        end
      end
      state[LEMR2]      : begin
        ref_ack = 1'b1;
        begin
          nextstate[NOP2] = 1'b1;
        end
      end
      state[LEMR3]      : begin
        ref_ack = 1'b1;
        begin
          nextstate[NOP3] = 1'b1;
        end
      end
      state[LEMR_0]     : begin
        ref_ack = 1'b1;
        begin
          nextstate[NOP4] = 1'b1;
        end
      end
      state[LEMR_1]     : begin
        ref_ack = 1'b1;
        begin
          nextstate[NOP10] = 1'b1;
        end
      end
      state[LEMR_2]     : begin
        ref_ack = 1'b1;
        begin
          nextstate[NOP11] = 1'b1;
        end
      end
      state[LMR_0]      : begin
        ref_ack = 1'b1;
        begin
          nextstate[NOP5] = 1'b1;
        end
      end
      state[LMR_1]      : begin
        ref_ack = 1'b1;
        begin
          nextstate[NOP9] = 1'b1;
        end
      end
      state[NOP0]       : begin
        begin
          nextstate[PRE_0] = 1'b1;
        end
      end
      state[NOP1]       : begin
        if (ref_req) begin
          nextstate[LEMR2] = 1'b1;
        end
        else begin
          nextstate[NOP1] = 1'b1; 
        end
      end
      state[NOP10]      : begin
        if (ref_req) begin
          nextstate[LEMR_2] = 1'b1;
        end
        else begin
          nextstate[NOP10] = 1'b1; 
        end
      end
      state[NOP11]      : begin
        if (ref_req) begin
          nextstate[AWAIT_CMD] = 1'b1;
        end
        else begin
          nextstate[NOP11] = 1'b1; 
        end
      end
      state[NOP12]      : begin
        begin
          nextstate[ACT_ROW] = 1'b1;
        end
      end
      state[NOP14]      : begin 
        begin
          nextstate[WRITE_ADDR] = 1'b1;
        end
      end
      state[NOP15]      : begin
        begin
          nextstate[READ_ADDR] = 1'b1;
        end
      end
      state[NOP2]       : begin
        if (ref_req) begin
          nextstate[LEMR3] = 1'b1;
        end
        else begin
          nextstate[NOP2] = 1'b1; 
        end
      end
      state[NOP20]      : begin
        begin
          nextstate[NOP21] = 1'b1;
        end
      end
      state[NOP21]      : begin
        adr_init = 1'b1;
        if (!fifo_re_d) begin
          nextstate[NOP22] = 1'b1;
        end
        else begin
          nextstate[NOP21] = 1'b1; 
        end
      end
      state[NOP22]      : begin
        begin
          nextstate[NOP_tWR] = 1'b1;
        end
      end
      state[NOP3]       : begin
        if (ref_req) begin
          nextstate[LEMR_0] = 1'b1;
        end
        else begin
          nextstate[NOP3] = 1'b1; 
        end
      end
      state[NOP30]      : begin
        begin
          nextstate[NOP31] = 1'b1;
        end
      end
      state[NOP31]      : begin
        adr_init = 1'b1;
        begin
          nextstate[NOP32] = 1'b1;
        end
      end
      state[NOP32]      : begin
        begin
          nextstate[NOP_tWR] = 1'b1;
        end
      end
      state[NOP4]       : begin
        if (ref_req) begin
          nextstate[LMR_0] = 1'b1;
        end
        else begin
          nextstate[NOP4] = 1'b1; 
        end
      end
      state[NOP5]       : begin
        if (ref_req) begin
          nextstate[PRE_1] = 1'b1;
        end
        else begin
          nextstate[NOP5] = 1'b1; 
        end
      end
      state[NOP6]       : begin
        if (ref_req) begin
          nextstate[AREF_0] = 1'b1;
        end
        else begin
          nextstate[NOP6] = 1'b1; 
        end
      end
      state[NOP7]       : begin
        if (ref_req) begin
          nextstate[AREF_1] = 1'b1;
        end
        else begin
          nextstate[NOP7] = 1'b1; 
        end
      end
      state[NOP8]       : begin
        if (ref_req) begin
          nextstate[LMR_1] = 1'b1;
        end
        else begin
          nextstate[NOP8] = 1'b1; 
        end
      end
      state[NOP9]       : begin
        if (ref_req) begin
          nextstate[LEMR_1] = 1'b1;
        end
        else begin
          nextstate[NOP9] = 1'b1; 
        end
      end
      state[NOP_tRFC]   : begin 
        ref_delay = !ref_delay_ack;
        if (ref_delay_ack) begin
          nextstate[AWAIT_CMD] = 1'b1;
        end
        else begin
          nextstate[NOP_tRFC] = 1'b1; 
        end
      end
      state[NOP_tWR]    : begin 
        if (!(tx_fifo_dat_o[5]) && (cur_row == tx_fifo_dat_o[26:14])) begin
          nextstate[READ_ADDR] = 1'b1;
        end
        else if (tx_fifo_dat_o[5] && (cur_row == tx_fifo_dat_o[26:14])) begin
          nextstate[WRITE_ADDR] = 1'b1;
        end
        else begin
          nextstate[PRECHARGE] = 1'b1;
        end
      end
      state[PRECHARGE]  : begin
        begin
          nextstate[AWAIT_CMD] = 1'b1;
        end
      end
      state[PRE_0]      : begin
        ref_ack = 1'b1;
        begin
          nextstate[NOP1] = 1'b1;
        end
      end
      state[PRE_1]      : begin
        ref_ack = 1'b1;
        begin
          nextstate[NOP6] = 1'b1;
        end
      end
      state[READ_ADDR]  : begin
        bl_en = 1'b1;
        read = 1'b1;
        begin
          nextstate[READ_BURST] = 1'b1;
        end
      end
      state[READ_BURST] : begin
        bl_en = !bl_ack;
        fifo_re = bl_ack;
        read = !bl_ack;
        if (bl_ack) begin
          nextstate[NOP30] = 1'b1;
        end
        else begin
          nextstate[READ_BURST] = 1'b1; 
        end
      end
      state[WRITE_ADDR] : begin
        bl_en = 1'b1;
        fifo_re = 1'b1;
        write = 1'b1;
        begin
          nextstate[WRITE_BURST] = 1'b1;
        end
      end
      state[WRITE_BURST]: begin
        bl_en = !bl_ack;
        fifo_re = 1'b1;
        write = 1'b1;
        if (bl_ack) begin
          nextstate[NOP20] = 1'b1;
        end
        else begin
          nextstate[WRITE_BURST] = 1'b1; 
        end
      end
    endcase
  end
  always @(posedge sdram_clk or posedge wb_rst) begin
    if (wb_rst)
      state <= 43'b0000000000000000000000000000000000000000001 << IDLE;
    else
      state <= nextstate;
  end
  always @(posedge sdram_clk or posedge wb_rst) begin
    if (wb_rst) begin
      a[14:0] <= 15'd0;
      cmd[2:0] <= 3'b111;
      cs_n <= 1'b1;
      cur_row[12:0] <= cur_row;
    end
    else begin
      a[14:0] <= 15'd0; 
      cmd[2:0] <= 3'b111; 
      cs_n <= 1'b0; 
      cur_row[12:0] <= cur_row; 
      case (1'b1) 
        nextstate[IDLE]       : begin
          cs_n <= 1'b1;
        end
        nextstate[ACT_ROW]    : begin
          a[14:0] <= {tx_fifo_dat_o[28:27],tx_fifo_dat_o[26:14]};
          cmd[2:0] <= 3'b011;
          cur_row[12:0] <= tx_fifo_dat_o[26:14];
        end
        nextstate[AREF]       : begin
          a[14:0] <= a;
          cmd[2:0] <= 3'b001;
        end
        nextstate[AREF_0]     : begin
          a[14:0] <= a;
          cmd[2:0] <= 3'b001;
        end
        nextstate[AREF_1]     : begin
          a[14:0] <= a;
          cmd[2:0] <= 3'b001;
        end
        nextstate[AWAIT_CMD]  : begin
          a[14:0] <= a;
          cs_n <= 1'b1;
        end
        nextstate[LEMR2]      : begin
          a[14:0] <= {2'b10,5'b00000,1'b0,7'b0000000};
          cmd[2:0] <= 3'b000;
        end
        nextstate[LEMR3]      : begin
          a[14:0] <= {2'b11,13'b0000000000000};
          cmd[2:0] <= 3'b000;
        end
        nextstate[LEMR_0]     : begin
          a[14:0] <= {2'b01,1'b0,1'b0,1'b0,3'b000,1'b0,3'b000,1'b0,1'b0,1'b0};
          cmd[2:0] <= 3'b000;
        end
        nextstate[LEMR_1]     : begin
          a[14:0] <= {2'b01,1'b0,1'b0,1'b0,3'b111,1'b0,3'b000,1'b0,1'b0,1'b0};
          cmd[2:0] <= 3'b000;
        end
        nextstate[LEMR_2]     : begin
          a[14:0] <= {2'b01,1'b0,1'b0,1'b0,3'b000,1'b0,3'b000,1'b0,1'b0,1'b0};
          cmd[2:0] <= 3'b000;
        end
        nextstate[LMR_0]      : begin
          a[14:0] <= {2'b00,1'b0,3'b001,1'b1,1'b0,3'b100,1'b0,3'b011};
          cmd[2:0] <= 3'b000;
        end
        nextstate[LMR_1]      : begin
          a[14:0] <= {2'b00,1'b0,3'b001,1'b0,1'b0,3'b100,1'b0,3'b011};
          cmd[2:0] <= 3'b000;
        end
        nextstate[NOP0]       : begin
          a[14:0] <= a;
        end
        nextstate[NOP1]       : begin
          a[14:0] <= a;
        end
        nextstate[NOP10]      : begin
          a[14:0] <= a;
        end
        nextstate[NOP11]      : begin
          a[14:0] <= a;
        end
        nextstate[NOP14]      : begin
          a[14:0] <= a;
        end
        nextstate[NOP15]      : begin
          a[14:0] <= a;
        end
        nextstate[NOP2]       : begin
          a[14:0] <= a;
        end
        nextstate[NOP20]      : begin
          a[14:0] <= a;
        end
        nextstate[NOP21]      : begin
          a[14:0] <= a;
        end
        nextstate[NOP22]      : begin
          a[14:0] <= a;
        end
        nextstate[NOP3]       : begin
          a[14:0] <= a;
        end
        nextstate[NOP30]      : begin
          a[14:0] <= a;
        end
        nextstate[NOP31]      : begin
          a[14:0] <= a;
        end
        nextstate[NOP32]      : begin
          a[14:0] <= a;
        end
        nextstate[NOP4]       : begin
          a[14:0] <= a;
        end
        nextstate[NOP5]       : begin
          a[14:0] <= a;
        end
        nextstate[NOP6]       : begin
          a[14:0] <= a;
        end
        nextstate[NOP7]       : begin
          a[14:0] <= a;
        end
        nextstate[NOP8]       : begin
          a[14:0] <= a;
        end
        nextstate[NOP9]       : begin
          a[14:0] <= a;
        end
        nextstate[NOP_tRFC]   : begin
          a[14:0] <= a;
        end
        nextstate[NOP_tWR]    : begin
          a[14:0] <= a;
        end
        nextstate[PRECHARGE]  : begin
          a[14:0] <= {2'b00,13'b0010000000000};
          cmd[2:0] <= 3'b010;
        end
        nextstate[PRE_0]      : begin
          a[14:0] <= {2'b00,13'b0010000000000};
          cmd[2:0] <= 3'b010;
        end
        nextstate[PRE_1]      : begin
          a[14:0] <= {2'b00,13'b0010000000000};
          cmd[2:0] <= 3'b010;
        end
        nextstate[READ_ADDR]  : begin
          a[14:0] <= {tx_fifo_dat_o[28:27],{4'b0000,tx_fifo_dat_o[13:10],burst_adr,1'b0}};
          cmd[2:0] <= 3'b101;
        end
        nextstate[READ_BURST] : begin
          a[14:0] <= a;
        end
        nextstate[WRITE_ADDR] : begin
          a[14:0] <= {tx_fifo_dat_o[28:27],{4'b0000,tx_fifo_dat_o[13:10],burst_adr,1'b0}};
          cmd[2:0] <= 3'b100;
        end
        nextstate[WRITE_BURST]: begin
          a[14:0] <= a;
        end
      endcase
    end
  end
  reg [87:0] statename;
  always @* begin
    case (1'b1)
      state[IDLE]       :
        statename = "IDLE";
      state[ACT_ROW]    :
        statename = "ACT_ROW";
      state[AREF]       :
        statename = "AREF";
      state[AREF_0]     :
        statename = "AREF_0";
      state[AREF_1]     :
        statename = "AREF_1";
      state[AWAIT_CMD]  :
        statename = "AWAIT_CMD";
      state[LEMR2]      :
        statename = "LEMR2";
      state[LEMR3]      :
        statename = "LEMR3";
      state[LEMR_0]     :
        statename = "LEMR_0";
      state[LEMR_1]     :
        statename = "LEMR_1";
      state[LEMR_2]     :
        statename = "LEMR_2";
      state[LMR_0]      :
        statename = "LMR_0";
      state[LMR_1]      :
        statename = "LMR_1";
      state[NOP0]       :
        statename = "NOP0";
      state[NOP1]       :
        statename = "NOP1";
      state[NOP10]      :
        statename = "NOP10";
      state[NOP11]      :
        statename = "NOP11";
      state[NOP12]      :
        statename = "NOP12";
      state[NOP14]      :
        statename = "NOP14";
      state[NOP15]      :
        statename = "NOP15";
      state[NOP2]       :
        statename = "NOP2";
      state[NOP20]      :
        statename = "NOP20";
      state[NOP21]      :
        statename = "NOP21";
      state[NOP22]      :
        statename = "NOP22";
      state[NOP3]       :
        statename = "NOP3";
      state[NOP30]      :
        statename = "NOP30";
      state[NOP31]      :
        statename = "NOP31";
      state[NOP32]      :
        statename = "NOP32";
      state[NOP4]       :
        statename = "NOP4";
      state[NOP5]       :
        statename = "NOP5";
      state[NOP6]       :
        statename = "NOP6";
      state[NOP7]       :
        statename = "NOP7";
      state[NOP8]       :
        statename = "NOP8";
      state[NOP9]       :
        statename = "NOP9";
      state[NOP_tRFC]   :
        statename = "NOP_tRFC";
      state[NOP_tWR]    :
        statename = "NOP_tWR";
      state[PRECHARGE]  :
        statename = "PRECHARGE";
      state[PRE_0]      :
        statename = "PRE_0";
      state[PRE_1]      :
        statename = "PRE_1";
      state[READ_ADDR]  :
        statename = "READ_ADDR";
      state[READ_BURST] :
        statename = "READ_BURST";
      state[WRITE_ADDR] :
        statename = "WRITE_ADDR";
      state[WRITE_BURST]:
        statename = "WRITE_BURST";
      default    :
        statename = "XXXXXXXXXXX";
    endcase
  end
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
   
endmodule //delay

   
`include "versatile_mem_ctrl_defines.v"

module ddr_ff_in
  (
   input  C0,   // clock
   input  C1,   // clock
   input  D,    // data input
   input  CE,   // clock enable
   output Q0,   // data output
   output Q1,   // data output
   input  R,    // reset
   input  S     // set
   );

`ifdef XILINX
   IDDR2 #(
     .DDR_ALIGNMENT("NONE"),
     .INIT_Q0(1'b0),
     .INIT_Q1(1'b0), 
     .SRTYPE("SYNC"))
   IDDR2_inst (
     .Q0(Q0),
     .Q1(Q1),
     .C0(C0),
     .C1(C1),
     .CE(CE),
     .D(D),
     .R(R),
     .S(S)
   );
`endif   // XILINX

`ifdef ALTERA
   altddio_in #(
     .WIDTH(1),
     .POWER_UP_HIGH("OFF"),
     .INTENDED_DEVICE_FAMILY("Stratix III"))
   altddio_in_inst (
     .aset(),
     .datain(D),
     .inclocken(CE),
     .inclock(C0),
     .aclr(R),
     .dataout_h(Q0),
     .dataout_l(Q1)
   );
`endif   // ALTERA

`ifdef GENERIC_PRIMITIVES
   reg Q0_i, Q1_i;
   always @ (posedge R or posedge C0)
     if (R)
       Q0_i <= 1'b0;
     else
       Q0_i <= D;

   assign Q0 = Q0_i;

   always @ (posedge R or posedge C1)
     if (R)
       Q1_i <= 1'b0;
     else
       Q1_i <= D;

   assign Q1 = Q1_i;
`endif   // GENERIC_PRIMITIVES

endmodule   // ddr_ff_in


module ddr_ff_out
  (
   input  C0,   // clock
   input  C1,   // clock
   input  D0,   // data input
   input  D1,   // data input
   input  CE,   // clock enable
   output Q,    // data output
   input  R,    // reset
   input  S     // set
   );

`ifdef XILINX
   ODDR2 #(
     .DDR_ALIGNMENT("NONE"),
     .INIT(1'b0),
     .SRTYPE("SYNC"))
   ODDR2_inst (
     .Q(Q),
     .C0(C0),
     .C1(C1),
     .CE(CE),
     .D0(D0),
     .D1(D1),
     .R(R),
     .S(S)
   );
`endif   // XILINX

`ifdef ALTERA
   altddio_out #(
     .WIDTH(1),
     .POWER_UP_HIGH("OFF"),
     .INTENDED_DEVICE_FAMILY("Stratix III"),
     .OE_REG("UNUSED"))
   altddio_out_inst (
     .aset(),
     .datain_h(D0),
     .datain_l(D1),
     .outclocken(CE),
     .outclock(C0),
     .aclr(R),
     .dataout(Q)
   );
`endif   // ALTERA

`ifdef GENERIC_PRIMITIVES
   reg Q0, Q1;
   always @ (posedge R or posedge C0)
     if (R)
       Q0 <= 1'b0;
     else
       Q0 <= D0;

   always @ (posedge R or posedge C1)
     if (R)
       Q1 <= 1'b0;
     else
       Q1 <= D1;
 
   assign Q = C0 ? Q0 : Q1;
`endif   // GENERIC_PRIMITIVES

endmodule   // ddr_ff_out

`include "versatile_mem_ctrl_defines.v"

module dcm_pll
  (
   input  rst,          // reset
   input  clk_in,       // clock in
   input  clkfb_in,     // feedback clock in
   output clk0_out,     // clock out
   output clk90_out,    // clock out, 90 degree phase shift
   output clk180_out,   // clock out, 180 degree phase shift
   output clk270_out,   // clock out, 270 degree phase shift
   output clkfb_out     // feedback clock out
   );

`ifdef XILINX
   wire clk_in_ibufg;
   wire clk0_bufg, clk90_bufg, clk180_bufg, clk270_bufg;
   // DCM with internal feedback
   DCM #(
      .CLKDV_DIVIDE(2.0),
      .CLKFX_DIVIDE(1),
      .CLKFX_MULTIPLY(4),
      .CLKIN_DIVIDE_BY_2("FALSE"), 
      .CLKIN_PERIOD(8.0),
      .CLKOUT_PHASE_SHIFT("NONE"), 
      .CLK_FEEDBACK("1X"), 
      .DESKEW_ADJUST("SYSTEM_SYNCHRONOUS"), 
      .DLL_FREQUENCY_MODE("LOW"), 
      .DUTY_CYCLE_CORRECTION("TRUE"), 
      .PHASE_SHIFT(0), 
      .STARTUP_WAIT("FALSE")) 
   DCM_internal (
      .CLK0(clk0_bufg),
      .CLK180(clk180_bufg),
      .CLK270(clk270_bufg),
      .CLK2X(),
      .CLK2X180(),
      .CLK90(clk90_bufg),
      .CLKDV(),
      .CLKFX(),
      .CLKFX180(),
      .LOCKED(),
      .PSDONE(),
      .STATUS(),
      .CLKFB(clk0_out),
      .CLKIN(clk_in_ibufg),
      .DSSEN(),
      .PSCLK(),
      .PSEN(),
      .PSINCDEC(),
      .RST(rst)
   );
   // DCM with external feedback
   DCM #(
      .CLKDV_DIVIDE(2.0),
      .CLKFX_DIVIDE(1),
      .CLKFX_MULTIPLY(4),
      .CLKIN_DIVIDE_BY_2("FALSE"), 
      .CLKIN_PERIOD(8.0),
      .CLKOUT_PHASE_SHIFT("NONE"), 
      .CLK_FEEDBACK("1X"), 
      .DESKEW_ADJUST("SYSTEM_SYNCHRONOUS"), 
      .DLL_FREQUENCY_MODE("LOW"), 
      .DUTY_CYCLE_CORRECTION("TRUE"), 
      .PHASE_SHIFT(0), 
      .STARTUP_WAIT("FALSE")) 
   DCM_external (
      .CLK0(clkfb_bufg),
      .CLK180(),
      .CLK270(),
      .CLK2X(),
      .CLK2X180(),
      .CLK90(),
      .CLKDV(),
      .CLKFX(),
      .CLKFX180(),
      .LOCKED(),
      .PSDONE(),
      .STATUS(),
      .CLKFB(clkfb_ibufg),
      .CLKIN(clk_in_ibufg),
      .DSSEN(),
      .PSCLK(),
      .PSEN(),
      .PSINCDEC(),
      .RST(rst)
   );

   // Input buffer on DCM clock source
   IBUFG IBUFG_clk (
     .I(clk_in),
     .O(clk_in_ibufg));

   // Global buffers on DCM generated clocks
   BUFG BUFG_0 (
     .I(clk0_bufg),
     .O(clk0_out));
   BUFG BUFG_90 (
     .I(clk90_bufg),
     .O(clk90_out));
   BUFG BUFG_180 (
     .I(clk180_bufg),
     .O(clk180_out));
   BUFG BUFG_270 (
     .I(clk270_bufg),
     .O(clk270_out));

   // External feedback to DCM
   IBUFG IBUFG_clkfb (
     .I(clkfb_in),
     .O(clkfb_ibufg));
   OBUF OBUF_clkfb (
     .I(clkfb_bufg),
     .O(clkfb_out));
`endif   // XILINX


`ifdef ALTERA
   wire [9:0] sub_wire0;
   wire [0:0] sub_wire8 = 1'h0;
   wire [3:3] sub_wire4 = sub_wire0[3:3];
   wire [2:2] sub_wire3 = sub_wire0[2:2];
   wire [1:1] sub_wire2 = sub_wire0[1:1];
   wire [0:0] sub_wire1 = sub_wire0[0:0];
   wire       sub_wire6 = clk_in;
   wire [1:0] sub_wire7 = {sub_wire8, sub_wire6};

   assign clk0_out   = sub_wire1;	
   assign clk90_out  = sub_wire2;	
   assign clk180_out = sub_wire3;	
   assign clk270_out = sub_wire4;	

   // PLL with external feedback
   altpll #(
     .bandwidth_type("AUTO"),
     .clk0_divide_by(1),
     .clk0_duty_cycle(50),
     .clk0_multiply_by(1),
     .clk0_phase_shift("0"),
     .clk1_divide_by(1),
     .clk1_duty_cycle(50),
     .clk1_multiply_by(1),
     .clk1_phase_shift("1250"),
     .clk2_divide_by(1),
     .clk2_duty_cycle(50),
     .clk2_multiply_by(1),
     .clk2_phase_shift("2500"),
     .clk3_divide_by(1),
     .clk3_duty_cycle(50),
     .clk3_multiply_by(1),
     .clk3_phase_shift("3750"),
     .compensate_clock("CLK0"),
     .inclk0_input_frequency(5000),
     .intended_device_family("Stratix III"),
     .lpm_hint("UNUSED"),
     .lpm_type("altpll"),
     .operation_mode("NORMAL"),
//   .operation_mode("SOURCE_SYNCHRONOUS"),
     .pll_type("AUTO"),
     .port_activeclock("PORT_UNUSED"),
     .port_areset("PORT_USED"),
     .port_clkbad0("PORT_UNUSED"),
     .port_clkbad1("PORT_UNUSED"),
     .port_clkloss("PORT_UNUSED"),
     .port_clkswitch("PORT_UNUSED"),
     .port_configupdate("PORT_UNUSED"),
     .port_fbin("PORT_USED"),
     .port_fbout("PORT_USED"),
     .port_inclk0("PORT_USED"),
     .port_inclk1("PORT_UNUSED"),
     .port_locked("PORT_UNUSED"),
     .port_pfdena("PORT_UNUSED"),
     .port_phasecounterselect("PORT_UNUSED"),
     .port_phasedone("PORT_UNUSED"),
     .port_phasestep("PORT_UNUSED"),
     .port_phaseupdown("PORT_UNUSED"),
     .port_pllena("PORT_UNUSED"),
     .port_scanaclr("PORT_UNUSED"),
     .port_scanclk("PORT_UNUSED"),
     .port_scanclkena("PORT_UNUSED"),
     .port_scandata("PORT_UNUSED"),
     .port_scandataout("PORT_UNUSED"),
     .port_scandone("PORT_UNUSED"),
     .port_scanread("PORT_UNUSED"),
     .port_scanwrite("PORT_UNUSED"),
     .port_clk0("PORT_USED"),
     .port_clk1("PORT_USED"),
     .port_clk2("PORT_USED"),
     .port_clk3("PORT_USED"),
     .port_clk4("PORT_UNUSED"),
     .port_clk5("PORT_UNUSED"),
     .port_clk6("PORT_UNUSED"),
     .port_clk7("PORT_UNUSED"),
     .port_clk8("PORT_UNUSED"),
     .port_clk9("PORT_UNUSED"),
     .port_clkena0("PORT_UNUSED"),
     .port_clkena1("PORT_UNUSED"),
     .port_clkena2("PORT_UNUSED"),
     .port_clkena3("PORT_UNUSED"),
     .port_clkena4("PORT_UNUSED"),
     .port_clkena5("PORT_UNUSED"),
     .using_fbmimicbidir_port("OFF"),
     .width_clock(10))
   altpll_internal (
     .fbin (),//(clkfb_in),
     .inclk (sub_wire7),
     .areset (rst),
     .clk (sub_wire0),
     .fbout (),//(clkfb_out),
     .activeclock (),
     .clkbad (),
     .clkena ({6{1'b1}}),
     .clkloss (),
     .clkswitch (1'b0),
     .configupdate (1'b0),
     .enable0 (),
     .enable1 (),
     .extclk (),
     .extclkena ({4{1'b1}}),
     .fbmimicbidir (),
     .locked (),
     .pfdena (1'b1),
     .phasecounterselect ({4{1'b1}}),
     .phasedone (),
     .phasestep (1'b1),
     .phaseupdown (1'b1),
     .pllena (1'b1),
     .scanaclr (1'b0),
     .scanclk (1'b0),
     .scanclkena (1'b1),
     .scandata (1'b0),
     .scandataout (),
     .scandone (),
     .scanread (1'b0),
     .scanwrite (1'b0),
     .sclkout0 (),
     .sclkout1 (),
     .vcooverrange (),
     .vcounderrange ()
   );
`endif   // ALTERA

//`ifdef GENERIC_PRIMITIVES
//`endif   // GENERIC_PRIMITIVES


endmodule   // dcm_pll


module dff_sr (aclr, aset, clock, data, q);

  input	 aclr;
  input	 aset;
  input	 clock;
  input	 data;
  output q;

  wire  data_in = data;
  wire  data_out;
  wire  q = data_out;

`ifdef XILINX
  FDCP FDCP_inst (
    .Q(data_out),
    .C(clock),
    .CLR(aclr),
    .D(data_in),
    .PRE(aset));
  defparam
    FDCP_inst.INIT = 1'b0;
`endif   // XILINX

`ifdef ALTERA
  lpm_ff lpm_ff_inst (
    .aclr(aclr),
    .clock(clock),
    .data(data_in),
    .aset(aset),
    .aload(),
    .enable(),
    .sclr(),
    .sload(),
    .sset(),
    .q(data_out));
  defparam
    lpm_ff_inst.lpm_fftype = "DFF",
    lpm_ff_inst.lpm_type = "LPM_FF",
    lpm_ff_inst.lpm_width = 1;
`endif   // ALTERA

endmodule

module versatile_mem_ctrl_ddr (
  // DDR2 SDRAM side
  ck_o, ck_n_o, 
  dq_io, dqs_io, dqs_n_io, 
  dm_rdqs_io,
  //rdqs_n_i, odt_o, 
  // Memory controller side
  tx_dat_i, rx_dat_o,
  dq_en, dqm_en,
  wb_rst, sdram_clk_0, sdram_clk_90, sdram_clk_180, sdram_clk_270
  );

  output        ck_o;
  output        ck_n_o;
  inout  [15:0] dq_io;
  inout   [1:0] dqs_io;
  inout   [1:0] dqs_n_io;
  inout   [1:0] dm_rdqs_io;
  //input   [1:0] rdqs_n_i;
  //output        odt_o;
  input  [35:0] tx_dat_i;
  output [35:0] rx_dat_o;
  input         dq_en;
  input         dqm_en;
  input         wb_rst;
  input         sdram_clk_0;
  input         sdram_clk_90;
  input         sdram_clk_180;
  input         sdram_clk_270;

  reg    [31:0] dq_rx_reg;
  wire   [31:0] dq_rx;
  wire    [1:0] dqs_o, dqs_n_o, dqm_o;
  wire   [15:0] dq_o;
  wire    [1:0] dqs_delayed;
  wire    [1:0] dqs_n_delayed;

  genvar        i;

  // Generate clock with equal delay as data
  ddr_ff_out ddr_ff_out_ck (
    .Q(ck_o),
    .C0(sdram_clk_0),
    .C1(sdram_clk_180),
    .CE(1'b1),
    .D0(1'b1),
    .D1(1'b0),
    .R(1'b0),
    .S(1'b0));

  ddr_ff_out ddr_ff_out_ck_n (
    .Q(ck_n_o),
    .C0(sdram_clk_0),
    .C1(sdram_clk_180),
    .CE(1'b1),
    .D0(1'b0),
    .D1(1'b1),
    .R(wb_rst),
    .S(1'b0));

  // Generate strobe with equal delay as data
  generate
    for (i=0; i<2; i=i+1) begin:dqs_oddr
      ddr_ff_out ddr_ff_out_dqs (
        .Q(dqs_o[i]),
        .C0(sdram_clk_0),
        .C1(sdram_clk_180),
        .CE(1'b1),
        .D0(1'b1),
        .D1(1'b0),
        .R(1'b0),
        .S(1'b0));
    end
  endgenerate

  generate
    for (i=0; i<2; i=i+1) begin:dqs_n_oddr
      ddr_ff_out ddr_ff_out_dqs_n (
        .Q(dqs_n_o[i]),
        .C0(sdram_clk_0),
        .C1(sdram_clk_180),
        .CE(1'b1),
        .D0(1'b0),
        .D1(1'b1),
        .R(wb_rst),
        .S(1'b0));
    end
  endgenerate

  // Assign outports
  assign dqs_io   = dq_en ? dqs_o : 2'bz;
  assign dqs_n_io = dq_en ? dqs_n_o : 2'bz;


`ifdef XILINX   

  reg  [15:0] dq_tx_reg;
  wire [15:0] dq_tx;
  reg   [3:0] dqm_tx_reg;
  wire  [3:0] dqm_tx;

  // Data out
  // Data from Tx FIFO
  always @ (posedge sdram_clk_270 or posedge wb_rst)
    if (wb_rst)
      dq_tx_reg[15:0] <= 16'h0;
    else
      if (dqm_en)
        dq_tx_reg[15:0] <= tx_dat_i[19:4];
      else
        dq_tx_reg[15:0] <= tx_dat_i[19:4];

  assign dq_tx[15:0] = tx_dat_i[35:20];

  // DDR flip-flops
  generate
    for (i=0; i<16; i=i+1) begin:data_out_oddr
      ddr_ff_out ddr_ff_out_inst_0 (
        .Q(dq_o[i]),
        .C0(sdram_clk_270),
        .C1(sdram_clk_90),
        .CE(dq_en),
        .D0(dq_tx[i]),
        .D1(dq_tx_reg[i]),
        .R(wb_rst),
        .S(1'b0));
    end
  endgenerate

  // Assign outports
  assign dq_io = dq_en ? dq_o : {16{1'bz}};

  // Data mask
  // Data mask from Tx FIFO
  always @ (posedge sdram_clk_270 or posedge wb_rst)
    if (wb_rst)
      dqm_tx_reg[1:0] <= 2'b00;
    else
      if (dqm_en)
        dqm_tx_reg[1:0] <= 2'b00;
      else
        dqm_tx_reg[1:0] <= tx_dat_i[1:0];

  always @ (posedge sdram_clk_180 or posedge wb_rst)
    if (wb_rst)
      dqm_tx_reg[3:2]  <= 2'b00;
    else
      if (dqm_en)
        dqm_tx_reg[3:2]  <= 2'b00;
      else
        dqm_tx_reg[3:2]  <= tx_dat_i[3:2];

  assign dqm_tx[1:0] = (dqm_en) ? 2'b00 : tx_dat_i[3:2];

  // DDR flip-flops
  generate
    for (i=0; i<2; i=i+1) begin:data_mask_oddr
      ddr_ff_out ddr_ff_out_inst_1 (
        .Q(dqm_o[i]),
        .C0(sdram_clk_270),
        .C1(sdram_clk_90),
        .CE(dq_en),
        .D0(!dqm_tx[i]),
        .D1(!dqm_tx_reg[i]),
        .R(wb_rst),
        .S(1'b0));
    end
  endgenerate

  // Assign outport
  assign dm_rdqs_io = dq_en ? dqm_o : 2'bzz;
    
  // Data in
  `ifdef INT_CLOCKED_DATA_CAPTURE
  // DDR flip-flops
  generate
    for (i=0; i<16; i=i+1) begin:iddr2gen
      ddr_ff_in ddr_ff_in_inst_0 (
        .Q0(dq_rx[i]), 
        .Q1(dq_rx[i+16]), 
        .C0(sdram_clk_270), 
        .C1(sdram_clk_90),
        .CE(1'b1), 
        .D(dq_io[i]),   
        .R(wb_rst),  
        .S(1'b0));
    end
  endgenerate

  // Data to Rx FIFO
  always @ (posedge sdram_clk_0 or posedge wb_rst)
    if (wb_rst)
      dq_rx_reg[31:16] <= 16'h0;
    else
      dq_rx_reg[31:16] <= dq_rx[31:16];

  always @ (posedge sdram_clk_180 or posedge wb_rst)
    if (wb_rst)
      dq_rx_reg[15:0] <= 16'h0;
    else
      dq_rx_reg[15:0] <= dq_rx[15:0];

  assign rx_dat_o = {dq_rx_reg, 4'h0};
  `endif   // INT_CLOCKED_DATA_CAPTURE

  `ifdef DEL_DQS_DATA_CAPTURE_1
   // Delay DQS
   // DDR FF
  `endif   // DEL_DQS_DATA_CAPTURE_1

  `ifdef DEL_DQS_DATA_CAPTURE_2
   // DDR data to IOBUF
   // Delay data (?)
   // IDDR FF
   // Rise & fall clocked FF
   // Fall sync FF
   // Mux
   // DDR DQS to IODUFDS
   // Delay DQS
   // BUFIO (?)
  `endif   // DEL_DQS_DATA_CAPTURE_2

`endif   // XILINX

`ifdef ALTERA

  wire  [3:0] dqm_tx;

  // Data out
  // DDR flip-flops
  generate
    for (i=0; i<16; i=i+1) begin:data_out_oddr
      ddr_ff_out ddr_ff_out_inst_0 (
        .Q(dq_o[i]),
        .C0(sdram_clk_270),
        .C1(sdram_clk_90),
        .CE(dq_en),
        .D0(tx_dat_i[i+16+4]),
        .D1(tx_dat_i[i+4]),
        .R(wb_rst),
        .S(1'b0));
    end
  endgenerate

  // Assign outport
  assign dq_io = dq_en ? dq_o : {16{1'bz}};

  // Data mask
  // Data mask from Tx FIFO
  assign dqm_tx = dqm_en ? {4{1'b0}} : tx_dat_i[3:0];

  // DDR flip-flops
  generate
    for (i=0; i<2; i=i+1) begin:data_mask_oddr
      ddr_ff_out ddr_ff_out_inst_1 (
        .Q(dqm_o[i]),
        .C0(sdram_clk_270),
        .C1(sdram_clk_90),
        .CE(dq_en),
        .D0(!dqm_tx[i+2]),
        .D1(!dqm_tx[i]),
        .R(wb_rst),
        .S(1'b0));
    end
  endgenerate

  // Assign outport
  assign dm_rdqs_io = dq_en ? dqm_o : 2'bzz;


  // Data in
  `ifdef INT_CLOCKED_DATA_CAPTURE
  // DDR flip-flops
  generate
    for (i=0; i<16; i=i+1) begin:iddr2gen
      ddr_ff_in ddr_ff_in_inst_0 (
        .Q0(dq_rx[i]), 
        .Q1(dq_rx[i+16]), 
        .C0(sdram_clk_270), 
        .C1(sdram_clk_90),
        .CE(1'b1), 
        .D(dq_io[i]),   
        .R(wb_rst),  
        .S(1'b0));
    end
  endgenerate

  // Data to Rx FIFO
  always @ (posedge sdram_clk_180 or posedge wb_rst)
    if (wb_rst)
      dq_rx_reg <= 32'h0;
    else
      dq_rx_reg <= dq_rx;

  assign rx_dat_o = {dq_rx_reg, 4'h0};
  `endif   // INT_CLOCKED_DATA_CAPTURE

  `ifdef DEL_DQS_DATA_CAPTURE_1
   // Delay DQS
   // DDR FF
  `endif   // DEL_DQS_DATA_CAPTURE_1

  `ifdef DEL_DQS_DATA_CAPTURE_2
   // DDR data to IOBUFFER
   // Delay data (?)
   // DDR FF
   // Rise & fall clocked FF
   // Fall sync FF
   // Mux
   // DDR DQS to IODUFDS
   // Delay DQS
   // BUFIO (?)
  `endif   // DEL_DQS_DATA_CAPTURE_2

`endif   // ALTERA


endmodule   // versatile_mem_ctrl_ddr


`include "versatile_mem_ctrl_defines.v"
`ifdef SDR_16
 `include "sdr_16_defines.v"
`endif
`ifdef DDR_16
 `include "ddr_16_defines.v"
`endif

module versatile_mem_ctrl_top
  (
    // wishbone side
    wb_adr_i_0, wb_dat_i_0, wb_dat_o_0,
    wb_stb_i_0, wb_cyc_i_0, wb_ack_o_0,
    wb_adr_i_1, wb_dat_i_1, wb_dat_o_1,
    wb_stb_i_1, wb_cyc_i_1, wb_ack_o_1,
    wb_adr_i_2, wb_dat_i_2, wb_dat_o_2,   // Fixed typo /MF
    wb_stb_i_2, wb_cyc_i_2, wb_ack_o_2,
    wb_adr_i_3, wb_dat_i_3, wb_dat_o_3,
    wb_stb_i_3, wb_cyc_i_3, wb_ack_o_3,
    wb_clk, wb_rst,

`ifdef SDR_16
    ba_pad_o, a_pad_o, cs_n_pad_o, ras_pad_o, cas_pad_o, we_pad_o, dq_o, dqm_pad_o, dq_i, dq_oe, cke_pad_o,
`endif

`ifdef DDR_16
    ck_pad_o, ck_n_pad_o, cke_pad_o, ck_fb_pad_o, ck_fb_pad_i,
    cs_n_pad_o, ras_pad_o, cas_pad_o,  we_pad_o,
    dm_rdqs_pad_io,  ba_pad_o, addr_pad_o, dq_pad_io, dqs_pad_io, dqs_oe, dqs_n_pad_io, rdqs_n_pad_i, odt_pad_o,
`endif
   // SDRAM signals
   sdram_clk
   );

    // number of wb clock domains
    parameter nr_of_wb_clk_domains = 1;
    // number of wb ports in each wb clock domain
    parameter nr_of_wb_ports_clk0  = 3;
    parameter nr_of_wb_ports_clk1  = 0;
    parameter nr_of_wb_ports_clk2  = 0;
    parameter nr_of_wb_ports_clk3  = 0;
    
    parameter tot_nr_of_wb_ports = nr_of_wb_ports_clk0 + nr_of_wb_ports_clk1 + nr_of_wb_ports_clk2 + nr_of_wb_ports_clk3;

    input  [36*nr_of_wb_ports_clk0-1:0] wb_adr_i_0;
    input  [36*nr_of_wb_ports_clk0-1:0] wb_dat_i_0;
    output [31:0]                       wb_dat_o_0;
    input  [0:nr_of_wb_ports_clk0-1]    wb_stb_i_0, wb_cyc_i_0, wb_ack_o_0;
    
    input  [36*nr_of_wb_ports_clk1-1:0] wb_adr_i_1;
    input  [36*nr_of_wb_ports_clk1-1:0] wb_dat_i_1;
    output [31:0]                       wb_dat_o_1;
    input  [0:nr_of_wb_ports_clk1-1]    wb_stb_i_1, wb_cyc_i_1, wb_ack_o_1;
    
    input  [36*nr_of_wb_ports_clk2-1:0] wb_adr_i_2;   // Fixed typo /MF
    input  [36*nr_of_wb_ports_clk2-1:0] wb_dat_i_2;   // Fixed typo /MF
    output [31:0]                       wb_dat_o_2;
    input  [0:nr_of_wb_ports_clk2-1]    wb_stb_i_2, wb_cyc_i_2, wb_ack_o_2;
    
    input  [36*nr_of_wb_ports_clk3-1:0] wb_adr_i_3;
    input  [36*nr_of_wb_ports_clk3-1:0] wb_dat_i_3;
    output [31:0]                       wb_dat_o_3;
    input  [0:nr_of_wb_ports_clk3-1]    wb_stb_i_3, wb_cyc_i_3, wb_ack_o_3;
        
    input  [0:nr_of_wb_clk_domains-1]   wb_clk;
    input  [0:nr_of_wb_clk_domains-1]   wb_rst;
    
`ifdef SDR_16
   output  [1:0] ba_pad_o;
   output [12:0] a_pad_o;
   output        cs_n_pad_o;
   output        ras_pad_o;
   output        cas_pad_o;
   output        we_pad_o;
   output [15:0] dq_o;
   output  [1:0] dqm_pad_o;
   input  [15:0] dq_i;
   output        dq_oe;
   output        cke_pad_o;
`endif
`ifdef DDR_16
   output        ck_pad_o;
   output        ck_n_pad_o;
   output        cke_pad_o;
   output        ck_fb_pad_o;
   input         ck_fb_pad_i;
   output        cs_n_pad_o;
   output        ras_pad_o;
   output        cas_pad_o;
   output        we_pad_o;
   inout   [1:0] dm_rdqs_pad_io;
   output  [1:0] ba_pad_o;
   output [12:0] addr_pad_o;
   inout  [15:0] dq_pad_io;
   inout   [1:0] dqs_pad_io;
   output        dqs_oe;
   inout   [1:0] dqs_n_pad_io;
   input   [1:0] rdqs_n_pad_i;
   output        odt_pad_o;
`endif
    input        sdram_clk;

    wire [1:0] fifo_empty[0:15];
    wire [1:0] fifo_rd[0:15];
    wire [1:0] fifo_dat_o[35:0];
    wire [1:0] fifo_dat_i[31:0];
    wire [1:0] fifo_wr[0:15];

    wire [35:0] tx_fifo_dat_o;   // tmp added /MF
    
genvar i;

generate   
    if (nr_of_wb_clk_domains > 0) begin    
        versatile_mem_ctrl_wb
        # (.nr_of_wb_ports(nr_of_wb_ports_clk0))
        wb0(
            // wishbone side
            .wb_adr_i_v(wb_adr_i_0),
            .wb_dat_i_v(wb_dat_i_0),
            .wb_dat_o(wb_dat_o_0),
            .wb_stb_i(wb_stb_i_0),
            .wb_cyc_i(wb_cyc_i_0),
            .wb_ack_o(wb_ack_o_0),
            .wb_clk(wb_clk[0]),
            .wb_rst(wb_rst[0]),
            // SDRAM controller interface
            .sdram_dat_o(),
            .sdram_fifo_empty(fifo_empty[0][0:nr_of_wb_ports_clk0-1]),
            .sdram_fifo_rd(),
            .sdram_dat_i(),
            .sdram_fifo_wr(),
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
        wb0(
            // wishbone side
            .wb_adr_i_v(wb_adr_i_1),
            .wb_dat_i_v(wb_dat_i_1),
            .wb_dat_o(wb_dat_o_1),
            .wb_stb_i(wb_stb_i_1),
            .wb_cyc_i(wb_cyc_i_1),
            .wb_ack_o(wb_ack_o_1),
            .wb_clk(wb_clk[1]),
            .wb_rst(wb_rst[1]),
            // SDRAM controller interface
            .sdram_dat_o(),
            .sdram_fifo_empty(),
            .sdram_fifo_rd(),
            .sdram_dat_i(),
            .sdram_fifo_wr(),
            .sdram_clk(sdram_clk),
            .sdram_rst(sdram_rst) );
        if (nr_of_wb_ports_clk1 < 16) begin
            assign fifo_empty[1][nr_of_wb_ports_clk1:15] = {(16-nr_of_wb_ports_clk1){1'b1}};
        end
    end else begin
        assign fifo_empty[1] = {16{1'b1}};
    end
endgenerate

generate   
    if (nr_of_wb_clk_domains > 2) begin    
        versatile_mem_ctrl_wb
        # (.nr_of_wb_ports(nr_of_wb_ports_clk1))
        wb0(
            // wishbone side
            .wb_adr_i_v(wb_adr_i_2),
            .wb_dat_i_v(wb_dat_i_2),
            .wb_dat_o(wb_dat_o_2),
            .wb_stb_i(wb_stb_i_2),
            .wb_cyc_i(wb_cyc_i_2),
            .wb_ack_o(wb_ack_o_2),
            .wb_clk(wb_clk[2]),
            .wb_rst(wb_rst[2]),
            // SDRAM controller interface
            .sdram_dat_o(),
            .sdram_fifo_empty(),
            .sdram_fifo_rd(),
            .sdram_dat_i(),
            .sdram_fifo_wr(),
            .sdram_clk(sdram_clk),
            .sdram_rst(sdram_rst) );
        if (nr_of_wb_ports_clk2 < 16) begin
            assign fifo_empty[2][nr_of_wb_ports_clk2:15] = {(16-nr_of_wb_ports_clk2){1'b1}};
        end
    end else begin
        assign fifo_empty[2] = {16{1'b1}};
    end
endgenerate

generate   
    if (nr_of_wb_clk_domains > 3) begin    
        versatile_mem_ctrl_wb
        # (.nr_of_wb_ports(nr_of_wb_ports_clk3))
        wb0(
            // wishbone side
            .wb_adr_i_v(wb_adr_i_3),
            .wb_dat_i_v(wb_dat_i_3),
            .wb_dat_o(wb_dat_o_3),
            .wb_stb_i(wb_stb_i_3),
            .wb_cyc_i(wb_cyc_i_3),
            .wb_ack_o(wb_ack_o_3),
            .wb_clk(wb_clk[3]),
            .wb_rst(wb_rst[3]),
            // SDRAM controller interface
            .sdram_dat_o(),
            .sdram_fifo_empty(),
            .sdram_fifo_rd(),
            .sdram_dat_i(),
            .sdram_fifo_wr(),
            .sdram_clk(sdram_clk),
            .sdram_rst(sdram_rst) );
        if (nr_of_wb_ports_clk3 < 16) begin
            assign fifo_empty[3][nr_of_wb_ports_clk3:15] = {(16-nr_of_wb_ports_clk3){1'b1}};
        end
    end else begin
        assign fifo_empty[3] = {16{1'b1}};
    end
endgenerate

`ifdef SDR_16
   wire read;
   reg [15:0] dq_i_reg, dq_i_tmp_reg;   
   wire dq_hi, dq_lo;
   reg [15:0] dq;
      
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
      .dq_hi(dq_hi),
      .dq_lo(dq_lo),
      .dqm(dqm_pad_o),
      .dq_oe(dq_oe),
      .a({ba_pad_o,a_pad_o}),
      .cmd({ras_pad_o,cas_pad_o,we_pad_o}),
      .cs_n(cs_n_pad_o),
      .sdram_clk(sdram_clk_0),
      .wb_rst(wb_rst)
      );

   inc_adr inc_adr0
     (
      .adr_i(tx_fifo_dat_o[9:6]),
      .bte_i(tx_fifo_dat_o[4:3]),
      .cti_i(tx_fifo_dat_o[2:0]),
      .init(adr_init),
      .inc(adr_inc | rx_fifo_we),
      .adr_o(burst_adr),
      .done(done),
      .clk(sdram_clk_0),
      .rst(wb_rst)
      );

   assign sdram_clk_0 = sdram_clk;
   assign cke_pad_o = 1'b1;

   defparam delay0.depth=`CL+2;   
   defparam delay0.width=4;
   delay delay0
     (
      .d({read,tx_fifo_b_sel_i_cur}),
      .q({rx_fifo_we,rx_fifo_a_sel_i}),
      .clk(sdram_clk_0),
      .rst(wb_rst)
      );

   always @ (posedge sdram_clk_0 or posedge wb_rst)
     if (wb_rst)
       {dq_i_reg, dq_i_tmp_reg} <= {16'h0000,16'h0000};
     else
       {dq_i_reg, dq_i_tmp_reg} <= {dq_i, dq_i_reg};

   assign rx_fifo_dat_i = {dq_i_tmp_reg, dq_i_reg, 4'h0};

   always @ (posedge sdram_clk_0 or posedge wb_rst)
     if (wb_rst)
       dq <= 16'h0000;
     else
       if (dq_hi)
         dq <= tx_fifo_dat_o[35:20];
       else if (dq_lo)
         dq <= tx_fifo_dat_o[19:4];
       else
         dq <= 16'h0000;

   assign dq_o = dq;

`endif //  `ifdef SDR_16


`ifdef DDR_16
   wire        read, write;
   wire        sdram_clk_90, sdram_clk_180, sdram_clk_270;
   wire        ck_fb;
   reg         cke, ras, cas, we, cs_n;
   wire        ras_o, cas_o, we_o, cs_n_o;
   wire  [1:0] ba_o;
   wire [12:0] addr_o;
   reg   [1:0] ba;
   reg  [12:0] addr;
   wire        dq_en, dqm_en;
   reg  [15:0] dq_tx_reg;
   wire [15:0] dq_tx;
   reg  [31:0] dq_rx_reg;
   wire [31:0] dq_rx;
   wire [15:0] dq_o;
   reg   [3:0] dqm_tx_reg;
   wire  [3:0] dqm_tx;
   wire  [1:0] dqm_o, dqs_o, dqs_n_o;
   wire        ref_delay, ref_delay_ack;
   wire        bl_en, bl_ack;
   wire        tx_fifo_re_i;
   wire        adr_init_delay;
   reg         adr_init_delay_i;
   reg   [3:0] burst_cnt;
   wire  [3:0] burst_next_cnt, burst_length;
   wire        burst_mask;
   wire [12:0] cur_row;

   // DDR SDRAM 16 FSM
   ddr_16 ddr_16_0
     (
      .adr_init(adr_init),
      .fifo_re(tx_fifo_re_i),
      .fifo_re_d(tx_fifo_re),
      .tx_fifo_dat_o(tx_fifo_dat_o),
      .burst_adr(burst_adr),
      .fifo_empty(tx_fifo_empty),
      .fifo_sel(tx_fifo_b_sel_i_cur),
      .read(read),
      .write(write),
      .ref_req(ref_req),
      .ref_ack(ref_ack),
      .ref_delay(ref_delay),
      .ref_delay_ack(ref_delay_ack),
      .bl_en(bl_en),
      .bl_ack(bl_ack),
      .a({ba_o,addr_o}),
      .cmd({ras_o,cas_o,we_o}),
      .cs_n(cs_n_o),
      .cur_row(cur_row),
      .sdram_clk(sdram_clk_0),
      .wb_rst(wb_rst)
      );

   inc_adr inc_adr0
     (
      .adr_i(tx_fifo_dat_o[9:6]),
      .bte_i(tx_fifo_dat_o[4:3]),
      .cti_i(tx_fifo_dat_o[2:0]),
      .init(adr_init),
      .inc(),
      .adr_o(burst_adr),
      .done(done),
      .clk(sdram_clk_0),
      .rst(wb_rst)
      );

   // Delay, refresh to activate/refresh
   ref_delay_counter ref_delay_counter0
     (
      .cke(ref_delay),
      .zq(ref_delay_ack),
      .clk(sdram_clk_0),
      .rst(wb_rst)
      );
   
   // Burst length, DDR2 SDRAM
   burst_length_counter burst_length_counter0
     (
      .cke(bl_en),
      .zq(bl_ack),
      .clk(sdram_clk_0),
      .rst(wb_rst)
      );

   // Wishbone burst length
   assign burst_length = (adr_init && tx_fifo_dat_o[2:0] == 3'b000) ? 4'd1 :   // classic cycle
                         (adr_init && tx_fifo_dat_o[2:0] == 3'b010) ? 4'd4 :   // incremental burst cycle
                          burst_length;

   // Burst mask
   // Burst length counter
   assign burst_next_cnt = (burst_cnt == 3) ? 4'd0 : burst_cnt + 4'd1;
   always @ (posedge sdram_clk_0 or posedge wb_rst)
     if (wb_rst)
       burst_cnt <= 4'h0;
     else
       if (bl_en)
         burst_cnt <= burst_next_cnt;
   // Burst Mask
   assign burst_mask = (burst_cnt >= burst_length) ? 1'b1 : 1'b0;

   // Control outports, DDR2 SDRAM
   always @ (posedge sdram_clk_180 or posedge wb_rst)
     if (wb_rst) begin
       cs_n <= 1'b0;
       cke  <= 1'b0;
       ras  <= 1'b0;
       cas  <= 1'b0;
       we   <= 1'b0;
       ba   <= 2'b00;
       addr <= 13'b0000000000000;
     end
     else begin
       cs_n <= cs_n_o;
       cke  <= 1'b1;
       ras  <= ras_o;
       cas  <= cas_o;
       we   <= we_o;
       ba   <= ba_o;
       addr <= addr_o;
     end

   assign cke_pad_o  = cke;
   assign ras_pad_o  = ras;
   assign cas_pad_o  = cas;
   assign we_pad_o   = we;
   assign ba_pad_o   = ba;
   assign addr_pad_o = addr;
   assign cs_n_pad_o = cs_n;


   // Read latency, delay the control signals to fit latency of the DDR2 SDRAM
   defparam delay0.depth=`CL+`AL+2; 
   defparam delay0.width=4;
   delay delay0 (
      .d({read && !burst_mask,tx_fifo_b_sel_i_cur}),
      .q({rx_fifo_we,rx_fifo_a_sel_i}),
      .clk(sdram_clk_0),
      .rst(wb_rst)
      );
   
   // write latency, delay the control signals to fit latency of the DDR2 SDRAM
   defparam delay1.depth=`CL+`AL-1;
   defparam delay1.width=2;
   delay delay1 (
      .d({write, burst_mask}),
      .q({dq_en, dqm_en}),
      .clk(sdram_clk_270),
      .rst(wb_rst)
      );

   // if CL>3 delay read from Tx FIFO
   defparam delay2.depth=`CL+`AL-3;
   defparam delay2.width=1;
   delay delay2 (
      .d(tx_fifo_re_i && !burst_mask),
      .q(tx_fifo_re),
      .clk(sdram_clk_0),
      .rst(wb_rst)
      );

   // if CL=3, no delay
   //assign tx_fifo_re = tx_fifo_re_i && !burst_mask;

   // Increment address
   defparam delay3.depth=`CL+`AL-1;
   defparam delay3.width=1;
   delay delay3 (
      .d({write|read}),
      .q({adr_inc}),
      .clk(sdram_clk_0),
      .rst(wb_rst)
      );

   // DCM/PLL with internal and external feedback
   // Remove skew from internal and external clock
   // Parameters are set in dcm_pll.v
   dcm_pll dcm_pll_0 (
      .rst(wb_rst),
      .clk_in(sdram_clk),
      .clkfb_in(ck_fb_pad_i),
      .clk0_out(sdram_clk_0),
      .clk90_out(sdram_clk_90),
      .clk180_out(sdram_clk_180),
      .clk270_out(sdram_clk_270),
      .clkfb_out(ck_fb)
      );

   // DDR2 IF
   versatile_mem_ctrl_ddr versatile_mem_ctrl_ddr_0 (
      // DDR2 SDRAM ports
      .ck_o(ck_pad_o),
      .ck_n_o(ck_n_pad_o),
      .dq_io(dq_pad_io),
      .dqs_io(dqs_pad_io),
      .dqs_n_io(dqs_n_pad_io), 
      .dm_rdqs_io(dm_rdqs_pad_io),
      // Memory controller side
      .tx_dat_i(tx_fifo_dat_o),
      .rx_dat_o(rx_fifo_dat_i),
      .dq_en(dq_en),
      .dqm_en(dqm_en),
      .wb_rst(wb_rst),
      .sdram_clk_0(sdram_clk_0),
      .sdram_clk_90(sdram_clk_90),
      .sdram_clk_180(sdram_clk_180),
      .sdram_clk_270(sdram_clk_270));

   // Assing outputs
   // Non-DDR outputs
   assign ba_pad_o     = ba;
   assign addr_pad_o   = addr;
   assign dqs_oe       = dq_en;
   assign cke_pad_o    = cke;
   assign ras_pad_o    = ras;
   assign cas_pad_o    = cas;
   assign we_pad_o     = we;
   assign cs_n_pad_o   = cs_n;
   assign ck_fb_pad_o  = ck_fb;

`endif //  `ifdef DDR_16
   
endmodule // wb_sdram_ctrl_top
