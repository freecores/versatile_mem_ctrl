svn_export: versatile_fifo_dual_port_ram.v versatile_fifo_async_cmp.v lfsr_polynom.v versatile_counter.v

versatile_fifo_dual_port_ram.v:
	svn export http://opencores.org/ocsvn/versatile_fifo/versatile_fifo/trunk/rtl/verilog/versatile_fifo_dual_port_ram.v

versatile_fifo_async_cmp.v:
	svn export http://opencores.org/ocsvn/versatile_fifo/versatile_fifo/trunk/rtl/verilog/versatile_fifo_async_cmp.v

lfsr_polynom.v:
	svn export http://opencores.org/ocsvn/versatile_counter/versatile_counter/trunk/rtl/verilog/lfsr_polynom.v

versatile_counter.v:
	svn export http://opencores.org/ocsvn/versatile_counter/versatile_counter/trunk/rtl/verilog/versatile_counter.v


versatile_fifo_dual_port_ram_dc_dw.v: versatile_fifo_dual_port_ram.v
	vppreproc +define+TYPE+"dc_dw" +define+DC +define+DW +define+DATA_WIDTH+36 +define+ADDR_WIDTH+8 --simple versatile_fifo_dual_port_ram.v > versatile_fifo_dual_port_ram_dc_dw.v

fifo_adr_counter.v: versatile_counter.v fifo_adr_counter_defines.v
	cp fifo_adr_counter_defines.v versatile_counter_defines.v
	vpp versatile_counter.v > tmp1.v
	vppreproc --simple tmp1.v | cat copyright.v - > fifo_adr_counter.v

ctrl_counter.v: versatile_counter.v ctrl_counter_defines.v
	cp ctrl_counter_defines.v versatile_counter_defines.v
	vpp versatile_counter.v > tmp1.v
	vppreproc --simple tmp1.v | cat copyright.v - > ctrl_counter.v

fifo_fill.v: fifo_fill.fzm
	perl fizzim.pl -encoding onehot < fifo_fill.fzm > fifo_fill.v

sdr_16.v: sdr_16.fzm sdr_16_defines.v
	perl fizzim.pl -encoding onehot < sdr_16.fzm > tmp1.v
	vppreproc --simple tmp1.v > sdr_16.v

ddr_16.v: ddr_16.fzm ddr_16_defines.v
	perl fizzim.pl -encoding onehot < ddr_16.fzm > tmp1.v
	vppreproc --simple tmp1.v > ddr_16.v

ref_counter.v: versatile_counter.v ref_counter_defines.v
	cp ref_counter_defines.v versatile_counter_defines.v
	vpp versatile_counter.v > tmp1.v
	vppreproc --simple tmp1.v | cat copyright.v - > ref_counter.v

ref_delay_counter.v: versatile_counter.v ref_delay_counter_defines.v
	cp ref_delay_counter_defines.v versatile_counter_defines.v
	vpp versatile_counter.v > tmp1.v
	vppreproc --simple tmp1.v | cat copyright.v - > ref_delay_counter.v

pre_delay_counter.v: versatile_counter.v pre_delay_counter_defines.v
	cp pre_delay_counter_defines.v versatile_counter_defines.v
	vpp versatile_counter.v > tmp1.v
	vppreproc --simple tmp1.v | cat copyright.v - > pre_delay_counter.v

burst_length_counter.v : versatile_counter.v burst_length_counter_defines.v
	cp burst_length_counter_defines.v versatile_counter_defines.v
	vpp versatile_counter.v > tmp1.v
	vppreproc --simple tmp1.v | cat copyright.v - > burst_length_counter.v

versatile_mem_ctrl_ip.v: versatile_fifo_async_cmp.v versatile_fifo_dual_port_ram_dc_dw.v fifo_adr_counter.v ctrl_counter.v fifo.v fifo_fill.v inc_adr.v ref_counter.v ref_delay_counter.v pre_delay_counter.v burst_length_counter.v sdr_16.v ddr_16.v delay.v ddr_ff.v dcm_pll.v versatile_mem_ctrl_top.v
	cat versatile_fifo_async_cmp.v versatile_fifo_dual_port_ram_dc_dw.v fifo_adr_counter.v ctrl_counter.v fifo.v fifo_fill.v inc_adr.v ref_counter.v ref_delay_counter.v pre_delay_counter.v burst_length_counter.v sdr_16.v ddr_16.v delay.v ddr_ff.v dcm_pll.v versatile_mem_ctrl_top.v | cat copyright.v - > versatile_mem_ctrl_ip.v

all: svn_export versatile_fifo_dual_port_ram_dc_dw.v fifo_adr_counter.v ctrl_counter.v fifo_fill.v sdr_16.v ddr_16.v ref_counter.v ref_delay_counter.v pre_delay_counter.v burst_length_counter.v versatile_mem_ctrl_ip.v

clean:
	rm -rf versatile_fifo_dual_port_ram_dc_dw.v versatile_fifo_async_cmp.v lfsr_polynom.v versatile_counter.v
	rm -rf fifo_fill.v sdr_16.v ddr_16.v
	rm -rf *_counter.v
	rm -rf *~

