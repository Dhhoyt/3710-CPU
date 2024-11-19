# wolfenstyle rendering engine
# written by the Nibble Noshers

#RAM_START + 1
`define WALLS_ADDR $8193 
`define WALLS_COUNT $4

# do the racast with the hardcoded map of walls
.FUN_RAY_CAST # playerX:%r8, playerY:%r9, angle:%rB
MOV %rB %r0
MOV %rB %r1
COS %r0 # ray_dx = cos(angle)
SIN %r1 # ray_dy = sin(angle)

LODP %r8 %r9 # load player position
LODR %r0 %r1 # load ray position

MOVI WALLS_ADDR %rC # put wall address in %rC
MOVI 0 %r3 # i = 0
.RAY_CAST_LOOP
ADDI $4 %rC # add struct size to address
LODW %rC #compute the intersection TODO does this need a destination?
ADDI $1 %r3 # count up
CMPI WALLS_COUNT %r3
BNE .RAY_CAST_LOOP
JUMP %rA # return , might be wrong?




@ #preloaded ram values
DECIMAL
1
1
1
5
1
5
5
5
5
5
5
1
5
1
1
1

#etc

