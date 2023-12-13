import os
import random
import string
alphanumeric = string.ascii_letters + string.digits
def writeRandomFile(path, size):
    with open(path, "wb") as fileOutput:
        # fileOutput.write(os.urandom(size))
        for i in range(size):
            fileOutput.write(bytearray(random.choice(alphanumeric).encode()))
# writeRandomFile(input("Path: "), input("Size: "))

writeRandomFile("data/original/test1", 1)
writeRandomFile("data/original/test2", 10)
writeRandomFile("data/original/test3", 100)
writeRandomFile("data/original/test4", 1000)
writeRandomFile("data/original/test5", 10000)