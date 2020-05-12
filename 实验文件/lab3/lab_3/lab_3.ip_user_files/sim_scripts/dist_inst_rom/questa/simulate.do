onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib dist_inst_rom_opt

do {wave.do}

view wave
view structure
view signals

do {dist_inst_rom.udo}

run -all

quit -force
