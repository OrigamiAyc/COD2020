#Switch
set_property -dict { PACKAGE_PIN H16   IOSTANDARD LVCMOS33 } [get_ports { din[3] }]; 
set_property -dict { PACKAGE_PIN G13   IOSTANDARD LVCMOS33 } [get_ports { din[2] }]; 
set_property -dict { PACKAGE_PIN F13   IOSTANDARD LVCMOS33 } [get_ports { din[1] }]; 
set_property -dict { PACKAGE_PIN E16   IOSTANDARD LVCMOS33 } [get_ports { din[0] }];  
set_property -dict { PACKAGE_PIN F16   IOSTANDARD LVCMOS33 } [get_ports { clk }]; 
set_property -dict { PACKAGE_PIN D14   IOSTANDARD LVCMOS33 } [get_ports { rst }]; 
#Led
set_property -dict { PACKAGE_PIN G18   IOSTANDARD LVCMOS33 } [get_ports { dout[3] }]; 
set_property -dict { PACKAGE_PIN F18   IOSTANDARD LVCMOS33 } [get_ports { dout[2] }]; 
set_property -dict { PACKAGE_PIN E17   IOSTANDARD LVCMOS33 } [get_ports { dout[1] }]; 
set_property -dict { PACKAGE_PIN D17   IOSTANDARD LVCMOS33 } [get_ports { dout[0] }]; 
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets {clk_IBUF}];