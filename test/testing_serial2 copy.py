f = open("./something3.txt", "w")
# x = "Password Email : helloworld12345"

clk0 = "2"
# def clockrst(path, speed):
#     f.write("force -freeze sim:/{}/rst 0 0\n".format(path))
#     f.write("force -freeze sim:/{}/clk 1 0, 0 {} -r 10".format(path, speed))
# clockrst("top_level/serialFPGA1/serialfpga_fsm_rx_1", clk0 + "ps")
# f.write("force -freeze sim:/top_level/serialFPGA1/serialFPGA_fsm_rx1/clk 1 0, 0 {1 ps} -r 2\n")
# f.write("force -freeze sim:/top_level/serialFPGA1/serialFPGA_fsm_rx1/rst 0 0\n")
f.write("force -freeze sim:/serialfpga/i_clk 1 0, 0 {1 ps} -r 2\n")
f.write("force -freeze sim:/serialfpga/i_rst_n 1 0\n")
f.write("run 10ps\n")
f.write("force -freeze sim:/serialfpga/i_rst_n 0 0\n")

clk1 = "10"
clk2 = "20"


def force(path, val):
    f.write("force -freeze sim:{} {} 0\n".format(path, val))

def sendByte(comm, vals):
    force("serialfpga/receive", "0")
    force("serialfpga/receive_data", "00100011") # Start byte
    f.write("run " + clk1 + "ps\n")
    force("serialfpga/receive", "1")
    f.write("run " + clk2 + "ps\n")

    force("serialfpga/receive", "0")
    # send command
    if(comm == "msg"):
        force("serialfpga/recieve_data", "01101101")
    elif(comm == "key"):
        force("serialfpga/receive_data", "01101011")
    elif(comm == "ende"):
        force("serialfpga/receive_data", "01100101")
    f.write("run " + clk1 + "ps\n")
    force("serialfpga/receive", "1")
    f.write("run " + clk2 + "ps\n")

    for val in vals:
        # send msg/key/ende
        force("serialfpga/receive", "0")
        force("serialfpga/receive_data", val)
        f.write("run " + clk1 + "ps\n")
        force("serialfpga/receive", "1")
        f.write("run " + clk2 + "ps\n")

    force("serialfpga/receive", "0")
    force("serialfpga/receive_data", "00100011") # Stop byte
    f.write("run " + clk1 + "ps\n")
    force("serialfpga/receive", "1")
    f.write("run " + clk2 + "ps\n")


        # force("top_level/serialFPGA1/receive", "0")
        # force("top_level/serialFPGA1/receive_data", "00000001") # Start byte
        # f.write("run " + clk1 + "ps\n")
        # force("top_level/serialFPGA1/receive", "1")
        # f.write("run " + clk2 + "ps\n")

        # force("top_level/serialFPGA1/receive", "0")
        # # send command
        # if(comm == "msg"):
        #     force("top_level/serialFPGA1/receive_data", "00000001")
        # elif(comm == "key"):
        #     force("top_level/serialFPGA1/receive_data", "00000010")
        # elif(comm == "ende"):
        #     force("top_level/serialFPGA1/receive_data", "00000011")
        # f.write("run " + clk1 + "ps\n")
        # force("top_level/serialFPGA1/receive", "1")
        # f.write("run " + clk2 + "ps\n")

        # # send msg/key/ende
        # force("top_level/serialFPGA1/receive", "0")
        # force("top_level/serialFPGA1/receive_data", val)
        # f.write("run " + clk1 + "ps\n")
        # force("top_level/serialFPGA1/receive", "1")
        # f.write("run " + clk2 + "ps\n")

        # force("top_level/serialFPGA1/receive", "0")
        # force("top_level/serialFPGA1/receive_data", "00000011") # Stop byte
        # f.write("run " + clk1 + "ps\n")
        # force("top_level/serialFPGA1/receive", "1")
        # f.write("run " + clk2 + "ps\n")

def strbinary(stri):
    return [bin(ord(char))[2:].zfill(8) for char in stri]
key = "12345678abcdefgh"
# msg = "Passworld Email : helloworld12345"
msg = "abcdefgh"
ende = "1"

force("serialfpga/receive", "1")
f.write("run " + clk1 + "ps\n")
sendByte("key", strbinary(key))
# sendByte("msg", strbinary(msg))
# sendByte("ende", "00000001")