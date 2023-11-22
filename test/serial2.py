import time
import serial
from serial.tools import list_ports

portlist = list_ports.comports()
for port in portlist:
    print(port)
port = input("Port: ")
ser = serial.Serial()
baudrate = 9600
ser.port = port
ser.baudrate = baudrate
ser.timeout = 0


startbyte = b'\x01'
stopbyte = b'\x02'
isEncrypt = "1"
key = "abcdefghefgh"
while(len(key)<16):
    key += "0"
dataframe = bytearray()
dataframe += startbyte + bytearray(isEncrypt + key, 'utf-8') + stopbyte

ser.open()
time.sleep(2)

ser.write(dataframe)

while True:
    while(ser.inWaiting() > 0):
        recvByte = ser.read(1)
        print(recvByte, end="")
        if(recvByte == b'\x02'):
            break

ser.close()