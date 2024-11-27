from itertools import chain, repeat
from pprint import pprint

import argparse
import re

LABEL_PATTERN = re.compile(r"(\w+):")

INSTRUCTION_COUNT = 2**16

OPERATION_RTYPE = 0b0000
OPERATION_ADDI = 0b0101
OPERATION_MOVI = 0b1101
OPERATION_CMPI = 0b1011
OPERATION_BCOND = 0b1100
OPERATION_MEMORY = 0b0100
OPERATION_SCOND = 0b0100
OPERATION_JCOND = 0b0100
OPERATION_JAL = 0b0100

EXTRA_ADD = 0b0101
EXTRA_COS = 0b1110
EXTRA_SIN = 0b1111
EXTRA_LOAD = 0b0000
EXTRA_STOR = 0b0100
EXTRA_SCOND = 0b1101
EXTRA_JCOND = 0b1100
EXTRA_JAL = 0b1000
EXTRA_MOV = 0b1101

OPERATION_SHIFT = 12
DESTINATION_SHIFT = 8
EXTRA_SHIFT = 4

CONDITIONS = {
    "EQ": 0b0000,
    "NE": 0b0001,
    "UC": 0b1110,
}

def encode(i, l, j):
    match i[0]:
        case "add":
            return rtype(i, EXTRA_ADD)
        case "sin":
            return rtype(i, EXTRA_SIN)
        case "cos":
            return rtype(i, EXTRA_COS)
        case "addi":
            return itype(i, OPERATION_ADDI, l)
        case "movi":
            return itype(i, OPERATION_MOVI, l)
        case "cmpi":
            return itype(i, OPERATION_CMPI, l)
        case "mov":
            return rtype(i, EXTRA_MOV)
        case "stor":
            # stor address source
            # memory[registers[address]] <- registers[source]
            return (OPERATION_MEMORY << OPERATION_SHIFT) \
                | (int(i[2]) << DESTINATION_SHIFT) \
                | (EXTRA_STOR << EXTRA_SHIFT) \
                | int(i[1])
        case "load":
            # load destination address
            # registers[destination] <- memory[registers[address]]
            return (OPERATION_MEMORY << OPERATION_SHIFT) \
                | (int(i[1]) << DESTINATION_SHIFT) \
                | (EXTRA_LOAD << EXTRA_SHIFT) \
                | int(i[2])
        case "bcond":
            d = int.from_bytes((l[i[1]] - j).to_bytes(1, signed=True), signed=False)
            return (OPERATION_BCOND << OPERATION_SHIFT) \
                | (CONDITIONS[i[2]] << DESTINATION_SHIFT) \
                | d
        case "scond":
            return (OPERATION_SCOND << OPERATION_SHIFT) \
                | (int(i[1]) << DESTINATION_SHIFT) \
                | (EXTRA_SCOND << EXTRA_SHIFT) \
                | CONDITIONS[i[2]]
        case "jcond":
            return (OPERATION_JCOND << OPERATION_SHIFT) \
                | (CONDITIONS[i[2]] << DESTINATION_SHIFT) \
                | (EXTRA_JCOND << EXTRA_SHIFT) \
                | int(i[1])
        case "jal":
            return (OPERATION_JAL << OPERATION_SHIFT) \
                | (int(i[1]) << DESTINATION_SHIFT) \
                | (EXTRA_JAL << EXTRA_SHIFT) \
                | int(i[2])
        case _:
            print(f"Unimplemented: {i}")
            raise ValueError()

def rtype(instruction, operation_code_extra: int):
    return (OPERATION_RTYPE << OPERATION_SHIFT) \
        | (int(instruction[1]) << DESTINATION_SHIFT) \
        | (operation_code_extra << EXTRA_SHIFT) \
        | (int(instruction[2]) if len(instruction) > 2 else 0)

def itype(instruction, operation_code: int, labels):
    try:
        j = int(instruction[2])
        immediate = int.from_bytes(j.to_bytes(1, signed=True), signed=False) if j <= 127 else j
    except:
        immediate = labels[instruction[2]]
    return (operation_code << OPERATION_SHIFT) \
        | (int(instruction[1]) << DESTINATION_SHIFT) \
        | immediate

def parse(s: str):
    lines = s.splitlines()
    instructions = list()
    labels = dict()

    for l in lines:
        if m := LABEL_PATTERN.match(l):
            n = m.groups()[0]
            # We currently have parsed `len(instructions)`
            # instructions, this labels the next one, which will be at
            # the `len(instructions)`-th index
            labels[n] = len(instructions)
        elif not l or l.isspace() or l.startswith("#"):
            continue
        else:
            operator, *operands = l.split()
            instructions.append((operator, *(o for o in operands)))

    return (instructions, labels)

def main():
    parser = argparse.ArgumentParser(prog="mips_assembler")
    parser.add_argument("output", type=argparse.FileType('w'))
    parser.add_argument("input", type=argparse.FileType('r'))
    parser.add_argument("--debug", action="store_true")
    arguments = parser.parse_args()

    instructions, labels = parse(arguments.input.read())

    if arguments.debug:
        pprint(instructions)
        pprint(labels)
        # pprint(encode(instructions, labels))

    if len(instructions) > INSTRUCTION_COUNT:
        print("error: Too many instructions to fit into memory")
        exit(1)

    lines = list(chain(
        # TODO: Is it right?
        (f"{encode(i, labels, j):04x}\n" for j, i in enumerate(instructions)),
        repeat("0000\n", (INSTRUCTION_COUNT - len(instructions)))
    ))
    assert(len(lines) == INSTRUCTION_COUNT)
    arguments.output.writelines(lines)

if __name__ == "__main__":
    main()
