import os
import sys
import argparse

labels: dict[str,int] = {}
jpoint_instrs = {}
macros : dict[str,str] = {}

RAM_START = 8192
FILE_LENGTH = 2 ** 16

r_type_insts =   {'ADD',  'ADDU',  'ADDC',  'MUL',  'SUB',  'SUBC',  'CMP',  'AND',  'OR',  'XOR',  'MOV', 'SIN', 'COS'}
i_type_insts =   {'ADDI', 'ADDUI', 'ADDCI', 'MULI', 'SUBI', 'SUBCI', 'CMPI', 'ANDI', 'ORI', 'XORI', 'MOVI', 'LUI'}
sh_type_insts =  {'LSH', 'ALSH'}
shi_type_insts = {'LSHI', 'ALSHI'}
b_type_insts =   {'BEQ', 'BNE', 'BGE', 'BCS', 'BCC', 'BHI', 'BLS', 'BLO', 'BHS', 'BGT', 'BLE', 'BFS', 'BFC', 'BLT', 'BUC', 'BINT'}
j_type_insts =   {'JEQ', 'JNE', 'JGE', 'JCS', 'JCC', 'JHI', 'JLS', 'JLO', 'JHS', 'JGT', 'JLE', 'JFS', 'JFC', 'JLT', 'JUC'}
spec_type_insts= {'LOAD', 'STOR', 'JAL'}
dist_1_type_insts= {'LODW', 'DIST', 'TXUV'}
dist_2_type_insts= {'LODP', 'LODR'}


sign_ext_imm =   {'ADDI', 'ADDUI', 'ADDCI', 'MULI', 'SUBI', 'SUBCI', 'CMPI'}
zero_ext_imm =   {'ANDI', 'ORI', 'XORI', 'MOVI', 'LUI'}

# Used by CALL expansion
parameter_regs = ['%r8', '%r9', '%rB', '%rC', '%rD']

reg_codes : dict[str,str] = {
    '%r0': '0',
    '%r1': '1',
    '%r2': '2',
    '%r3': '3',
    '%r4': '4',
    '%r5': '5',
    '%r6': '6',
    '%r7': '7',
    '%r8': '8',
    '%r9': '9',
    '%r10': 'A',
    '%r11': 'B',
    '%r12': 'C',
    '%r13': 'D',
    '%r14': 'E',
    '%r15': 'F',
    '%rA': 'A',
    '%rB': 'B',
    '%rC': 'C',
    '%rD': 'D',
    '%rE': 'E',
    '%rF': 'F',
    '%ra': 'A',
    '%rb': 'B',
    '%rc': 'C',
    '%rd': 'D',
    '%re': 'E',
    '%rf': 'F',
    '%csp': 'F',
    '%gsp': 'E'
}

inst_codes : dict[str,str] = {
    'REGISTER_TYPE': '0',
    'WAIT':  '0',
    'AND':   '1',
    'ANDI':  '1',
    'OR':    '2',
    'ORI':   '2',
    'XOR':   '3',
    'XORI':  '3',

    'ADD':   '5',
    'ADDI':  '5',
    'ADDU':  '6',
    'ADDUI': '6',
    'ADDC':  '7',
    'ADDCI': '7',
    'MOV':   'D',
    'MOVI':  'D',
    'MUL':   'C',
    'MULI':  'E',
    'SUB':   '9',
    'SUBI':  '9',
    'SUBC':  'A',
    'SUBCI': 'A',
    'CMP':   'B',
    'CMPI':  'B',

    'COS':   'E',
    'SIN':   'F',

    'SHIFT_TYPE': '8',
    'LSH':   '4',
    'LSHI':  '0',
    'ASHU':  '4',
    'ASHUI': '2',

    'LUI':  'F',

    'SPECIAL_TYPE': '4',
    'LOAD': '0',
    'LPR':  '1',
    'SNXB': '2',
    'DI':   '3',
    'STOR': '4',
    'SPR':  '5',
    'ZRXB': '6',
    'EI':   '7',
    'JAL':  '8',
    'RETX': '9',
    'TBIT': 'A',
    'EXCP': 'B',
    'TBITI':'E',

    'DISTANCE_1_TYPE': 'E',
    'LODW': '2',
    'DIST': '3',
    'TXUV': '4',

    'DISTANCE_2_TYPE': 'E',
    'LODP': '0',
    'LODR': '1',
    

    'BRANCH': 'C',
    'JUMP': 'C',

    'EQ' : '0',
    'NE' : '1',
    'CS' : '2',
    'CC' : '3',
    'HI' : '4',
    'LS' : '5',
    'GT' : '6',
    'LE' : '7',
    'FS' : '8',
    'FC' : '9',
    'LO' : 'A',
    'HS' : 'B',
    'LT' : 'C',
    'GE' : 'D',
    'UC' : 'E',
    'INT': 'F'
}

# from https://stackoverflow.com/questions/38834378/path-to-a-directory-as-argparse-argument
def dir_path(path):
    if os.path.isdir(path):
        return path
    else:
        raise argparse.ArgumentTypeError(f"readable_dir:{path} is not a valid path")

def byte(number, i):
    return (number & (0xff << (i * 8))) >> (i * 8)

def replaceLabel(label):
    def r(l):
        if (l[0] == '.'):
            return '$' + str(labels[l])
        else:
            return l

    if (label.startswith('JPT')):
        return label
    else:
        m = map(r, label.split())
        return ' '.join(m)

def replaceMacros(parts: list[str]):
    toreturn: list[str] = []
    if len(parts) > 0 and parts[0] == '`define': return []
    for s in parts:
        if s[0] == '`':
            if s[1:] in macros:
                toreturn.append(macros[s[1:]])
            else:
                sys.exit(f"Undefined macro: {s}")
        else:
            toreturn.append(s)
    return toreturn

def parseImm(token):
    if token.startswith('$$'):
        parsed = int(float(token[2:]) * 256)
    elif token.startswith('$'):
        parsed = int(token[1:])
    else:
        sys.exit(f'ERROR: Badly formatted imm \'{token}\'')
	
    return parsed

# casey wolfe added some code here to define multi line macros
# use ~ to denote more lines
def precompile(filename):
    f = open(filename, 'r')
    df = open('defined.mc', 'w')

    inMacro = False
    macroName = ''
    # Find all macro definitions
    for i, x in enumerate(f):
        line = x.split('#')[0]
        parts = line.split()

        if inMacro: # added multiline macros
            if len(parts) > 0 and parts[0]=='~':
                macros[macroName] = macros[macroName] + '\n' + ' '.join([x for x in parts[1:]])
            else:
                inMacro = False
                macroName = ''
        
        if len(parts) > 0 and parts[0]=='`define':
            inMacro = True
            macroName = parts[1]
            macros[macroName] = ' '.join([str(x) for x in parts[2:]]) # added whole line here
        


    
    print(f'Macros found: {macros}')

    f.seek(0)

    for line in f:
        if line[0] == '~':
            continue

        parts = replaceMacros(line.split())
        if len(parts) > 0 and parts[0] == 'CALL':
            if len(parts) < 2:
                sys.exit('not enough CALL args')
            label = parts[1]
            # reglist = parts[2][1:-1].split(',') # Commented out because moving data like this before a function is wasteful
            # if len(reglist) > 5:
            #     sys.exit('too many parameters')
            # for i, reg in enumerate(reglist):
            #     if reg != '':
            #         df.write(f'MOV {reg} {parameter_regs[i]}\n')
            df.write(f'MOVI {label} %rA\n')
            df.write(f'LUI {label} %rA\n')
            df.write(f'JAL %rA %rA\n')
        elif len(parts) > 0 and parts[0] == 'MOVW':
            if len(parts) < 3:
                sys.exit('not enough MOVW args')
            imm = parts[1]
            rdst = parts[2]
            parsed_imm = parseImm(imm)
            if parsed_imm > 0xFFFF:
                sys.exit(f'MOVW imm too large, must be less than 0xFFFF, found {parsed_imm}')
            lo_byte = byte(parsed_imm, 0)
            hi_byte = byte(parsed_imm, 1)
            df.write(f'MOVI ${lo_byte} {rdst}\n')
            df.write(f'LUI ${hi_byte} {rdst}\n')
        elif len(parts) > 0 and parts[0] in {'SIN', 'COS'}: # insert dummy/unused register 0
            parts.insert(1, f'%r0')
            df.write(' '.join(parts) + '\n')
        else:
            df.write(' '.join(parts) + '\n')

    f.close()
    df.close()

def assemble(filename: str):
    # find the labels and their addresses
    f = open('defined.mc', 'r')

    address = -1

    # Build the dict for resolving labels
    for x in f:
        line = x.split('#')[0] # discard comment at end of line
        parts = line.split()
        
        if len(parts) > 0:
            if line[0] == '.':
                labelAddress = address + 1

                if labelAddress % 2 == 0:
                    odd = False
                else:
                    odd = True
                    labelAddress -= 1
                    
                # reduce to shift for 8-bit immediate
                # while labelAddress > 127:
                #     labelAddress //= 2

                label = parts.pop(0)
	
                if odd:
                    # if it is odd, we have to correct for the -1 above
                    labels[label] = labelAddress + 1
                else:
                    labels[label] = labelAddress
            else:
                address = address + 1

    f.close()

    print(f"Labels found: {labels}")

    f = open('defined.mc', 'r')
    filename = filename.replace('\\', '/')
    start = filename.rindex('/')+1 if '/' in filename else 0
    out_name = f"{output_dir}{filename[start:filename.rindex('.')]}.dat"
    wf = open(f"{out_name}", 'w')
    sf = open(f'{output_dir}stripped.mc', 'w')

    ram = False
    address = -1
    for i, x in enumerate(f):
        line = x.split('#')[0] # discard comment at end of line
        parts = line.split()
        if len(parts) > 0 and line[0] == '@':
            ram = True
            break
        if len(parts) > 0 and line[0] != '.' and line[0] != '`':
            for part in parts:
                sf.write(part + ' ')
            sf.write('\n')
            address = address + 1
            instr = parts.pop(0)
            if instr == 'WAIT':
                wf.write('0000\n')
            elif instr in r_type_insts: # ----------------------------------------------------------------------------------------
                # i.e. ADD %r1 %r2 -> 0251
                if len(parts) != 2:
                    sys.exit(f'ERROR: Wrong number of args on line {i+1} in instruction {x}\n\tExpected: 2, Found: {len(parts)}')
                else:
                    r_src, r_dst = parts
                    if r_src not in reg_codes or r_dst not in reg_codes:
                        sys.exit(f'ERROR: Unrecognized register on line {i+1} in instruction {x}')
                    else:
                        wf.write(inst_codes['REGISTER_TYPE'] + reg_codes[r_dst] + inst_codes[instr] + reg_codes[r_src] + '\n')
            elif instr in i_type_insts: # ----------------------------------------------------------------------------------------
                if len(parts) != 2:
                    sys.exit(f'ERROR: Wrong number of args on line {i+1} in instruction {x}\n\tExpected: 2, Found: {len(parts)}')
                else:
                    imm, r_dst = parts
                    if r_dst not in reg_codes:
                        sys.exit(f'ERROR: Unrecognized register on line {i+1} in instruction {x}')
                    if imm[0] == '$':
                        parsed_imm = int(imm[1:])
                    elif imm[0] == '.':
                        parsed_imm = labels[imm]
                        if instr == 'MOVI':
                            parsed_imm = parsed_imm & 0xFF
                        elif instr == 'LUI':
                            parsed_imm = (parsed_imm & 0xFF00) >> 8
                    else:
                        sys.exit(f'ERROR: Badly formatted imm on line {i+1} in instruction {x}'
                                +f'\n\tExpected imm to start with: \'$\', but found: \'{imm[0]}\'')

                    if parsed_imm > 0xFF or parsed_imm < -128:
                        sys.exit(f'ERROR: Out of range imm on line {i+1} in instruction {x}'
                                +f'\n\tImmediate must be between -127 and 255, found {parsed_imm}')
                    if instr in sign_ext_imm:
                        if parsed_imm > 127:
                            print(f'WARNING: Found large imm that will be sign extended on line {i+1} in instruction {x}'
                                    +f'\n\t{parsed_imm} will become {int.from_bytes(parsed_imm.to_bytes(1, byteorder="big"), byteorder="big", signed=True)}')
                            # That funkiness in that print is to cast to a byte, then back to an int using 2's C
                    elif instr in zero_ext_imm:
                        if parsed_imm < 0:
                            print(f'WARNING: Found negative imm that will be zero extended on line {i+1} in instruction {x}'
                                    +f'\n\t{parsed_imm} will become {parsed_imm & 0xFF}')
                    else:
                        sys.exit(f'CRASHED: Something went horribly wrong. An inst was in the i_type set, I do not know how the imm is extended')
                    formatted_imm = f'{(parsed_imm & 0xFF):02X}'
                    wf.write(inst_codes[instr] + reg_codes[r_dst] + formatted_imm + '\n')
            elif instr in sh_type_insts: # ----------------------------------------------------------------------------------------
                if len(parts) != 2:
                    sys.exit(f'ERROR: Wrong number of args on line {i+1} in instruction {x}\n\tExpected: 2, Found: {len(parts)}')
                else:
                    r_src, r_dst = parts
                    if r_src not in reg_codes or r_dst not in reg_codes:
                        sys.exit(f'ERROR: Unrecognized register on line {i+1} in instruction {x}')
                    else:
                        wf.write(inst_codes['SHIFT_TYPE'] + reg_codes[r_dst] + inst_codes[instr] + reg_codes[r_src] + '\n')
            elif instr in shi_type_insts: # ----------------------------------------------------------------------------------------
                if len(parts) != 2:
                    sys.exit(f'ERROR: Wrong number of args on line {i+1} in instruction {x}\n\tExpected: 2, Found: {len(parts)}')
                else:
                    imm, r_dst = parts
                    if imm[0] != '$':
                        sys.exit(f'ERROR: Badly formatted imm on line {i+1} in instruction {x}'
                                +f'\n\tExpected imm to start with: \'$\', but found \'{imm[0]}\'')
                    if r_dst not in reg_codes:
                        sys.exit(f'ERROR: Unrecognized register on line {i+1} in instruction {x}')
                    else:
                        parsed_imm = int(imm[1:])
                        if parsed_imm > 15 or -5 > parsed_imm:
                            sys.exit(f'ERROR: Out of range imm on line {i+1} in inst {x}'
                                    +f'\n\tImmediate must be between 0 and 15, found {parsed_imm}')
                        else:  
                            # formatted_imm = f'{parsed_imm:01X}'
                            formatted_imm = hex((parsed_imm + (1 << 4)) % (1 << 4))[2:]
                            sign_bit = parsed_imm < 0
                            # TODO: Bandaid fix, ASHUI is now unsupported
                            wf.write('8' + reg_codes[r_dst] + str(int(sign_bit)) + formatted_imm + '\n')
            elif instr in b_type_insts: # ----------------------------------------------------------------------------------------
                if len(parts) != 1:
                    sys.exit(f'ERROR: Wrong number of args on line {i+1} in instruction {x}\n\tExpected: 1, Found: {len(parts)}')
                else:
                    displacement = parts[0]
                    if displacement[0] == '$': # if displacement is imm
                        parsed_disp = int(displacement[1:]) # cut off first char
                        if parsed_disp > 255 or -255 > parsed_disp:
                            sys.exit(f'ERROR: Out of range displacement on line {i+1} in inst {x}'
                                    +f'\n\t Displacement must be between -255 and 255, found: {parsed_disp}')
                    elif displacement[0] == '.': # if displacement is label
                        parsed_disp = labels[displacement] - address
                        if parsed_disp > 255 or -255 > parsed_disp:
                            sys.exit(f'ERROR: Out of range displacement on line {i+1} in inst {x}'
                                    +f'\n\t Displacement must be between -255 and 255, but label created displacement: {parsed_disp}')
                    else:
                        sys.exit(f'ERROR: Bad branch displacement on line {i+1} in inst {x}'
                                +f'\n\tCould not recognize {displacement} as a valid imm or label')

                    if parsed_disp >= 0: 
                        formatted_disp = f'{parsed_disp:02X}'
                    else:
                        twos_comp_disp = ((-1 * parsed_disp) ^ 255) + 1
                        formatted_disp = f'{twos_comp_disp:02X}'
                    wf.write(inst_codes['BRANCH'] + inst_codes[instr[1:]] + formatted_disp + '\n')
            elif instr in j_type_insts: # ----------------------------------------------------------------------------------------
                if len(parts) != 1:
                    sys.exit(f'ERROR: Wrong number of args on line {i+1} in instruction {x}\n\tExpected: 1, Found: {len(parts)}')
                else:
                    r_src = parts[0]
                    if r_src not in reg_codes:
                        sys.exit(f'ERROR: Unrecognized register on line {i+1} in instruction {x}')
                    else:
                        wf.write(inst_codes['SPECIAL_TYPE'] + inst_codes[instr[1:]] + inst_codes['JUMP'] + reg_codes[r_src] + '\n')
            elif instr in spec_type_insts:
                if len(parts) != 2:
                    sys.exit(f'ERROR: Wrong number of args on line {i+1} in instruction {x}\n\tExpected: 2, Found: {len(parts)}')
                r_first, r_sec = parts
                if r_first not in reg_codes or r_sec not in reg_codes:
                    sys.exit(f'ERROR: Unrecognized register on line {i+1} in instruction {x}')
                else:
                    wf.write(inst_codes['SPECIAL_TYPE'] + reg_codes[r_first] + inst_codes[instr] + reg_codes[r_sec] + '\n')
            elif instr in dist_1_type_insts:
                if len(parts) != 1 :
                    sys.exit(f'ERROR: Wrong number of args on line {i+1} in instruction {x}\n\tExpected: 1, Found: {len(parts)}')
                r_X = parts[0]
                if r_X not in reg_codes:
                    sys.exit(f'ERROR: Unrecognized register on line {i+1} in instruction {x}')
                wf.write(inst_codes['DISTANCE_1_TYPE'] + reg_codes[r_X] + inst_codes[instr] + '0\n')
            elif instr in dist_2_type_insts:
                if len(parts) != 2 :
                    sys.exit(f'ERROR: Wrong number of args on line {i+1} in instruction {x}\n\tExpected: 2, Found: {len(parts)}')
                r_X, r_Y = parts
                if r_X not in reg_codes or r_Y not in reg_codes:
                    sys.exit(f'ERROR: Unrecognized register on line {i+1} in instruction {x}')
                wf.write(inst_codes['DISTANCE_2_TYPE'] + reg_codes[r_X] + inst_codes[instr] + reg_codes[r_Y] +'\n')
            elif instr == 'NOP':
                # Hardcode NOP as OR %r0 %r0
                wf.write('0020\n')


            else: # ----------------------------------------------------------------------------------------
                sys.exit('Syntax Error: not a valid instruction: ' + line)

    if ram:
        while address < RAM_START-1:
            wf.write('0000\n')
            address += 1
        mode = f.readline()
        if mode == 'DECIMAL\n':
            for x in f:
                line = x.split('#')[0]
                if len(line) > 1:
                    parsed_line = int(line[:-1])
                    formatted_line = f'{parsed_line:04X}'
                    wf.write(f'{formatted_line}\n')
                    address += 1
        elif mode == 'IMMEDIATE\n':
            for x in f:
                line = x.split('#')[0]
                if len(line) > 1:
                    parsed_line = parseImm(line[:-1])
                    formatted_line = f'{parsed_line:04X}'
                    wf.write(f'{formatted_line}\n')
                    address += 1
        else:
            sys.exit(f"Unsupported RAM encoding mode: {mode[:-1]}")

    if not short_file:
        while address < FILE_LENGTH-1:
            wf.write('0000\n')
            address = address + 1
    wf.close()
    f.close()
    # print(f'End labels: {labels}')

def main():
    parser = argparse.ArgumentParser(description='This is the CR16 Assembler')
    parser.add_argument('file', nargs='?', help='The asm file to assemble')
    parser.add_argument('--dir', type=dir_path, help='A directory of asm files to assemble')
    parser.add_argument('--dest', type=dir_path, help='A directory to store resulting .dat files')
    parser.add_argument('-s', '--short', action='store_true', help='Do not write 0\'s to size of RAM')
    args = parser.parse_args()
    global short_file
    short_file = args.short

    global output_dir
    if args.dest == None:
        if args.dir == None:
            output_dir = './'
        else:
            output_dir = f'{args.dir}/'
    else:
        output_dir = f'{args.dest}/'

    if args.file != None:
        precompile(args.file)
        assemble(args.file)
    elif args.dir != None:
        for f in os.listdir(args.dir):
            precompile(f'{args.dir}/{f}')
            assemble(f'{args.dir}/{f}')
    else:
        sys.exit('argument error: must provide file or directory of files to assemble')
  
if __name__ == "__main__":
    main()
