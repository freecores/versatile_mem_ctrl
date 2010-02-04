`timescale 1ns/1ns


//
// Specify either type of memory
// or
// BA_SIZE, ROW_SIZE, COL_SIZE and SDRAM_DATA_WIDTH
//
// either in this file or as command line option; +define+MT48LC16M16
//

// number of adr lines to use
// 2^2 = 4 32 bit word burst
//`define BURST_SIZE 2


// DDR2 SDRAM
// MT47H32M16 – 8 Meg x 16 x 4 banks
`define MT47H32M16
`ifdef MT47H32M16
// using 1 of MT47H32M16
// SDRAM data width is 16
`define BURST_SIZE 4  
`define SDRAM_DATA_WIDTH 16
`define COL_SIZE 10  
`define ROW_SIZE 13
`define BA_SIZE 2

`define SDRAM16
`define BA tx_fifo_dat_o[28:27]
`define ROW tx_fifo_dat_o[26:14]
`define COL {4'b0000,tx_fifo_dat_o[13:10],burst_adr,1'b0}
`define WORD_SIZE 1
`define WB_ADR_HI 24
`define WB_ADR_LO 2

// Mode Register (MR) Definition
// [16]    (BA2)   1'b0
// [15:14] (BA1-0) Mode Register Definition (MR): 2'b00 - Mode Register (MR)
// [13]    (A13)   1'b0
// [12]    (A12)   PD Mode (PD): 1'b0 - Fast exit (normal), 1'b1 - Slow exit (low power)
// [11:9]  (A11-9) Write Recovery (WR): 3'b000 - reserved, 3b'001 - 2, ... , 3b'111 - 8
// [8]     (A8)    DLL Reset (DLL): 1'b0 - No, 1'b1 - Yes
// [7]     (A7)    Mode (TM): 1'b0 - Normal, 1'b1 - Test
// [6]     (A6)    CAS#
// [5:4]   (A5-4)  CAS Latency (CL): 3'b011 - 3, ... , 3'b111 - 7
// [3]     (A3)    Burst Type (BT): 1'b0 - Sequential, 1'b1 - Interleaved
// [2:0]   (A2-0)  Burst Length (BL): 3'b010 - 4, 3'b011 - 8
`define MR  2'b00
`define PD  1'b0
`define WR  3'b001
`define DLL 1'b0
`define TM  1'b0
`define CAS 1'b0
`define CL  3'b100
`define BT  1'b0
`define BL  3'b011

// Extended Mode Register (EMR) Definition
// [16]    (BA2)    1'b0
// [15:14] (BA1-0)  Mode Register Set (MRS): 2'b01 - Extended Mode Register (EMR)
// [13]    (A13)    1'b0
// [12]    (A12)    Outputs (OUT): 1'b0 - Enabled, 1'b1 - Disabled
// [11]    (A11)    RDQS Enable (RDQS): 1'b0 - Enabled, 1'b1 - Disabled
// [10]    (A10)    DQS# Enable (DQS): 1'b0 - Enabled, 1'b1 - Disabled
// [9:7]   (A9-7)   OCD Opearation (OCD): 3'b000 - OCD exit, 3b'111 - Enable OCD defaults
// [6,2]   (A6, A2) RTT Nominal (RTT6,2): 2'b00 - Disabled, 2'b01 - 75 ohm, 
//                                        2'b10 - 150 ohm, 2'b11 - 50 ohm,
// [5:3]   (A5-3)   Posted CAS# Additive Latenct (AL): 3'b000 - 0, ... , 3'b110 - 6
// [1]     (A1)     Output Drive Strength (ODS): 1'b0 - Full, 1'b1 - Reduced
// [0]     (A0)     DLL Enable (DLL_EN): 1'b0 - Enable (normal), 1'b1 - Disable (test/debug)
`define MRS    2'b01
`define OUT    1'b0
`define RDQS   1'b0
`define DQS    1'b0
`define OCD    3'b000
`define RTT6   1'b0
`define RTT2   1'b0
`define AL     3'b000
`define ODS    1'b0
`define DLL_EN 1'b0

// Extended Mode Register 2 (EMR2) Definition
// [16]    (BA2)    1'b0
// [15:14] (BA1-0)  Mode Register Set (MRS2): 2'b10 - Extended Mode Register 2 (EMR2)
// [13:8]  (A13-8)  6'b000000
// [7]     (A7)     SRT Enable (SRT): 1'b0 - 1x refresh rate (0 - 85 C), 
//                                    1'b1 - 2x refresh rate (> 85 C)
// [6:0]   (A6-0)   7'b0000000
`define MRS2 2'b10
`define SRT  1'b0

// Extended Mode Register 3 (EMR3) Definition
// [16]    (BA2)    1'b0
// [15:14] (BA1-0)  Mode Register Set (MRS): 2'b11 - Extended Mode Register 2 (EMR2)
// [13:0]  (A13-0)  14'b00000000000000
`define MRS3 2'b11

// Addr to SDRAM {ba[1:0],a[12:0]}
`define A_LMR         {`MR,`PD,`WR,`DLL,`TM,`CAS,`CL,`BT,`BL}
`define A_LMR_DLL_RST {2'b00,1'b0,`WR,1'b0,1'b1,1'b0,`CL,1'b0,`BL}
//`define A_LMR_DLL_RST {2'b00,4'b0000,1'b1,8'b00000000}
`define A_LMR     {`MR,`PD,`WR,`DLL,`TM,`CAS,`CL,`BT,`BL}
`define A_LEMR    {`MRS,`OUT,`RDQS,`DQS,`OCD,`RTT6,`AL,`RTT2,`ODS,`DLL_EN}
`define A_LEMR_OCD_DEFAULT    {`MRS,`OUT,`RDQS,`DQS,3'b111,`RTT6,`AL,`RTT2,`ODS,`DLL}
`define A_LEMR2   {`MRS2,5'b00000,`SRT,7'b0000000}
`define A_LEMR3   {`MRS3,13'b0000000000000}
`define A_PRE     {2'b00,13'b0010000000000}
`define A_ACT     {`BA,`ROW}
`define A_READ    {`BA,`COL}
`define A_WRITE   {`BA,`COL}
`define A_DEFAULT {2'b00,13'b0000000000000}

// Command
`define CMD {ras, cas, we}
`define CMD_NOP   3'b111
`define CMD_AREF  3'b001
`define CMD_LMR   3'b000
`define CMD_LEMR  3'b000
`define CMD_LEMR2 3'b000
`define CMD_LEMR3 3'b000
`define CMD_PRE   3'b010
`define CMD_ACT   3'b011
`define CMD_READ  3'b101
`define CMD_WRITE 3'b100
`define CMD_BT    3'b110

// AC Operating Specifications and Conditions
//`define TWR  4'd2    // Write recovery time, tWR/tCLK=15/8=2 (tCLK)
//`define TRFC 5'd10   // REFRESH-to-ACTIVATE/REFRESH interval (256Mb), tRFC/tCLK=75/8=10 (tCLK)
//`define TRFC 5'd14   // REFRESH-to-ACTIVATE/REFRESH interval (512Mb), tRFC/tCLK=105/8=14 (tCLK)
//`define TRFC 5'd16   // REFRESH-to-ACTIVATE/REFRESH interval (1Gb), tRFC/tCLK=127,5/8=16 (tCLK)
//`define TRFC 5'd25   // REFRESH-to-ACTIVATE/REFRESH interval (2Gb), tRFC/tCLK=197,5/8=25 (tCLK)
//`define TRCD 2'd2    // ACTIVATE-to-READ/WRITE delay, 12-15ns, tRCD/tCLK=15/8=2 (tCLK)

`endif //  `ifdef MT47H32M16


/*
//`define MT48LC16M16
`ifdef MT48LC16M16
// using 1 of MT48LC16M16
// SDRAM data width is 16

`define BURST_SIZE 2  
`define SDRAM_DATA_WIDTH 16
`define COL_SIZE 9  
`define ROW_SIZE 13
`define BA_SIZE 2

`define SDRAM16
`define BA tx_fifo_dat_o[28:27]
`define ROW tx_fifo_dat_o[26:14]
`define COL {4'b0000,tx_fifo_dat_o[13:10],burst_adr,1'b0}
`define WORD_SIZE 1
`define WB_ADR_HI 24
`define WB_ADR_LO 2
`endif //  `ifdef MT48LC16M16

//`define DEVICE MT48LC4M16
`ifdef MT48LC4M16
// using 1 of MT48LC4M16
// SDRAM data width is 16

`define BURST_SIZE 2  
`define SDRAM_DATA_WIDTH 16
`define COL_SIZE 8  
`define ROW_SIZE 12
`define BA_SIZE 2

`define SDRAM16
`define COL {5'b0000,wb_adr_i[8:1]}
`define ROW wb_adr_i[20:9]
`define BA wb_adr_i[22:21]
`define WORD_SIZE 1
`define END_OF_BURST burst_counter[0]
`define WB_ADR_HI 22
`define WB_ADR_LO 1
`endif //  `ifdef MT48LC4M16


// FIFO
`define DLY_INIT 4095
`define AREF_INIT 390


// LMR
// [12:10] reserved
// [9]     WB, write burst; 0 - programmed burst length, 1 - single location
// [8:7]   OP Mode, 2'b00
// [6:4]   CAS Latency; 3'b010 - 2, 3'b011 - 3
// [3]     BT, Burst Type; 1'b0 - sequential, 1'b1 - interleaved
// [2:0]   Burst length; 3'b000 - 1, 3'b001 - 2, 3'b010 - 4, 3'b011 - 8, 3'b111 - full page
`define WB 1'b0
`define CL 2
`define BT 1'b0
`define BL 3'b001

// Adr to SDRAM {ba[1:0],a[12:0]}
`define A_LMR     {2'b00,3'b000,`WB,2'b00,3'd`CL,`BT,`BL}
`define A_PRE     {2'b00,13'b0010000000000}
`define A_ACT     {`BA,`ROW}
`define A_READ    {`BA,`COL}
`define A_WRITE   {`BA,`COL}
`define A_DEFAULT {2'b00,13'b0000000000000}

// command
`define CMD {ras, cas, we}
`define CMD_NOP   3'b111
`define CMD_AREF  3'b001
`define CMD_LMR   3'b000
`define CMD_PRE   3'b010
`define CMD_ACT   3'b011
`define CMD_READ  3'b101
`define CMD_WRITE 3'b100
`define CMD_BT    3'b110

*/
