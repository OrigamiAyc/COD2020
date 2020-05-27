#Switch
set_property -dict { PACKAGE_PIN F16   IOSTANDARD LVCMOS33 } [get_ports { S }]; 
set_property -dict { PACKAGE_PIN D14   IOSTANDARD LVCMOS33 } [get_ports { R }]; 
#Led
set_property -dict { PACKAGE_PIN D18   IOSTANDARD LVCMOS33 } [get_ports { Q }]; 
set_property -dict { PACKAGE_PIN C17   IOSTANDARD LVCMOS33 } [get_ports { Q_n }]; 
set_property CFGBVS VCCO [current_design];
set_property CONFIG_VOLTAGE 3.3 [current_design];
set_property SEVERITY {Warning} [get_drc_checks LUTLP-1];