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

root = tk.Tk()
app = App(root)
app.mainloop()