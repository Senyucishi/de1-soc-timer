create_clock -name CLOCK_50 -period 20.000 [get_ports {CLOCK_50}]

# Board switches and buttons feed two-register synchronizers.
set_false_path -from [get_ports {KEY[*] SW[*]}]
