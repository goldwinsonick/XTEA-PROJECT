import time
from datetime import datetime
import serial
from serial.tools import list_ports
import tkinter as tk
class Ser:
    def __init__(self):
        self.ser = serial.Serial()
        self.timeout = 10
        self.STARTBYTE = b'#'
        self.STOPBYTE = b'#'
        self.cnt = 0;

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
        print("Waiting for " + str(self.cnt) + " bytes...")
        temp = 0
        with open(output_path, 'wb') as output_file:
            while True:
                if(self.ser.inWaiting() > 0):
                    temp += 1
                    recvByte = self.ser.read(1)
                    print("Recieved: ", end="")
                    print(recvByte)
                    output_file.write(recvByte)
                if(temp >= self.cnt):
                    break

    def sendData(self, data):
        self.ser.write(data)

    def sendFile(self, file_path):
        self.cnt = 0
        with open(file_path, 'rb') as file:
            while True:
                self.sendData(b'#m')

                msg = file.read(8)
                if(not msg):
                    break
                self.cnt+=8
                self.ser.write(msg)
                for i in range(8-len(msg)):
                    self.ser.write(b' ')

                self.sendData(b'#')
                self.sendData(b'#pa##')

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

        self.updatePortBtn = tk.Button(self.portFrame, text="Update Port", command=lambda:self.updatePort())
        self.updatePortBtn.pack()

        # INPUT
        self.inputFrame = tk.Frame(self.root, bg="#ddd")
        self.inputFrame.grid(row=1, column=0, sticky="news")
        self.filePathLabel = tk.Label(self.inputFrame, text="Path to File: ")
        self.filePathEntry = tk.Entry(self.inputFrame)
        self.filePathEntry.insert(0, "data/test1.txt")
        self.filePathLabel.pack()
        self.filePathEntry.pack()

        self.keyLabel = tk.Label(self.inputFrame, text="Key/Password: ")
        self.keyEntry = tk.Entry(self.inputFrame)
        self.keyEntry.insert(0, "12345678abcdefgh")
        self.keyLabel.pack()
        self.keyEntry.pack()

        self.outputPathLabel = tk.Label(self.inputFrame, text="Output Path: ")
        self.outputPathEntry = tk.Entry(self.inputFrame)
        self.outputPathEntry.insert(0, "data/outtest1.txt")
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
        pathInput = self.filePathEntry.get()
        pathOutput = self.outputPathEntry.get()
        key = self.keyEntry.get()

        # Send key
        self.ser.sendData(b'#k')
        self.ser.sendData(key.encode())
        self.ser.sendData(b'#')

        # Send ende
        self.ser.sendData(b'#e')
        if(isEncrypt):
            self.ser.sendData(b'00110001')
        else:
            self.ser.sendData(b'00110000')
        self.ser.sendData(b'#')

        # Send msg
        self.ser.sendFile(pathInput)

        self.ser.readData(pathOutput)

root = tk.Tk()
app = App(root)
app.mainloop()