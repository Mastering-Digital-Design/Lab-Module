add wave -position end  sysclk
add wave -position end -hexadecimal data_in
add wave -position end load
add wave -position end  dac_sdi
add wave -position end  dac_cs
add wave -position end  dac_sck
add wave -position end  dac_ld
force sysclk 1 0, 0 10ns -r 20ns
force data_in 10'h23b
force load 0
run 200ns
force load 1
run 400ns
force load 0
run 20us


