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

writeRandomFile("data/test1", 1)
writeRandomFile("data/test2", 10)
writeRandomFile("data/test3", 100)
writeRandomFile("data/test4", 1000)
writeRandomFile("data/test5", 10000)