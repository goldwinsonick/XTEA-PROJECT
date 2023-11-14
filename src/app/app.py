import serial
from serial.tools import list_ports
import tkinter as tk

class Ser:
    def __init__(self):
        self.ser = serial.Serial()

    def configureSerial(self, port, baudrate):
        self.ser.port = port
        self.ser.baudrate = baudrate

    def getPortList(self):
        ports = list_ports.comports()
        return ports

    def readData(self):
        # read data from FPGA
        pass

    def sendData(self, file_path):
        # send data
        pass

class App(tk.Frame):
    def __init__(self, root):
        super().__init__(root)
        self.root = root
        self.ser = Ser()

        self.root.geometry("500x500")
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
        self.refreshPort()

        self.portSelectLabel = tk.Label(self.portFrame, text="Select FPGA Port: ")
        self.portSelectLabel.pack()
        self.portSelectEntry = tk.Entry(self.portFrame)
        self.portSelectEntry.pack()

        # INPUT
        self.inputFrame = tk.Frame(self.root, bg="#ddd")
        self.inputFrame.grid(row=1, column=0, sticky="news")
        self.filePathLabel = tk.Label(self.inputFrame, text="Path to File: ")
        self.filePathEntry = tk.Entry(self.inputFrame)
        self.filePathLabel.pack()
        self.filePathEntry.pack()

        self.keyLabel = tk.Label(self.inputFrame, text="Key/Password: ")
        self.keyEntry = tk.Entry(self.inputFrame)
        self.keyLabel.pack()
        self.keyEntry.pack()

        self.outputPathLabel = tk.Label(self.inputFrame, text="Output Path: ")
        self.outputPathEntry = tk.Entry(self.inputFrame)
        self.outputPathLabel.pack()
        self.outputPathEntry.pack()

        self.encryptBtn = tk.Button(self.inputFrame, text="encrypt")
        self.decryptBtn = tk.Button(self.inputFrame, text="decrypt")
        self.encryptBtn.pack()
        self.decryptBtn.pack()
    
    def refreshPort(self):
        temp = "Port(s) Available:\n"
        for port in self.ser.getPortList():
            temp += str(port)
            temp += "\n"
        self.portListStrVar.set(temp)
    
    def start(self):
        port = self.portSelectEntry.get()
        pathInput = self.filePathEntry.get()
        pathOutput = self.outputPathEntry.get()
        key = self.keyEntry.get()

root = tk.Tk()
app = App(root)
app.mainloop()