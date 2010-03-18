svn_export: versatile_fifo_dual_port_ram.v versatile_fifo_async_cmp.v

versatile_fifo_dual_port_ram.v:
	svn export http://opencores.org/ocsvn/versatile_fifo/versatile_fifo/trunk/rtl/verilog/versatile_fifo_dual_port_ram.v

versatile_fifo_async_cmp.v:
	svn export http://opencores.org/ocsvn/versatile_fifo/versatile_fifo/trunk/rtl/verilog/versatile_fifo_async_cmp.v

versatile_counter_generator.php:
	svn export http://opencores.org/ocsvn/versatile_counter/versatile_counter/trunk/rtl/verilog/versatile_counter_generator.php

CSV.class.php:
	svn export http://opencores.org/ocsvn/versatile_counter/versatile_counter/trunk/rtl/verilog/CSV.class.php

versatile_fifo_dual_port_ram_dc_dw.v: versatile_fifo_dual_port_ram.v
	vppreproc +define+TYPE+"dc_dw" +define+DC +define+DW +define+DATA_WIDTH+36 +define+ADDR_WIDTH+8 --simple versatile_fifo_dual_port_ram.v > versatile_fifo_dual_port_ram_dc_dw.v

versatile_counter: versatile_counter_generator.php CSV.class.php
	excel2csv versatile_counter.xls -S ,
	./versatile_counter_generator.php fifo_adr_counter.csv > fifo_adr_counter.v
	./versatile_counter_generator.php ctrl_counter.csv > ctrl_counter.v
	./versatile_counter_generator.php ref_counter.csv > ref_counter.v
	./versatile_counter_generator.php ref_delay_counter.csv > ref_delay_counter.v
	./versatile_counter_generator.php pre_delay_counter.csv > pre_delay_counter.v
	./versatile_counter_generator.php burst_length_counter.csv > burst_length_counter.v

fifo_fill.v: fifo_fill.fzm
	perl fizzim.pl -encoding onehot < fifo_fill.fzm > fifo_fill.v

ddr_16.v: ddr_16.fzm ddr_16_defines.v
	perl fizzim.pl -encoding onehot < ddr_16.fzm > tmp1.v
	vppreproc --simple tmp1.v > ddr_16.v

versatile_mem_ctrl_ip.v: versatile_fifo_async_cmp.v versatile_fifo_dual_port_ram_dc_dw.v fifo_adr_counter.v ctrl_counter.v ref_counter.v ref_delay_counter.v pre_delay_counter.v burst_length_counter.v fifo.v fifo_fill.v inc_adr.v sdr_16.v ddr_16.v delay.v ddr_ff.v dcm_pll.v dff_sr.v versatile_mem_ctrl_ddr.v versatile_mem_ctrl_top.v
	cat versatile_fifo_async_cmp.v versatile_fifo_dual_port_ram_dc_dw.v fifo_adr_counter.v ctrl_counter.v fifo.v fifo_fill.v inc_adr.v ref_counter.v ref_delay_counter.v pre_delay_counter.v burst_length_counter.v sdr_16.v ddr_16.v delay.v ddr_ff.v dcm_pll.v dff_sr.v versatile_mem_ctrl_ddr.v versatile_mem_ctrl_top.v | cat copyright.v - > versatile_mem_ctrl_ip.v

all: svn_export versatile_fifo_dual_port_ram_dc_dw.v versatile_counter fifo_fill.v sdr_16.v ddr_16.v versatile_mem_ctrl_ip.v

sdr_16.v: versatile_fifo_async_cmp.v versatile_fifo_dual_port_ram_dc_dw.v versatile_counter
	vppreproc --simple +define+SDR_16 delay.v codec.v fifo_adr_counter.v versatile_fifo_dual_port_ram_dc_sw.v versatile_fifo_async_cmp.v ref_counter.v fsm_sdr_16.v versatile_mem_ctrl_wb.v versatile_mem_ctrl_top.v > sdr_16.v

all: sdr_16.v

clean:
	rm -rf versatile_fifo_dual_port_ram_dc_dw.v versatile_fifo_async_cmp.v
	rm -rf fifo_fill.v sdr_16.v ddr_16.v
	rm -rf *_counter.v
	rm -rf *.csv
	rm -rf *~

