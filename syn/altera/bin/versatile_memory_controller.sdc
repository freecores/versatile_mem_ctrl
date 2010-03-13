#**************************************************************
# Timimg Information for DDR2 SDRAM
#**************************************************************
# Timing specifications from Micron Data Sheet (DDR2 SDRAM MT47H32M16-5E)

# Clock cycle time: min=5.00ns, max=8.00ns
set tCK 5.000

# Data Strobe Out
# DQS output access time from CK/CK#
set tDQSCKmin -0.500
set tDQSCKmax  0.500

# Data Strobe In
# DQS rising edge to CK rising edge
set tDQSSmin [expr -0.25 * $tCK]
set tDQSSmax [expr 0.25 * $tCK]
# DQS falling to CK rising: setup time
set tDSSmin [expr 0.2 * $tCK]
# DQS falling from CK rising: hold time
set tDSHmin [expr 0.2 * $tCK]

# Data Out
# DQ output access time from CK/CK#
set tACmin -0.600
set tACmax  0.600

# Data In
# DQ and DM input setup time to DQS
set tDSb 0.150
# DQ and DM input hold time to DQS
set tDHb 0.275
# DQ and DM input setup time to DQS
set tDSa 0.400
# DQ and DM input hold time to DQS
set tDHa 0.400

# Command and Address
# Input setup time
set tISb 0.350
set tISa 0.600
# Input hold time
set tIHb 0.470
set tIHa 0.600


#**************************************************************
# Timimg Information
#**************************************************************

# Trace delay for data
set tTDDmin 0.100
set tTDDmax 0.200

# Trace delay for clock
set tTDCmin  0.100
set tTDCmax  0.200


#**************************************************************
# Create Clock
#**************************************************************

# Clock frequency
set wb_clk_period 20.000
set sdram_clk_period $tCK

# Clocks
create_clock -name {wb_clk}    -period $wb_clk_period    [get_ports {wb_clk}]
create_clock -name {sdram_clk} -period $sdram_clk_period [get_ports {sdram_clk}]

# Virtual clocks
#create_clock -name {v_wb_clk_in}     -period $wb_clk_period 
#create_clock -name {v_wb_clk_out}    -period $wb_clk_period 
#create_clock -name {v_sdram_clk_in}  -period $sdram_clk_period 
#create_clock -name {v_sdram_clk_out} -period $sdram_clk_period 


#**************************************************************
# Create Generated Clock
#**************************************************************

create_generated_clock -name sdram_clk_0 -phase 0 -source [get_ports {sdram_clk}] [get_pins {dcm_pll_0|altpll_internal|auto_generated|pll1|clk[0]}]
create_generated_clock -name sdram_clk_180 -phase 180 -source [get_ports {sdram_clk}] [get_pins {dcm_pll_0|altpll_internal|auto_generated|pll1|clk[2]}]
create_generated_clock -name sdram_clk_270 -phase 270 -source [get_ports {sdram_clk}] [get_pins {dcm_pll_0|altpll_internal|auto_generated|pll1|clk[3]}]
create_generated_clock -name ck_pad_o -phase 0 -source [get_pins {versatile_mem_ctrl_ddr_0|ddr_ff_out_ck|altddio_out_inst|auto_generated|ddio_outa[0]|clkhi}] [get_ports {ck_pad_o}]

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
# Double Data Rate requires constraints for both rising and falling clock edge
# Input max delay value = max trace delay for data + tCO of external device – min trace delay for clock
# Input min delay value = min trace delay for data + tCOmin of external device – max trace delay for clock
# Assume (for now): max trace delay for data = min trace delay for clock
#                   min trace delay for data = max trace delay for clock
# Data
set_input_delay -clock {ck_pad_o} -max $tACmax             [get_ports {dq_pad_io[*]}] -add_delay
set_input_delay -clock {ck_pad_o} -max $tACmax -clock_fall [get_ports {dq_pad_io[*]}] -add_delay
set_input_delay -clock {ck_pad_o} -min $tACmin             [get_ports {dq_pad_io[*]}] -add_delay
set_input_delay -clock {ck_pad_o} -min $tACmin -clock_fall [get_ports {dq_pad_io[*]}] -add_delay
# Data Strobe
set_input_delay -clock {ck_pad_o} -max $tDQSCKmax             [get_ports {dqs_pad_io[*]}] -add_delay
set_input_delay -clock {ck_pad_o} -max $tDQSCKmax -clock_fall [get_ports {dqs_pad_io[*]}] -add_delay
set_input_delay -clock {ck_pad_o} -min $tDQSCKmin             [get_ports {dqs_pad_io[*]}] -add_delay
set_input_delay -clock {ck_pad_o} -min $tDQSCKmin -clock_fall [get_ports {dqs_pad_io[*]}] -add_delay
# Data Strobe
set_input_delay -clock {ck_pad_o} -max $tDQSCKmax             [get_ports {dqs_n_pad_io[*]}] -add_delay
set_input_delay -clock {ck_pad_o} -max $tDQSCKmax -clock_fall [get_ports {dqs_n_pad_io[*]}] -add_delay
set_input_delay -clock {ck_pad_o} -min $tDQSCKmin             [get_ports {dqs_n_pad_io[*]}] -add_delay
set_input_delay -clock {ck_pad_o} -min $tDQSCKmin -clock_fall [get_ports {dqs_n_pad_io[*]}] -add_delay
# Data Mask
set_input_delay -clock {ck_pad_o} -max $tDQSCKmax             [get_ports {dm_rdqs_pad_io[*]}] -add_delay
set_input_delay -clock {ck_pad_o} -max $tDQSCKmax -clock_fall [get_ports {dm_rdqs_pad_io[*]}] -add_delay
set_input_delay -clock {ck_pad_o} -min $tDQSCKmin             [get_ports {dm_rdqs_pad_io[*]}] -add_delay
set_input_delay -clock {ck_pad_o} -min $tDQSCKmin -clock_fall [get_ports {dm_rdqs_pad_io[*]}] -add_delay

# Single Data Rate requires constraints for rising clock edge only


#**************************************************************
# Set Output Delay
#**************************************************************
# Double Data Rate requires constraints for both rising and falling clock edge
# Output max delay = max trace delay for data + tSU of external register – min trace delay for clock
# Output min delay = min trace delay for data – tH of external register – max trace delay for clock
# Assume (for now): max trace delay for data = min trace delay for clock 
#                   min trace delay for data = max trace delay for clock
# Data
set_output_delay -clock {ck_pad_o} -max $tISa              [get_ports {dq_pad_io[*]}] -add_delay
set_output_delay -clock {ck_pad_o} -max $tISa  -clock_fall [get_ports {dq_pad_io[*]}] -add_delay 
set_output_delay -clock {ck_pad_o} -min -$tIHa             [get_ports {dq_pad_io[*]}] -add_delay 
set_output_delay -clock {ck_pad_o} -min -$tIHa -clock_fall [get_ports {dq_pad_io[*]}] -add_delay 
# Data Strobe
set_output_delay -clock {ck_pad_o} -max $tISa              [get_ports {dqs_pad_io[*]}] -add_delay
set_output_delay -clock {ck_pad_o} -max $tISa  -clock_fall [get_ports {dqs_pad_io[*]}] -add_delay 
set_output_delay -clock {ck_pad_o} -min -$tIHa             [get_ports {dqs_pad_io[*]}] -add_delay 
set_output_delay -clock {ck_pad_o} -min -$tIHa -clock_fall [get_ports {dqs_pad_io[*]}] -add_delay 
# Data Strobe
set_output_delay -clock {ck_pad_o} -max $tISa              [get_ports {dqs_n_pad_io[*]}] -add_delay
set_output_delay -clock {ck_pad_o} -max $tISa  -clock_fall [get_ports {dqs_n_pad_io[*]}] -add_delay 
set_output_delay -clock {ck_pad_o} -min -$tIHa             [get_ports {dqs_n_pad_io[*]}] -add_delay 
set_output_delay -clock {ck_pad_o} -min -$tIHa -clock_fall [get_ports {dqs_n_pad_io[*]}] -add_delay 
# Data Mask
set_output_delay -clock {ck_pad_o} -max $tISa              [get_ports {dm_rdqs_pad_io[*]}] -add_delay
set_output_delay -clock {ck_pad_o} -max $tISa  -clock_fall [get_ports {dm_rdqs_pad_io[*]}] -add_delay 
set_output_delay -clock {ck_pad_o} -min -$tIHa             [get_ports {dm_rdqs_pad_io[*]}] -add_delay 
set_output_delay -clock {ck_pad_o} -min -$tIHa -clock_fall [get_ports {dm_rdqs_pad_io[*]}] -add_delay 

# Single Data Rate requires constraints for rising clock edge only
# Chip Select
set_output_delay -clock {ck_pad_o} -max $tISa  [get_ports {cs_n_pad_o}] -add_delay
set_output_delay -clock {ck_pad_o} -min -$tIHa [get_ports {cs_n_pad_o}] -add_delay
# Row Address Strobe
set_output_delay -clock {ck_pad_o} -max $tISa  [get_ports {ras_pad_o}] -add_delay
set_output_delay -clock {ck_pad_o} -min -$tIHa [get_ports {ras_pad_o}] -add_delay
# Column Address Strobe
set_output_delay -clock {ck_pad_o} -max $tISa  [get_ports {cas_pad_o}] -add_delay
set_output_delay -clock {ck_pad_o} -min -$tIHa [get_ports {cas_pad_o}] -add_delay
# Write Enable
set_output_delay -clock {ck_pad_o} -max $tISa  [get_ports {we_pad_o}] -add_delay
set_output_delay -clock {ck_pad_o} -min -$tIHa [get_ports {we_pad_o}] -add_delay
# Bank Address
set_output_delay -clock {ck_pad_o} -max $tISa  [get_ports {ba_pad_o[*]}] -add_delay
set_output_delay -clock {ck_pad_o} -min -$tIHa [get_ports {ba_pad_o[*]}] -add_delay
# Address
set_output_delay -clock {ck_pad_o} -max $tISa  [get_ports {addr_pad_o[*]}] -add_delay
set_output_delay -clock {ck_pad_o} -min -$tIHa [get_ports {addr_pad_o[*]}] -add_delay
# Clock Enable
set_output_delay -clock {ck_pad_o} -max $tISa  [get_ports {cke_pad_o}] -add_delay
set_output_delay -clock {ck_pad_o} -min -$tIHa [get_ports {cke_pad_o}] -add_delay


#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************

# Reset
set_false_path -from [get_ports {wb_rst}]

# Input Timing Exceptions
# False path exceptions for opposite-edge transfer
# Data
set_false_path -setup -fall_from [get_clocks ck_pad_o] -rise_to [get_clocks sdram_clk_270]
set_false_path -setup -rise_from [get_clocks ck_pad_o] -fall_to [get_clocks sdram_clk_270]
set_false_path -hold  -rise_from [get_clocks ck_pad_o] -fall_to [get_clocks sdram_clk_270]
set_false_path -hold  -fall_from [get_clocks ck_pad_o] -rise_to [get_clocks sdram_clk_270]
# Data Strobe
#set_false_path -setup -fall_from [get_clocks ck_pad_o] -rise_to [get_clocks sdram_clk_0]
#set_false_path -setup -rise_from [get_clocks ck_pad_o] -fall_to [get_clocks sdram_clk_0]
#set_false_path -hold  -rise_from [get_clocks ck_pad_o] -fall_to [get_clocks sdram_clk_0]
#set_false_path -hold  -fall_from [get_clocks ck_pad_o] -rise_to [get_clocks sdram_clk_0]

# Output Timing Exceptions
# False path exceptions for opposite-edge transfer
# Data
set_false_path -setup -rise_from [get_clocks sdram_clk_270] -fall_to [get_clocks ck_pad_o]
set_false_path -setup -fall_from [get_clocks sdram_clk_270] -rise_to [get_clocks ck_pad_o]
set_false_path -hold  -rise_from [get_clocks sdram_clk_270] -rise_to [get_clocks ck_pad_o]
set_false_path -hold  -fall_from [get_clocks sdram_clk_270] -fall_to [get_clocks ck_pad_o]
# Data Strobe
set_false_path -setup -rise_from [get_clocks sdram_clk_0] -fall_to [get_clocks ck_pad_o]
set_false_path -setup -fall_from [get_clocks sdram_clk_0] -rise_to [get_clocks ck_pad_o]
set_false_path -hold  -rise_from [get_clocks sdram_clk_0] -rise_to [get_clocks ck_pad_o]
set_false_path -hold  -fall_from [get_clocks sdram_clk_0] -fall_to [get_clocks ck_pad_o]


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


