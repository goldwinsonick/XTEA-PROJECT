def compareFile(path1, path2):
    total = 0
    right = 0
    with open(path1, "rb") as file1:
        with open(path2, "rb") as file2:
            while(True):
                x1 = file1.read(1)
                x2 = file2.read(1)
                if(not x1):
                    break
                total += 1
                if(x1==x2):
                    right += 1
    print(total)
    print(right)
    print(right/total*100, end="%")
# compareFile(input("File1: "), input("File2: "))

compareFile("data/test4", "data/de4")
            