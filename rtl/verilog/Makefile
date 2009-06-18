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

versatile_mem_ctrl:
	vppreproc --simple versatile_mem_ctrl_top.v ctrl_counter.v fifo.v | cat copyright.v - > versatile_mem_ctrl_ip.v

all:  ctrl_counter dual_port_ram fifo_adr_counter fifo versatile_mem_ctrl
