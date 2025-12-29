source /home/lab716/Desktop/Z/synopsys_dc.setup

#Read All Files
# read_verilog bitonic_sort.v
analyze -format verilog {bitonic_block.v bitonic_sort.v bitonic_node.v CAS.v}
elaborate bitonic_sort
current_design bitonic_sort
link

#Setting Clock Constraints
source -echo -verbose bitonic_sort_dc.sdc
set high_fanout_net_threshold 0
set_fix_multiple_port_nets -all -buffer_constants [get_designs *]
check_design
uniquify

#Synthesis all design
# compile -map_effort high -area_effort high
# compile -map_effort high -area_effort high -inc
compile


write -format ddc     -hierarchy -output "bitonic_sort_syn.ddc"
write_file -format verilog -hierarchy -output bitonic_sort_syn.v
write_sdf -version 2.1 bitonic_sort_syn.sdf
write_sdc -version 2.1 bitonic_sort_syn.sdc
report_area > area.log
report_power > power.log
report_timing -sign 4 > timing.log
report_timing -sign 4 -delay_type min > hold.log
report_timing -delay_type min > timing_hold.log
exit
