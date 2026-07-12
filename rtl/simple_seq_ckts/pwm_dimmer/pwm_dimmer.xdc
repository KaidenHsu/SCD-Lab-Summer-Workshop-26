# ZedBoard 100 MHz PL clock and center pushbutton reset.
set_property -dict { PACKAGE_PIN Y9 IOSTANDARD LVCMOS33 } [get_ports { clk }]
create_clock -name clk -period 10.000 [get_ports { clk }]
set_property -dict { PACKAGE_PIN P16 IOSTANDARD LVCMOS33 } [get_ports { rst }]

# ZedBoard user switches SW0 through SW7 set the brightness value.
set_property -dict { PACKAGE_PIN F22 IOSTANDARD LVCMOS33 } [get_ports { brightness[0] }]
set_property -dict { PACKAGE_PIN G22 IOSTANDARD LVCMOS33 } [get_ports { brightness[1] }]
set_property -dict { PACKAGE_PIN H22 IOSTANDARD LVCMOS33 } [get_ports { brightness[2] }]
set_property -dict { PACKAGE_PIN F21 IOSTANDARD LVCMOS33 } [get_ports { brightness[3] }]
set_property -dict { PACKAGE_PIN H19 IOSTANDARD LVCMOS33 } [get_ports { brightness[4] }]
set_property -dict { PACKAGE_PIN H18 IOSTANDARD LVCMOS33 } [get_ports { brightness[5] }]
set_property -dict { PACKAGE_PIN H17 IOSTANDARD LVCMOS33 } [get_ports { brightness[6] }]
set_property -dict { PACKAGE_PIN M15 IOSTANDARD LVCMOS33 } [get_ports { brightness[7] }]

# LED LD0 shows the PWM output.
set_property -dict { PACKAGE_PIN T22 IOSTANDARD LVCMOS33 } [get_ports { led }]
