with open("data.txt", "w") as f:
	output = ""
	for i in range(2 ** 16):
		output += "0000000000000000\n"
	f.write(output)