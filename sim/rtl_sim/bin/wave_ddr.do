onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group {CLOCK & RESET} -divider Reset
add wave -noupdate -expand -group {CLOCK & RESET} -format Logic /versatile_mem_ctrl_tb/dut/wb_rst
add wave -noupdate -expand -group {CLOCK & RESET} -divider Clocks
add wave -noupdate -expand -group {CLOCK & RESET} -format Logic /versatile_mem_ctrl_tb/dut/wb_clk
add wave -noupdate -expand -group {CLOCK & RESET} -format Logic /versatile_mem_ctrl_tb/dut/sdram_clk
add wave -noupdate -expand -group {CLOCK & RESET} -divider {DCM/PLL generated clocks}
add wave -noupdate -expand -group {CLOCK & RESET} -format Logic /versatile_mem_ctrl_tb/dut/sdram_clk_0
add wave -noupdate -expand -group {CLOCK & RESET} -format Logic /versatile_mem_ctrl_tb/dut/sdram_clk_90
add wave -noupdate -expand -group {CLOCK & RESET} -format Logic /versatile_mem_ctrl_tb/dut/sdram_clk_180
add wave -noupdate -expand -group {CLOCK & RESET} -format Logic /versatile_mem_ctrl_tb/dut/sdram_clk_270
add wave -noupdate -group DCM/PLL -divider {Xilinx DCM or Altera altpll}
add wave -noupdate -group DCM/PLL -format Logic /versatile_mem_ctrl_tb/dut/dcm_pll_0/rst
add wave -noupdate -group DCM/PLL -format Logic /versatile_mem_ctrl_tb/dut/dcm_pll_0/clk_in
add wave -noupdate -group DCM/PLL -format Logic /versatile_mem_ctrl_tb/dut/dcm_pll_0/clkfb_in
add wave -noupdate -group DCM/PLL -format Logic /versatile_mem_ctrl_tb/dut/dcm_pll_0/clk0_out
add wave -noupdate -group DCM/PLL -format Logic /versatile_mem_ctrl_tb/dut/dcm_pll_0/clk90_out
add wave -noupdate -group DCM/PLL -format Logic /versatile_mem_ctrl_tb/dut/dcm_pll_0/clk180_out
add wave -noupdate -group DCM/PLL -format Logic /versatile_mem_ctrl_tb/dut/dcm_pll_0/clk270_out
add wave -noupdate -group DCM/PLL -format Logic /versatile_mem_ctrl_tb/dut/dcm_pll_0/clkfb_out
add wave -noupdate -group {WISHBONE IF} -divider wb0
add wave -noupdate -group {WISHBONE IF} -format Literal -radix hexadecimal /versatile_mem_ctrl_tb/dut/wbs0_dat_i
add wave -noupdate -group {WISHBONE IF} -format Literal -radix hexadecimal /versatile_mem_ctrl_tb/dut/wbs0_adr_i
add wave -noupdate -group {WISHBONE IF} -format Literal /versatile_mem_ctrl_tb/dut/wbs0_sel_i
add wave -noupdate -group {WISHBONE IF} -format Literal /versatile_mem_ctrl_tb/dut/wbs0_cti_i
add wave -noupdate -group {WISHBONE IF} -format Literal /versatile_mem_ctrl_tb/dut/wbs0_bte_i
add wave -noupdate -group {WISHBONE IF} -format Logic /versatile_mem_ctrl_tb/dut/wbs0_we_i
add wave -noupdate -group {WISHBONE IF} -format Logic /versatile_mem_ctrl_tb/dut/wbs0_cyc_i
add wave -noupdate -group {WISHBONE IF} -format Logic /versatile_mem_ctrl_tb/dut/wbs0_stb_i
add wave -noupdate -group {WISHBONE IF} -format Literal -radix hexadecimal /versatile_mem_ctrl_tb/dut/wbs0_dat_o
add wave -noupdate -group {WISHBONE IF} -format Logic /versatile_mem_ctrl_tb/dut/wbs0_ack_o
add wave -noupdate -group {WISHBONE IF} -format Literal -radix ascii /versatile_mem_ctrl_tb/wb0i/statename
add wave -noupdate -group {WISHBONE IF} -divider wb1
add wave -noupdate -group {WISHBONE IF} -format Literal -radix hexadecimal /versatile_mem_ctrl_tb/dut/wbs1_dat_i
add wave -noupdate -group {WISHBONE IF} -format Literal -radix hexadecimal /versatile_mem_ctrl_tb/dut/wbs1_adr_i
add wave -noupdate -group {WISHBONE IF} -format Literal /versatile_mem_ctrl_tb/dut/wbs1_sel_i
add wave -noupdate -group {WISHBONE IF} -format Literal /versatile_mem_ctrl_tb/dut/wbs1_cti_i
add wave -noupdate -group {WISHBONE IF} -format Literal /versatile_mem_ctrl_tb/dut/wbs1_bte_i
add wave -noupdate -group {WISHBONE IF} -format Logic /versatile_mem_ctrl_tb/dut/wbs1_we_i
add wave -noupdate -group {WISHBONE IF} -format Logic /versatile_mem_ctrl_tb/dut/wbs1_cyc_i
add wave -noupdate -group {WISHBONE IF} -format Logic /versatile_mem_ctrl_tb/dut/wbs1_stb_i
add wave -noupdate -group {WISHBONE IF} -format Literal -radix hexadecimal /versatile_mem_ctrl_tb/dut/wbs1_dat_o
add wave -noupdate -group {WISHBONE IF} -format Logic /versatile_mem_ctrl_tb/dut/wbs1_ack_o
add wave -noupdate -group {WISHBONE IF} -format Literal -radix ascii /versatile_mem_ctrl_tb/wb1i/statename
add wave -noupdate -group {WISHBONE IF} -divider wb4
add wave -noupdate -group {WISHBONE IF} -format Literal -radix hexadecimal /versatile_mem_ctrl_tb/dut/wbs4_dat_i
add wave -noupdate -group {WISHBONE IF} -format Literal -radix hexadecimal /versatile_mem_ctrl_tb/dut/wbs4_adr_i
add wave -noupdate -group {WISHBONE IF} -format Literal /versatile_mem_ctrl_tb/dut/wbs4_sel_i
add wave -noupdate -group {WISHBONE IF} -format Literal /versatile_mem_ctrl_tb/dut/wbs4_cti_i
add wave -noupdate -group {WISHBONE IF} -format Literal /versatile_mem_ctrl_tb/dut/wbs4_bte_i
add wave -noupdate -group {WISHBONE IF} -format Logic /versatile_mem_ctrl_tb/dut/wbs4_we_i
add wave -noupdate -group {WISHBONE IF} -format Logic /versatile_mem_ctrl_tb/dut/wbs4_cyc_i
add wave -noupdate -group {WISHBONE IF} -format Logic /versatile_mem_ctrl_tb/dut/wbs4_stb_i
add wave -noupdate -group {WISHBONE IF} -format Literal -radix hexadecimal /versatile_mem_ctrl_tb/dut/wbs4_dat_o
add wave -noupdate -group {WISHBONE IF} -format Logic /versatile_mem_ctrl_tb/dut/wbs4_ack_o
add wave -noupdate -group {WISHBONE IF} -format Literal -radix ascii /versatile_mem_ctrl_tb/wb4i/statename
add wave -noupdate -group {TX FIFO} -divider {Tx FIFO Control}
add wave -noupdate -group {TX FIFO} -format Logic /versatile_mem_ctrl_tb/dut/tx_fifo/rst
add wave -noupdate -group {TX FIFO} -format Logic /versatile_mem_ctrl_tb/dut/tx_fifo/a_clk
add wave -noupdate -group {TX FIFO} -format Literal -radix hexadecimal /versatile_mem_ctrl_tb/dut/tx_fifo/a_dat_i
add wave -noupdate -group {TX FIFO} -format Literal /versatile_mem_ctrl_tb/dut/tx_fifo/a_fifo_full_o
add wave -noupdate -group {TX FIFO} -format Literal /versatile_mem_ctrl_tb/dut/tx_fifo/a_fifo_sel_i
add wave -noupdate -group {TX FIFO} -format Logic /versatile_mem_ctrl_tb/dut/tx_fifo/a_we_i
add wave -noupdate -group {TX FIFO} -format Logic /versatile_mem_ctrl_tb/dut/tx_fifo/b_clk
add wave -noupdate -group {TX FIFO} -format Literal -radix hexadecimal /versatile_mem_ctrl_tb/dut/tx_fifo/b_dat_o
add wave -noupdate -group {TX FIFO} -format Literal /versatile_mem_ctrl_tb/dut/tx_fifo/b_fifo_empty_o
add wave -noupdate -group {TX FIFO} -format Literal -radix unsigned /versatile_mem_ctrl_tb/dut/tx_fifo/b_fifo_sel_i
add wave -noupdate -group {TX FIFO} -format Logic /versatile_mem_ctrl_tb/dut/tx_fifo/b_re_i
add wave -noupdate -group {TX FIFO} -format Literal -radix unsigned /versatile_mem_ctrl_tb/dut/tx_fifo/dpram_a_a
add wave -noupdate -group {TX FIFO} -format Literal -radix unsigned /versatile_mem_ctrl_tb/dut/tx_fifo/dpram_a_b
add wave -noupdate -group {TX FIFO} -format Literal -radix unsigned /versatile_mem_ctrl_tb/dut/tx_fifo/radr0
add wave -noupdate -group {TX FIFO} -format Literal -radix unsigned /versatile_mem_ctrl_tb/dut/tx_fifo/radr1
add wave -noupdate -group {TX FIFO} -format Literal -radix unsigned /versatile_mem_ctrl_tb/dut/tx_fifo/radr4
add wave -noupdate -group {TX FIFO} -divider {Tx FIFO 0}
add wave -noupdate -group {TX FIFO} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/tx_fifo/dpram/ram[15]}
add wave -noupdate -group {TX FIFO} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/tx_fifo/dpram/ram[14]}
add wave -noupdate -group {TX FIFO} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/tx_fifo/dpram/ram[13]}
add wave -noupdate -group {TX FIFO} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/tx_fifo/dpram/ram[12]}
add wave -noupdate -group {TX FIFO} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/tx_fifo/dpram/ram[11]}
add wave -noupdate -group {TX FIFO} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/tx_fifo/dpram/ram[10]}
add wave -noupdate -group {TX FIFO} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/tx_fifo/dpram/ram[9]}
add wave -noupdate -group {TX FIFO} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/tx_fifo/dpram/ram[8]}
add wave -noupdate -group {TX FIFO} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/tx_fifo/dpram/ram[7]}
add wave -noupdate -group {TX FIFO} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/tx_fifo/dpram/ram[6]}
add wave -noupdate -group {TX FIFO} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/tx_fifo/dpram/ram[5]}
add wave -noupdate -group {TX FIFO} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/tx_fifo/dpram/ram[4]}
add wave -noupdate -group {TX FIFO} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/tx_fifo/dpram/ram[3]}
add wave -noupdate -group {TX FIFO} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/tx_fifo/dpram/ram[2]}
add wave -noupdate -group {TX FIFO} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/tx_fifo/dpram/ram[1]}
add wave -noupdate -group {TX FIFO} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/tx_fifo/dpram/ram[0]}
add wave -noupdate -group {TX FIFO} -divider {Tx FIFO 1}
add wave -noupdate -group {TX FIFO} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/tx_fifo/dpram/ram[47]}
add wave -noupdate -group {TX FIFO} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/tx_fifo/dpram/ram[46]}
add wave -noupdate -group {TX FIFO} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/tx_fifo/dpram/ram[45]}
add wave -noupdate -group {TX FIFO} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/tx_fifo/dpram/ram[44]}
add wave -noupdate -group {TX FIFO} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/tx_fifo/dpram/ram[43]}
add wave -noupdate -group {TX FIFO} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/tx_fifo/dpram/ram[42]}
add wave -noupdate -group {TX FIFO} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/tx_fifo/dpram/ram[41]}
add wave -noupdate -group {TX FIFO} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/tx_fifo/dpram/ram[40]}
add wave -noupdate -group {TX FIFO} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/tx_fifo/dpram/ram[39]}
add wave -noupdate -group {TX FIFO} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/tx_fifo/dpram/ram[38]}
add wave -noupdate -group {TX FIFO} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/tx_fifo/dpram/ram[37]}
add wave -noupdate -group {TX FIFO} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/tx_fifo/dpram/ram[36]}
add wave -noupdate -group {TX FIFO} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/tx_fifo/dpram/ram[35]}
add wave -noupdate -group {TX FIFO} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/tx_fifo/dpram/ram[34]}
add wave -noupdate -group {TX FIFO} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/tx_fifo/dpram/ram[33]}
add wave -noupdate -group {TX FIFO} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/tx_fifo/dpram/ram[32]}
add wave -noupdate -group {TX FIFO} -divider {Tx FIFO 4}
add wave -noupdate -group {TX FIFO} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/tx_fifo/dpram/ram[143]}
add wave -noupdate -group {TX FIFO} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/tx_fifo/dpram/ram[142]}
add wave -noupdate -group {TX FIFO} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/tx_fifo/dpram/ram[141]}
add wave -noupdate -group {TX FIFO} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/tx_fifo/dpram/ram[140]}
add wave -noupdate -group {TX FIFO} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/tx_fifo/dpram/ram[139]}
add wave -noupdate -group {TX FIFO} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/tx_fifo/dpram/ram[138]}
add wave -noupdate -group {TX FIFO} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/tx_fifo/dpram/ram[137]}
add wave -noupdate -group {TX FIFO} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/tx_fifo/dpram/ram[136]}
add wave -noupdate -group {TX FIFO} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/tx_fifo/dpram/ram[135]}
add wave -noupdate -group {TX FIFO} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/tx_fifo/dpram/ram[134]}
add wave -noupdate -group {TX FIFO} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/tx_fifo/dpram/ram[133]}
add wave -noupdate -group {TX FIFO} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/tx_fifo/dpram/ram[132]}
add wave -noupdate -group {TX FIFO} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/tx_fifo/dpram/ram[131]}
add wave -noupdate -group {TX FIFO} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/tx_fifo/dpram/ram[130]}
add wave -noupdate -group {TX FIFO} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/tx_fifo/dpram/ram[129]}
add wave -noupdate -group {TX FIFO} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/tx_fifo/dpram/ram[128]}
add wave -noupdate -group {MAIN STATE MACHINE} -format Literal -radix ascii /versatile_mem_ctrl_tb/dut/ddr_16_0/statename
add wave -noupdate -group {MAIN STATE MACHINE} -format Literal -radix hexadecimal /versatile_mem_ctrl_tb/dut/ddr_16_0/a
add wave -noupdate -group {MAIN STATE MACHINE} -format Logic /versatile_mem_ctrl_tb/dut/ddr_16_0/adr_init
add wave -noupdate -group {MAIN STATE MACHINE} -format Literal /versatile_mem_ctrl_tb/dut/ddr_16_0/burst_adr
add wave -noupdate -group {MAIN STATE MACHINE} -format Literal /versatile_mem_ctrl_tb/dut/ddr_16_0/cmd
add wave -noupdate -group {MAIN STATE MACHINE} -format Logic /versatile_mem_ctrl_tb/dut/ddr_16_0/cs_n
add wave -noupdate -group {MAIN STATE MACHINE} -format Literal -radix binary /versatile_mem_ctrl_tb/dut/ddr_16_0/fifo_empty
add wave -noupdate -group {MAIN STATE MACHINE} -format Logic /versatile_mem_ctrl_tb/dut/ddr_16_0/fifo_re
add wave -noupdate -group {MAIN STATE MACHINE} -format Literal /versatile_mem_ctrl_tb/dut/ddr_16_0/fifo_sel
add wave -noupdate -group {MAIN STATE MACHINE} -format Logic /versatile_mem_ctrl_tb/dut/ddr_16_0/read
add wave -noupdate -group {MAIN STATE MACHINE} -format Logic /versatile_mem_ctrl_tb/dut/ddr_16_0/write
add wave -noupdate -group {MAIN STATE MACHINE} -format Logic /versatile_mem_ctrl_tb/dut/ddr_16_0/ref_ack
add wave -noupdate -group {MAIN STATE MACHINE} -format Logic /versatile_mem_ctrl_tb/dut/ddr_16_0/ref_req
add wave -noupdate -group {MAIN STATE MACHINE} -format Logic /versatile_mem_ctrl_tb/dut/ddr_16_0/sdram_clk
add wave -noupdate -group {MAIN STATE MACHINE} -format Logic -radix hexadecimal {/versatile_mem_ctrl_tb/dut/ddr_16_0/tx_fifo_dat_o[5]}
add wave -noupdate -group {MAIN STATE MACHINE} -format Literal -radix hexadecimal /versatile_mem_ctrl_tb/dut/ddr_16_0/tx_fifo_dat_o
add wave -noupdate -group {DDR2 SDRAM IF} -format Literal -radix ascii /versatile_mem_ctrl_tb/dut/ddr_16_0/statename
add wave -noupdate -group {DDR2 SDRAM IF} -format Logic /versatile_mem_ctrl_tb/dut/ck_pad_o
add wave -noupdate -group {DDR2 SDRAM IF} -format Logic /versatile_mem_ctrl_tb/dut/ck_n_pad_o
add wave -noupdate -group {DDR2 SDRAM IF} -format Logic /versatile_mem_ctrl_tb/dut/cke_pad_o
add wave -noupdate -group {DDR2 SDRAM IF} -format Logic /versatile_mem_ctrl_tb/dut/cs_n_pad_o
add wave -noupdate -group {DDR2 SDRAM IF} -format Logic /versatile_mem_ctrl_tb/dut/ras_pad_o
add wave -noupdate -group {DDR2 SDRAM IF} -format Logic /versatile_mem_ctrl_tb/dut/cas_pad_o
add wave -noupdate -group {DDR2 SDRAM IF} -format Logic /versatile_mem_ctrl_tb/dut/we_pad_o
add wave -noupdate -group {DDR2 SDRAM IF} -format Literal /versatile_mem_ctrl_tb/dut/ba_pad_o
add wave -noupdate -group {DDR2 SDRAM IF} -format Literal -radix decimal /versatile_mem_ctrl_tb/dut/addr_pad_o
add wave -noupdate -group {DDR2 SDRAM IF} -format Literal -radix hexadecimal /versatile_mem_ctrl_tb/dut/dq_o
add wave -noupdate -group {DDR2 SDRAM IF} -format Logic /versatile_mem_ctrl_tb/dut/dq_oe
add wave -noupdate -group {DDR2 SDRAM IF} -format Logic /versatile_mem_ctrl_tb/dut/dq_en
add wave -noupdate -group {DDR2 SDRAM IF} -format Logic /versatile_mem_ctrl_tb/dut/dqs_en
add wave -noupdate -group {DDR2 SDRAM IF} -format Literal /versatile_mem_ctrl_tb/dut/rdqs_n_pad_i
add wave -noupdate -group {DDR2 SDRAM IF} -format Logic /versatile_mem_ctrl_tb/dut/odt_pad_o
add wave -noupdate -group {DDR2 SDRAM IF} -format Logic /versatile_mem_ctrl_tb/dut/dqm_en
add wave -noupdate -group {DDR2 SDRAM IF} -format Literal /versatile_mem_ctrl_tb/dut/dqm_o
add wave -noupdate -group {DDR2 SDRAM IF} -format Literal /versatile_mem_ctrl_tb/dut/dm_rdqs_pad_io
add wave -noupdate -group {DDR2 SDRAM SIMULATIOM MODEL} -divider {Micron DDR2 SDRAM}
add wave -noupdate -group {DDR2 SDRAM SIMULATIOM MODEL} -format Literal -radix ascii /versatile_mem_ctrl_tb/dut/ddr_16_0/statename
add wave -noupdate -group {DDR2 SDRAM SIMULATIOM MODEL} -format Logic /versatile_mem_ctrl_tb/ddr2_sdram/ck
add wave -noupdate -group {DDR2 SDRAM SIMULATIOM MODEL} -format Logic /versatile_mem_ctrl_tb/ddr2_sdram/ck_n
add wave -noupdate -group {DDR2 SDRAM SIMULATIOM MODEL} -format Logic /versatile_mem_ctrl_tb/ddr2_sdram/cke
add wave -noupdate -group {DDR2 SDRAM SIMULATIOM MODEL} -format Logic /versatile_mem_ctrl_tb/ddr2_sdram/cs_n
add wave -noupdate -group {DDR2 SDRAM SIMULATIOM MODEL} -format Logic /versatile_mem_ctrl_tb/ddr2_sdram/ras_n
add wave -noupdate -group {DDR2 SDRAM SIMULATIOM MODEL} -format Logic /versatile_mem_ctrl_tb/ddr2_sdram/cas_n
add wave -noupdate -group {DDR2 SDRAM SIMULATIOM MODEL} -format Logic /versatile_mem_ctrl_tb/ddr2_sdram/we_n
add wave -noupdate -group {DDR2 SDRAM SIMULATIOM MODEL} -format Literal /versatile_mem_ctrl_tb/ddr2_sdram/ba
add wave -noupdate -group {DDR2 SDRAM SIMULATIOM MODEL} -format Literal -radix hexadecimal /versatile_mem_ctrl_tb/ddr2_sdram/addr
add wave -noupdate -group {DDR2 SDRAM SIMULATIOM MODEL} -format Logic /versatile_mem_ctrl_tb/ddr2_sdram/odt
add wave -noupdate -group {DDR2 SDRAM SIMULATIOM MODEL} -format Literal /versatile_mem_ctrl_tb/ddr2_sdram/dm_rdqs
add wave -noupdate -group {DDR2 SDRAM SIMULATIOM MODEL} -format Literal -radix hexadecimal /versatile_mem_ctrl_tb/ddr2_sdram/dq
add wave -noupdate -group {DDR2 SDRAM SIMULATIOM MODEL} -format Literal /versatile_mem_ctrl_tb/ddr2_sdram/dqs
add wave -noupdate -group {DDR2 SDRAM SIMULATIOM MODEL} -format Literal /versatile_mem_ctrl_tb/ddr2_sdram/dqs_n
add wave -noupdate -group {DDR2 SDRAM SIMULATIOM MODEL} -format Literal /versatile_mem_ctrl_tb/ddr2_sdram/rdqs_n
add wave -noupdate -group {RX FIFO} -divider {Rx FIFO Control}
add wave -noupdate -group {RX FIFO} -format Literal /versatile_mem_ctrl_tb/dut/rx_fifo_full
add wave -noupdate -group {RX FIFO} -format Literal /versatile_mem_ctrl_tb/dut/rx_fifo_empty
add wave -noupdate -group {RX FIFO} -divider {Rx FIFO 0}
add wave -noupdate -group {RX FIFO} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/rx_fifo/dpram/ram[7]}
add wave -noupdate -group {RX FIFO} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/rx_fifo/dpram/ram[6]}
add wave -noupdate -group {RX FIFO} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/rx_fifo/dpram/ram[5]}
add wave -noupdate -group {RX FIFO} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/rx_fifo/dpram/ram[4]}
add wave -noupdate -group {RX FIFO} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/rx_fifo/dpram/ram[3]}
add wave -noupdate -group {RX FIFO} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/rx_fifo/dpram/ram[2]}
add wave -noupdate -group {RX FIFO} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/rx_fifo/dpram/ram[1]}
add wave -noupdate -group {RX FIFO} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/rx_fifo/dpram/ram[0]}
add wave -noupdate -group {RX FIFO} -format Literal -radix unsigned /versatile_mem_ctrl_tb/dut/rx_fifo/wadr0
add wave -noupdate -group {RX FIFO} -format Literal -radix unsigned /versatile_mem_ctrl_tb/dut/rx_fifo/radr0
add wave -noupdate -group {RX FIFO} -divider {Rx FIFO 1}
add wave -noupdate -group {RX FIFO} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/rx_fifo/dpram/ram[39]}
add wave -noupdate -group {RX FIFO} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/rx_fifo/dpram/ram[38]}
add wave -noupdate -group {RX FIFO} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/rx_fifo/dpram/ram[37]}
add wave -noupdate -group {RX FIFO} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/rx_fifo/dpram/ram[36]}
add wave -noupdate -group {RX FIFO} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/rx_fifo/dpram/ram[35]}
add wave -noupdate -group {RX FIFO} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/rx_fifo/dpram/ram[34]}
add wave -noupdate -group {RX FIFO} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/rx_fifo/dpram/ram[33]}
add wave -noupdate -group {RX FIFO} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/rx_fifo/dpram/ram[32]}
add wave -noupdate -group {RX FIFO} -format Literal -radix unsigned /versatile_mem_ctrl_tb/dut/rx_fifo/wadr1
add wave -noupdate -group {RX FIFO} -format Literal -radix unsigned /versatile_mem_ctrl_tb/dut/rx_fifo/radr1
add wave -noupdate -group {RX FIFO} -divider {Rx FIFO 4}
add wave -noupdate -group {RX FIFO} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/rx_fifo/dpram/ram[143]}
add wave -noupdate -group {RX FIFO} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/rx_fifo/dpram/ram[142]}
add wave -noupdate -group {RX FIFO} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/rx_fifo/dpram/ram[141]}
add wave -noupdate -group {RX FIFO} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/rx_fifo/dpram/ram[140]}
add wave -noupdate -group {RX FIFO} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/rx_fifo/dpram/ram[139]}
add wave -noupdate -group {RX FIFO} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/rx_fifo/dpram/ram[138]}
add wave -noupdate -group {RX FIFO} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/rx_fifo/dpram/ram[137]}
add wave -noupdate -group {RX FIFO} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/rx_fifo/dpram/ram[136]}
add wave -noupdate -group {RX FIFO} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/rx_fifo/dpram/ram[135]}
add wave -noupdate -group {RX FIFO} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/rx_fifo/dpram/ram[134]}
add wave -noupdate -group {RX FIFO} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/rx_fifo/dpram/ram[133]}
add wave -noupdate -group {RX FIFO} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/rx_fifo/dpram/ram[132]}
add wave -noupdate -group {RX FIFO} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/rx_fifo/dpram/ram[131]}
add wave -noupdate -group {RX FIFO} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/rx_fifo/dpram/ram[130]}
add wave -noupdate -group {RX FIFO} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/rx_fifo/dpram/ram[129]}
add wave -noupdate -group {RX FIFO} -format Literal -radix hexadecimal {/versatile_mem_ctrl_tb/dut/rx_fifo/dpram/ram[128]}
add wave -noupdate -group {RX FIFO} -format Literal -radix unsigned /versatile_mem_ctrl_tb/dut/rx_fifo/wadr4
add wave -noupdate -group {RX FIFO} -format Literal -radix unsigned /versatile_mem_ctrl_tb/dut/rx_fifo/radr4
add wave -noupdate -group {BURST LENGTH} -format Logic /versatile_mem_ctrl_tb/dut/burst_length_counter0/cke
add wave -noupdate -group {BURST LENGTH} -format Logic /versatile_mem_ctrl_tb/dut/burst_length_counter0/clk
add wave -noupdate -group {BURST LENGTH} -format Logic /versatile_mem_ctrl_tb/dut/burst_length_counter0/rst
add wave -noupdate -group {BURST LENGTH} -format Literal -radix hexadecimal /versatile_mem_ctrl_tb/dut/burst_length_counter0/wrap_value
add wave -noupdate -group {BURST LENGTH} -format Literal -radix hexadecimal /versatile_mem_ctrl_tb/dut/burst_length_counter0/qi
add wave -noupdate -group {BURST LENGTH} -format Literal -radix hexadecimal /versatile_mem_ctrl_tb/dut/burst_length_counter0/q_next
add wave -noupdate -group {BURST LENGTH} -format Logic /versatile_mem_ctrl_tb/dut/burst_length_counter0/zq
add wave -noupdate -group {ADDRESS INCREMENT} -format Logic /versatile_mem_ctrl_tb/dut/write
add wave -noupdate -group {ADDRESS INCREMENT} -format Logic /versatile_mem_ctrl_tb/dut/read
add wave -noupdate -group {ADDRESS INCREMENT} -format Logic /versatile_mem_ctrl_tb/dut/inc_adr0/rst
add wave -noupdate -group {ADDRESS INCREMENT} -format Logic /versatile_mem_ctrl_tb/dut/inc_adr0/clk
add wave -noupdate -group {ADDRESS INCREMENT} -format Literal -radix unsigned /versatile_mem_ctrl_tb/dut/inc_adr0/adr_i
add wave -noupdate -group {ADDRESS INCREMENT} -format Literal -radix unsigned /versatile_mem_ctrl_tb/dut/inc_adr0/bte_i
add wave -noupdate -group {ADDRESS INCREMENT} -format Literal -radix unsigned /versatile_mem_ctrl_tb/dut/inc_adr0/cti_i
add wave -noupdate -group {ADDRESS INCREMENT} -format Logic /versatile_mem_ctrl_tb/dut/inc_adr0/init
add wave -noupdate -group {ADDRESS INCREMENT} -format Logic /versatile_mem_ctrl_tb/dut/inc_adr0/init_i
add wave -noupdate -group {ADDRESS INCREMENT} -format Logic /versatile_mem_ctrl_tb/dut/inc_adr0/inc
add wave -noupdate -group {ADDRESS INCREMENT} -format Literal -radix unsigned /versatile_mem_ctrl_tb/dut/inc_adr0/cnt
add wave -noupdate -group {ADDRESS INCREMENT} -format Literal -radix unsigned /versatile_mem_ctrl_tb/dut/inc_adr0/adr_o
add wave -noupdate -group {ADDRESS INCREMENT} -format Logic /versatile_mem_ctrl_tb/dut/inc_adr0/done
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {252260000 ps} 0}
configure wave -namecolwidth 371
configure wave -valuecolwidth 84
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {193310526 ps} {259935789 ps}
