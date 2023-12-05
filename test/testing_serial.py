f = open("./something.txt", "w")
x = "hello this is a msg and I want to encrypt this.."
def setBit(pin, val):
    f.write("force -freeze sim:/serialfpga_fsm_tx/{} {} 0\n".format(pin, val))
    print("force -freeze sim:/serialfpga_fsm_tx/{} {} 0".format(pin, val))
f.write("force -freeze sim:/serialfpga_fsm_tx/clk 1 0, 0 {5 ps} -r 10\nforce -freeze sim:/serialfpga_fsm_tx/rst 0 0\n")


# setBit("i_recv", "1")
# setBit("i_recvByte", "00000001")
# f.write("run 20ps\n")
# setBit("i_recv", "0")
# f.write("run 20ps\n")
# for c in x:
#     c_bin = format(ord(c), '08b')
#     setBit("i_recv", '1')
#     setBit("i_recvByte", "00000001")
#     f.write("run 20ps\n")
#     setBit("i_recv", '0')
#     f.write("run 20ps\n")

#     setBit("i_recv", '1')
#     setBit("i_recvByte", c_bin)
#     f.write("run 20ps\n")
#     setBit("i_recv", '0')
#     f.write("run 20ps\n")

# setBit("i_recv", "1")
# setBit("i_recvByte", "00000011")
# setBit("i_recv", "0")
# f.write("run 20ps\n")

# f.close()
#--------------------------------------------------------------------------
setBit("i_v0", "11001010110010101100101011001010")
setBit("i_v1", "11110000111100001111000011110000")
setBit("i_tx_ready", "0")
setBit("i_done", "0")
f.write("run 50ps\n")
setBit("i_done", "1")
f.write("run 50ps\n")
setBit("i_tx_ready", "1")
f.write("run 500ps\n")
f.close()





