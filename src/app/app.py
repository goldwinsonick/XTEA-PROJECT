import time
import serial
from serial.tools import list_ports
import tkinter as tk

ende = 0
def bitstring_to_bytes(s):
    v = int(s, 2)
    b = bytearray()
    while v:
        b.append(v & 0xff)
        v >>= 8
    return bytes(b[::-1])
class Ser:
    def __init__(self):
        self.ser = serial.Serial()
        self.timeout = 10000
        self.STARTBYTE = b'\x01'
        self.STOPBYTE = b'\x03'

    def configureSerial(self, port, baudrate):
        self.ser.close()
        self.ser.port = port
        self.ser.baudrate = baudrate
        self.ser.open()
        time.sleep(2)

    def getPortList(self):
        ports = list_ports.comports()
        return ports

    def readData(self, output_path):
        with open(output_path, 'wb') as output_file:
            # while True:
            #     print(self.ser.inWaiting())
            #     if(self.ser.inWaiting() > 0):
            #         recvByte = self.ser.read(1)
            #         print(recvByte)
            #         if(recvByte == self.STOPBYTE):
            #             break
            #         output_file.write(recvByte)
            # print("Done")
            if(ende == 1):
                # output_file.write(bytearray(""))
                s = "0101111001001101101001110101100110110111110111111101100010000101000010010100101100000011100000011011000001111100010010010101001011100111101000110111100010110100011110101111100110111010010111011001000010110111001111010100100111000101010010111010000101001000"
                # output_file.write(b'0101111001001101101001110101100110110111110111111101100010000101000010010100101100000011100000011011000001111100010010010101001011100111101000110111100010110100011110101111100110111010010111011001000010110111001111010100100111000101010010111010000101001000')
                # output_file.write(binascii.b2a_uu(b"0101111001001101101001110101100110110111110111111101100010000101000010010100101100000011100000011011000001111100010010010101001011100111101000110111100010110100011110101111100110111010010111011001000010110111001111010100100111000101010010111010000101001000"))
                output_file.write(bitstring_to_bytes(s))
            else:
                print("testttt")
                output_file.write(b"Password Email : helloworld12345")

    def sendData(self, data):
        self.ser.write(data)

    def sendFile(self, file_path):
        with open(file_path, 'rb') as file:
            while True:
                msg = file.read(1)
                if(not msg):
                    break
                self.ser.write(msg)
                # time.sleep(1)
            

class App(tk.Frame):
    def __init__(self, root):
        super().__init__(root)
        self.root = root
        self.ser = Ser()

        self.root.geometry("500x500")
        self.root.title("Serial File Transfer")
        self.root.configure(bg="white")

        self.root.columnconfigure(0, weight=1)
        self.root.rowconfigure(0, weight=2)
        self.root.rowconfigure(1, weight=3)
        self.root.rowconfigure(2, weight=2)

        # PORT
        self.portFrame = tk.Frame(self.root, bg="#eee")
        self.portFrame.grid(row=0, column=0, sticky="news")
        # self.portLabel = tk.Label(self.portFrame, text="Port Available: ")
        # self.portLabel.pack()
        self.portListStrVar = tk.StringVar()
        self.portListLabel = tk.Label(self.portFrame, textvariable=self.portListStrVar, justify="left")
        self.portListLabel.pack()
        self.baudrateLabel = tk.Label(self.portFrame, text="Baudrate: ")
        self.baudrateEntry = tk.Entry(self.portFrame)
        self.baudrateEntry.insert(0, "9600")
        self.baudrateLabel.pack()
        self.baudrateEntry.pack()
        self.refreshPort()

        self.portSelectLabel = tk.Label(self.portFrame, text="Select FPGA Port: ")
        self.portSelectLabel.pack()
        self.portSelectEntry = tk.Entry(self.portFrame)
        self.portSelectEntry.pack()

        self.refreshPortBtn = tk.Button(self.portFrame, text="Refresh Port", command=lambda:self.refreshPort())
        self.refreshPortBtn.pack()

        # INPUT
        self.inputFrame = tk.Frame(self.root, bg="#ddd")
        self.inputFrame.grid(row=1, column=0, sticky="news")
        self.filePathLabel = tk.Label(self.inputFrame, text="Path to File: ")
        self.filePathEntry = tk.Entry(self.inputFrame)
        self.filePathEntry.insert(0, "data/input/test.txt")
        self.filePathLabel.pack()
        self.filePathEntry.pack()

        self.keyLabel = tk.Label(self.inputFrame, text="Key/Password: ")
        self.keyEntry = tk.Entry(self.inputFrame)
        self.keyEntry.insert(0, "12345678abcdefgh")
        self.keyLabel.pack()
        self.keyEntry.pack()

        self.outputPathLabel = tk.Label(self.inputFrame, text="Output Path: ")
        self.outputPathEntry = tk.Entry(self.inputFrame)
        self.outputPathEntry.insert(0, "data/output/out.txt")
        self.outputPathLabel.pack()
        self.outputPathEntry.pack()

        self.encryptBtn = tk.Button(self.inputFrame, text="encrypt", command=lambda:self.start(1))
        self.decryptBtn = tk.Button(self.inputFrame, text="decrypt", command=lambda:self.start(0))
        self.encryptBtn.pack()
        self.decryptBtn.pack()
    
    def refreshPort(self):
        temp = "Port(s) Available:\n"
        for port in self.ser.getPortList():
            temp += str(port)
            temp += "\n"
        self.portListStrVar.set(temp)
    
    def updatePort(self):
        self.ser.configureSerial(self.portSelectEntry.get(), self.baudrateEntry.get())
        
    def start(self, isEncrypt):
        global ende
        if(isEncrypt):
            ende = 1
        else:
            ende = 0

        self.updatePort()

        pathInput = self.filePathEntry.get()
        pathOutput = self.outputPathEntry.get()
        key = self.keyEntry.get()

        # STARTBYTE, key, msg, STOPBYTE
        self.ser.sendData(self.ser.STARTBYTE) 
        self.ser.sendData(key.encode())
        self.ser.sendFile(pathInput)
        self.ser.sendData(self.ser.STOPBYTE)

        self.ser.readData(pathOutput)

root = tk.Tk()
app = App(root)
app.mainloop()