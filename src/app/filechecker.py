def compareFile(path1, path2, showFalseByte):
    total = 0
    wrong = 0
    with open(path1, "rb") as file1:
        with open(path2, "rb") as file2:
            while(True):
                x1 = file1.read(1)
                x2 = file2.read(1)
                if(not x1):
                    break
                total += 1
                if(x1 != x2):
                    wrong+=1
                    if(showFalseByte):
                        print("Kesalahan ke {}: (in Hex)".format(wrong))
                        print(x1.hex())
                        print(x2.hex())
    print("Total Byte       :" + str(total))
    print("Total Byte Salah :" + str(wrong))
    print("Akurasi          :" + str(((total-wrong)/total)*100) + "%")
# compareFile(input("File1: "), input("File2: "), True)

for i in range(1,6):
    compareFile("data/original/test" + str(i), "data/decrypted/de" + str(i), False)
    