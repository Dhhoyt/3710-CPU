from itertools import chain, repeat
from pprint import pprint

import argparse
import re

LABEL_PATTERN = re.compile(r"(\w+):")

INSTRUCTION_COUNT = 2**16 - 1

RTYPE_OPERATION_CODE = 0b0000
ADDI_OPERATION_CODE = 0b0101
MOVI_OPERATION_CODE = 0b1101
CMPI_OPERATION_CODE = 0b1011
BCOND_OPERATION_CODE = 0b1100
MEMORY_OPERATION_CODE = 0b0100
SCOND_OPERATION_CODE = 0b0100
JCOND_OPERATION_CODE = 0b0100

ADD_OPERATION_CODE_EXTRA = 0b0101
LOAD_OPERATION_CODE_EXTRA = 0b0000
STOR_OPERATION_CODE_EXTRA = 0b0100
SCOND_OPERATION_CODE_EXTRA = 0b1101
JCOND_OPERATION_CODE_EXTRA = 0b1100

OPERATION_CODE_SHIFT = 12
DESTINATION_SHIFT = 8
OPERATION_CODE_EXTRA_SHIFT = 4

CONDITIONS = {
    "EQ": 0b0000,
    "NE": 0b0001,
    "UC": 0b1110,
}

def encode(i, l, j):
    match i[0]:
        case "add":
            return rtype(i, ADD_OPERATION_CODE_EXTRA)
        case "addi":
            return itype(i, ADDI_OPERATION_CODE)
        case "movi":
            return itype(i, MOVI_OPERATION_CODE)
        case "cmpi":
            return itype(i, CMPI_OPERATION_CODE)
        case "bcond":
            d = int.from_bytes((l[i[1]] - j).to_bytes(1, signed=True), signed=False)
            return (BCOND_OPERATION_CODE << OPERATION_CODE_SHIFT) \
                | (CONDITIONS[i[2]] << DESTINATION_SHIFT) \
                | d
        case "stor":
            return (MEMORY_OPERATION_CODE << OPERATION_CODE_SHIFT) \
                | (int(i[2]) << DESTINATION_SHIFT) \
                | (STOR_OPERATION_CODE_EXTRA << OPERATION_CODE_EXTRA_SHIFT) \
                | int(i[1])
        case "load":
            return (MEMORY_OPERATION_CODE << OPERATION_CODE_SHIFT) \
                | (int(i[1]) << DESTINATION_SHIFT) \
                | (LOAD_OPERATION_CODE_EXTRA << OPERATION_CODE_EXTRA_SHIFT) \
                | int(i[2])
        case "scond":
            return (SCOND_OPERATION_CODE << OPERATION_CODE_SHIFT) \
                | (int(i[1]) << DESTINATION_SHIFT) \
                | (SCOND_OPERATION_CODE_EXTRA << OPERATION_CODE_EXTRA_SHIFT) \
                | CONDITIONS[i[2]]
        case "jcond":
            t = l[i[1]]
            return (JCOND_OPERATION_CODE << OPERATION_CODE_SHIFT) \
                | (CONDITIONS[i[2]] << DESTINATION_SHIFT) \
                | (JCOND_OPERATION_CODE_EXTRA << OPERATION_CODE_EXTRA_SHIFT) \
                | t

def rtype(instruction, operation_code_extra: int):
    return (RTYPE_OPERATION_CODE << OPERATION_CODE_SHIFT) \
        | (int(instruction[1]) << DESTINATION_SHIFT) \
        | (operation_code_extra << OPERATION_CODE_EXTRA_SHIFT) \
        | int(instruction[2])

def itype(instruction, operation_code: int):
    return (operation_code << OPERATION_CODE_SHIFT) \
        | (int(instruction[1]) << DESTINATION_SHIFT) \
        | int(instruction[2])

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
        elif l.isspace():
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
