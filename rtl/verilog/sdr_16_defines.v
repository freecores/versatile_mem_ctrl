//
// Specify either type of memory
// or
// BA_SIZE, ROW_SIZE, COL_SIZE and SDRAM_DATA_WIDTH
//
// either in this file or as command line option; +define+MT48LC16M16
//

// Most of these defines have an effect on things in fsm_sdr_16.v

`define MT48LC16M16 // 32MB part
//`define MT48LC4M16  //  8MB part


// SDRAM clock frequency
// set refresh counter timeout
// all rows should be refreshed every 64 ms
`define SDRAM_CLK_64
//`define SDRAM_CLK_125
//`define SDRAM_CLK_133
//`define SDRAM_CLK_154

// Define this to allow indication that a burst read is still going
// to the wishbone state machine, so it doesn't start emptying the
// ingress fifo after a aborted burst before the burst read is
// actually finished.
//`define SDRAM_WB_SAME_CLOCKS


`ifdef MT48LC16M16
// using 1 of MT48LC16M16
// SDRAM data width is 16
  
`define SDRAM_DATA_WIDTH 16
`define COL_SIZE 9  
`define ROW_SIZE 13
`define BA_SIZE 2

`endif //  `ifdef MT48LC16M16

`ifdef MT48LC4M16
// using 1 of MT48LC4M16
// SDRAM data width is 16
  
`define SDRAM_DATA_WIDTH 16
`define COL_SIZE 8  
`define ROW_SIZE 12
`define BA_SIZE 2

`endif //  `ifdef MT48LC4M16

// LMR
// [12:10] reserved
// [9]     WB, write burst; 0 - programmed burst length, 1 - single location
// [8:7]   OP Mode, 2'b00
// [6:4]   CAS Latency; 3'b010 - 2, 3'b011 - 3
// [3]     BT, Burst Type; 1'b0 - sequential, 1'b1 - interleaved
// [2:0]   Burst length; 3'b000 - 1, 3'b001 - 2, 3'b010 - 4, 3'b011 - 8, 3'b111 - full page
`define INIT_WB 1'b0
`define INIT_CL 3'b010
`define INIT_BT 1'b0
`define INIT_BL 3'b001
