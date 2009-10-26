svn_export:
	svn export http://opencores.org/ocsvn/versatile_fifo/versatile_fifo/trunk/rtl/verilog/versatile_fifo_dual_port_ram.v
	svn export http://opencores.org/ocsvn/versatile_fifo/versatile_fifo/trunk/rtl/verilog/versatile_fifo_async_cmp.v
	svn export http://opencores.org/ocsvn/versatile_counter/versatile_counter/trunk/rtl/verilog/lfsr_polynom.v
	svn export http://opencores.org/ocsvn/versatile_counter/versatile_counter/trunk/rtl/verilog/versatile_counter.v

dual_port_ram:
	vppreproc +define+TYPE+"dc_dw" +define+DC +define+DW +define+DATA_WIDTH+36 +define+ADDR_WIDTH+8 --simple versatile_fifo_dual_port_ram.v > versatile_fifo_dual_port_ram_dc_dw.v

fifo_adr_counter:
	cp fifo_adr_counter_defines.v versatile_counter_defines.v
	vpp versatile_counter.v > tmp1.v
	vppreproc --simple tmp1.v | cat copyright.v - > fifo_adr_counter.v

ctrl_counter:
	cp ctrl_counter_defines.v versatile_counter_defines.v
	vpp versatile_counter.v > tmp1.v
	vppreproc --simple tmp1.v | cat copyright.v - > ctrl_counter.v

fifo_fill_fsm:
	perl fizzim.pl -encoding onehot < fifo_fill.fzm > fifo_fill.v

sdr_16:
	perl fizzim.pl -encoding onehot < sdr_16.fzm > tmp1.v
	vppreproc --simple tmp1.v > sdr_16.v

ddr_16:
	perl fizzim.pl -encoding onehot < ddr_16.fzm > tmp1.v
	vppreproc --simple tmp1.v > ddr_16.v

ref_counter:
	cp ref_counter_defines.v versatile_counter_defines.v
	vpp versatile_counter.v > tmp1.v
	vppreproc --simple tmp1.v | cat copyright.v - > ref_counter.v

delay_counter:
	cp cke_delay_counter_defines.v versatile_counter_defines.v
	vpp versatile_counter.v > tmp1.v
	vppreproc --simple tmp1.v | cat copyright.v - > cke_delay_counter.v

versatile_mem_ctrl:
	cat versatile_fifo_async_cmp.v versatile_fifo_dual_port_ram_dc_dw.v fifo_adr_counter.v ctrl_counter.v fifo.v fifo_fill.v inc_adr.v ref_counter.v cke_delay_counter.v sdr_16.v ddr_16.v delay.v versatile_mem_ctrl_top.v | cat copyright.v - > versatile_mem_ctrl_ip.v

all:  ctrl_counter dual_port_ram fifo_adr_counter fifo_fill_fsm sdr_16 ddr_16 delay_counter versatile_mem_ctrl

