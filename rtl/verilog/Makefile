svn_export: versatile_fifo_dual_port_ram_dc_sw.v versatile_fifo_async_cmp.v versatile_counter_generator.php

versatile_fifo_dual_port_ram_dc_sw.v:
	svn export http://opencores.org/ocsvn/versatile_fifo/versatile_fifo/trunk/rtl/verilog/versatile_fifo_dual_port_ram_dc_sw.v

versatile_fifo_async_cmp.v:
	svn export http://opencores.org/ocsvn/versatile_fifo/versatile_fifo/trunk/rtl/verilog/versatile_fifo_async_cmp.v

versatile_counter_generator.php:
	svn export http://opencores.org/ocsvn/versatile_counter/versatile_counter/trunk/rtl/verilog/versatile_counter_generator.php
	svn export http://opencores.org/ocsvn/versatile_counter/versatile_counter/trunk/rtl/verilog/CSV.class.php

versatile_counter: versatile_counter_generator.php
	excel2csv versatile_counter.xls -S ,
	./versatile_counter_generator.php fifo_adr_counter.csv > fifo_adr_counter.v
	./versatile_counter_generator.php ctrl_counter.csv > ctrl_counter.v
	./versatile_counter_generator.php ref_counter.csv > ref_counter.v
	./versatile_counter_generator.php ref_delay_counter.csv > ref_delay_counter.v
	./versatile_counter_generator.php pre_delay_counter.csv > pre_delay_counter.v
	./versatile_counter_generator.php burst_length_counter.csv > burst_length_counter.v

fifo_fill.v: fifo_fill.fzm
	perl fizzim.pl -encoding onehot < fifo_fill.fzm > fifo_fill.v

sdr_16.v: sdr_16.fzm sdr_16_defines.v
	perl fizzim.pl -encoding onehot < sdr_16.fzm > tmp1.v
	vppreproc --simple tmp1.v > sdr_16.v

ddr_16.v: ddr_16.fzm ddr_16_defines.v
	perl fizzim.pl -encoding onehot < ddr_16.fzm > tmp1.v
	vppreproc --simple tmp1.v > ddr_16.v

versatile_mem_ctrl_ip.v: versatile_fifo_async_cmp.v versatile_fifo_dual_port_ram_dc_dw.v fifo_adr_counter.v ctrl_counter.v ref_counter.v ref_delay_counter.v pre_delay_counter.v burst_length_counter.v fifo.v fifo_fill.v inc_adr.v sdr_16.v ddr_16.v delay.v ddr_ff.v dcm_pll.v versatile_mem_ctrl_top.v
	cat versatile_fifo_async_cmp.v versatile_fifo_dual_port_ram_dc_dw.v fifo_adr_counter.v ctrl_counter.v fifo.v fifo_fill.v inc_adr.v ref_counter.v ref_delay_counter.v pre_delay_counter.v burst_length_counter.v sdr_16.v ddr_16.v delay.v ddr_ff.v dcm_pll.v versatile_mem_ctrl_top.v | cat copyright.v - > versatile_mem_ctrl_ip.v

all: svn_export versatile_fifo_dual_port_ram_dc_dw.v versatile_counter fifo_fill.v sdr_16.v ddr_16.v versatile_mem_ctrl_ip.v

clean:
	rm -rf versatile_fifo_dual_port_ram_dc_dw.v versatile_fifo_async_cmp.v lfsr_polynom.v versatile_counter.v
	rm -rf fifo_fill.v sdr_16.v ddr_16.v
	rm -rf *_counter.v
	rm -rf *.csv
	rm -rf *~
