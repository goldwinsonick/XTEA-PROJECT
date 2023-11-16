import time
import serial
from serial.tools import list_ports

ser = serial.Serial()

portlist = list_ports.comports()
for port in portlist:
    print(port)
port = input("Port: ")
baudrate = 9600
ser.port = port
ser.baudrate = baudrate
ser.timeout = 0

startbyte = 0x01
stopbyte = 0x02
isEncrypt = "1"
key = "abcdefghefgh"
while(len(key)<16):
    key += "0"
dataframe = bytearray()
dataframe.append(startbyte)
dataframe += bytearray(isEncrypt + key, 'utf-8')
dataframe.append(stopbyte)

ser.open()
ser.write(dataframe)
print("sent")
print("--")
time.sleep(5)

# Recieve Bytes
while 1:
    while(ser.inWaiting() > 0):
        recvByte = ser.read(1)
        print(recvByte)

ser.close()