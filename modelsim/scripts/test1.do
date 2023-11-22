add wave -position end  sim:/xtea_engine/i_clk
add wave -position end  sim:/xtea_engine/i_ende
add wave -position end  sim:/xtea_engine/i_key0
add wave -position end  sim:/xtea_engine/i_key1
add wave -position end  sim:/xtea_engine/i_key2
add wave -position end  sim:/xtea_engine/i_key3
add wave -position end  sim:/xtea_engine/i_rst
add wave -position end  sim:/xtea_engine/i_start
add wave -position end  sim:/xtea_engine/i_v0
add wave -position end  sim:/xtea_engine/i_v1
add wave -position end  sim:/xtea_engine/o_done
add wave -position end  sim:/xtea_engine/o_out0
add wave -position end  sim:/xtea_engine/o_out1

force -freeze sim:/xtea_engine/i_rst 0 0
force -freeze sim:/xtea_engine/i_start 1 0
force -freeze sim:/xtea_engine/i_clk 0 0, 1 {2 ps} -r 4
force -freeze sim:/xtea_engine/i_ende 1 0
force -freeze sim:/xtea_engine/i_v0 01101000011001010110110001101100 0
force -freeze sim:/xtea_engine/i_v1 01101111001100010011001000110011 0
force -freeze sim:/xtea_engine/i_key0 00110001001100100011001100110100 0
force -freeze sim:/xtea_engine/i_key1 00110101001101100011011100111000 0
force -freeze sim:/xtea_engine/i_key2 00110001001100100011001100110100 0
force -freeze sim:/xtea_engine/i_key3 00110101001101100011011100111000 0
run 1ns
force -freeze sim:/xtea_engine/i_start 0 0
run 1ns

force -freeze sim:/xtea_engine/i_start 1 0
force -freeze sim:/xtea_engine/i_ende 0 0
force -freeze sim:/xtea_engine/i_v0 10011110010111101110111011011111 0
force -freeze sim:/xtea_engine/i_v1 10110111101010111010110000101000 0
force -freeze sim:/xtea_engine/i_key0 00110001001100100011001100110100 0
force -freeze sim:/xtea_engine/i_key1 00110101001101100011011100111000 0
force -freeze sim:/xtea_engine/i_key2 00110001001100100011001100110100 0
force -freeze sim:/xtea_engine/i_key3 00110101001101100011011100111000 0
run 1ns
force -freeze sim:/xtea_engine/i_start 0 0
run 1ns