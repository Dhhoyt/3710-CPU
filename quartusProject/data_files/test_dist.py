res = ""
for i in range(320):
    res += format(i, '04x')   + "\n"

with open("testdist1.dat", "w") as f:
    f.write(res)