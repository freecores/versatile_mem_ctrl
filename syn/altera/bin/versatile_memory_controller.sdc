#**************************************************************
# Time Information
#**************************************************************
# Timing specifications from Micron Data Sheet (DDR2 SDRAM MT47H32M16-5E)

# Clock cycle time: min=5.00ns, max=8.00ns
set tCK 5.000

# Input setup time: tISb=350ps, tISa=600ps
set tSU 0.600

# Input hold time: tIHb=470ps, tIHa=600ps
set tH  0.600

# DQS output access time from CK/CK#
set tDQSCKmin -0.500
set tDQSCKmax  0.500

# DQ output access time from CK/CK#
set tACmin -0.600
set tACmax  0.600


#**************************************************************
# Create Clock
#**************************************************************

# Clock frequency
set wb_clk_period 20.000
set sdram_clk_period $tCK

# Clocks
create_clock -name {wb_clk} -period $wb_clk_period [get_ports {wb_clk}]
create_clock -name {sdram_clk} -period $sdram_clk_period [get_ports {sdram_clk}]

# Virtual clocks
create_clock -name {v_wb_clk_in} -period $wb_clk_period 
create_clock -name {v_wb_clk_out} -period $wb_clk_period 
create_clock -name {v_sdram_clk_in} -period $sdram_clk_period 
create_clock -name {v_sdram_clk_out} -period $sdram_clk_period 


#**************************************************************
# Create Generated Clock
#**************************************************************

create_generated_clock -name sdram_clk_0 -phase 0 -source [get_ports {sdram_clk}] [get_pins {dcm_pll_0|altpll_internal|auto_generated|pll1|clk[0]}]

create_generated_clock -name sdram_clk_180 -phase 180 -source [get_ports {sdram_clk}] [get_pins {dcm_pll_0|altpll_internal|auto_generated|pll1|clk[2]}]

create_generated_clock -name sdram_clk_270 -phase 270 -source [get_ports {sdram_clk}] [get_pins {dcm_pll_0|altpll_internal|auto_generated|pll1|clk[3]}]

create_generated_clock -name ck_pad_o -phase 0 -source [get_pins {ddr_ff_out_inst_2|altddio_out_inst|auto_generated|ddio_outa[0]|clkhi}] [get_ports ck_pad*]


#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

derive_clock_uncertainty


#**************************************************************
# Set Input Delay
#**************************************************************

set_input_delay -clock {ck_pad_o} -max $tACmax             [get_ports {dq_pad_io[*]}] -add_delay
set_input_delay -clock {ck_pad_o} -max $tACmax -clock_fall [get_ports {dq_pad_io[*]}] -add_delay
set_input_delay -clock {ck_pad_o} -min $tACmin             [get_ports {dq_pad_io[*]}] -add_delay
set_input_delay -clock {ck_pad_o} -min $tACmin -clock_fall [get_ports {dq_pad_io[*]}] -add_delay

#set_input_delay -clock {ck_pad_o} -max $tDQSCKmax             [get_ports {dqs_pad_io[*]}] -add_delay
#set_input_delay -clock {ck_pad_o} -max $tDQSCKmax -clock_fall [get_ports {dqs_pad_io[*]}] -add_delay
#set_input_delay -clock {ck_pad_o} -min $tDQSCKmin             [get_ports {dqs_pad_io[*]}] -add_delay
#set_input_delay -clock {ck_pad_o} -min $tDQSCKmin -clock_fall [get_ports {dqs_pad_io[*]}] -add_delay

#set_input_delay -clock {ck_pad_o} -max $tDQSCKmax             [get_ports {dqs_n_pad_io[*]}] -add_delay
#set_input_delay -clock {ck_pad_o} -max $tDQSCKmax -clock_fall [get_ports {dqs_n_pad_io[*]}] -add_delay
#set_input_delay -clock {ck_pad_o} -min $tDQSCKmin             [get_ports {dqs_n_pad_io[*]}] -add_delay
#set_input_delay -clock {ck_pad_o} -min $tDQSCKmin -clock_fall [get_ports {dqs_n_pad_io[*]}] -add_delay


#**************************************************************
# Set Output Delay
#**************************************************************

set_output_delay -clock {ck_pad_o} -max $tSU             [get_ports {dq_pad_io[*]}] -add_delay
set_output_delay -clock {ck_pad_o} -max $tSU -clock_fall [get_ports {dq_pad_io[*]}] -add_delay 
set_output_delay -clock {ck_pad_o} -min -$tH             [get_ports {dq_pad_io[*]}] -add_delay 
set_output_delay -clock {ck_pad_o} -min -$tH -clock_fall [get_ports {dq_pad_io[*]}] -add_delay 

#set_output_delay -clock {ck_pad_o} -max $tSU             [get_ports {dqs_pad_io[*]}] -add_delay
#set_output_delay -clock {ck_pad_o} -max $tSU -clock_fall [get_ports {dqs_pad_io[*]}] -add_delay 
#set_output_delay -clock {ck_pad_o} -min -$tH             [get_ports {dqs_pad_io[*]}] -add_delay 
#set_output_delay -clock {ck_pad_o} -min -$tH -clock_fall [get_ports {dqs_pad_io[*]}] -add_delay 

#set_output_delay -clock {ck_pad_o} -max $tSU             [get_ports {dqs_n_pad_io[*]}] -add_delay
#set_output_delay -clock {ck_pad_o} -max $tSU -clock_fall [get_ports {dqs_pad_n_io[*]}] -add_delay 
#set_output_delay -clock {ck_pad_o} -min -$tH             [get_ports {dqs_n_pad_io[*]}] -add_delay 
#set_output_delay -clock {ck_pad_o} -min -$tH -clock_fall [get_ports {dqs_n_pad_io[*]}] -add_delay 



#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************

# Reset
set_false_path -from [get_ports {wb_rst}]

# Input Timing Exceptions
set_false_path -setup -fall_from [get_clocks ck_pad_o] -rise_to [get_clocks sdram_clk_270]
set_false_path -setup -rise_from [get_clocks ck_pad_o] -fall_to [get_clocks sdram_clk_270]
set_false_path -hold  -rise_from [get_clocks ck_pad_o] -fall_to [get_clocks sdram_clk_270]
set_false_path -hold  -fall_from [get_clocks ck_pad_o] -rise_to [get_clocks sdram_clk_270]

# Output Timing Exceptions
set_false_path -setup -rise_from [get_clocks sdram_clk_270] -fall_to [get_clocks ck_pad_o]
set_false_path -setup -fall_from [get_clocks sdram_clk_270] -rise_to [get_clocks ck_pad_o]
set_false_path -hold  -rise_from [get_clocks sdram_clk_270] -rise_to [get_clocks ck_pad_o]
set_false_path -hold  -fall_from [get_clocks sdram_clk_270] -fall_to [get_clocks ck_pad_o]


#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************


