import argparse


def convert(filename):
	file = open(filename, 'r')
	out = open('mifText.mif', 'w')

	fileLines = file.readlines()
	lineCount = len(fileLines) - 1


	out.write('''-- begin_signature
-- memory
-- end_signature
WIDTH=16;
DEPTH=65536;

ADDRESS_RADIX=UNS;
DATA_RADIX=BIN;

CONTENT BEGIN\n''')
	for i, line in enumerate(reversed(fileLines)):
		out.write(f'\t{lineCount - i} :\t{bin(int(line, 16))[2:].zfill(16)};\n')
	out.write('END;\n')

	file.close()
	out.close()


parser = argparse.ArgumentParser(description='GEnerates a mif format')
parser.add_argument('file', nargs='?', help='The hex file to reformat')
args = parser.parse_args()

if args.file != None:
	convert(args.file)

