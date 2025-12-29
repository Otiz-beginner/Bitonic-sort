# CHIP Level Constraint

set cycle  10.0        ;#clock period defined by designer

create_clock -period $cycle [get_ports  clk]
set_fix_hold                [get_clocks clk]
set_dont_touch_network      [get_clocks clk]
set_clock_uncertainty  0.1  [get_clocks clk]
set_clock_latency      0.5  [get_clocks clk]
set_ideal_network           [get_ports clk]

set_input_delay  -max 1   -clock clk [remove_from_collection [all_inputs] [get_ports clk]] 
set_input_delay  -min 0   -clock clk [remove_from_collection [all_inputs] [get_ports clk]] 
set_output_delay 1 -clock clk [all_outputs]
set_load         1                [all_outputs]
set_drive        0.1              [all_inputs]

set_operating_conditions -max_library fsa0m_a_generic_core_ss1p62v125c -max WCCOM
set_wire_load_model -name G1000K -library fsa0m_a_generic_core_ss1p62v125c                    
