# wolfenstyle rendering engine
# written by the Nibble Noshers

#RAM_START + 1
`define WALLS_ADDR $8193 
`define WALLS_COUNT $4
`define MAX_FIXED_VAL $32767

# do the racast with the hardcoded map of walls
.FUN_RAY_CAST # playerX:%r8, playerY:%r9, angle:%rB
MOV %rB %r0
MOV %rB %r1
COS %r0 # ray_dx = cos(angle)
SIN %r1 # ray_dy = sin(angle)
ADD %r8 %r0# move the direction vector to the player position
ADD %r9 %r1

LODP %r8 %r9 # load player position
LODR %r0 %r1 # load ray position

MOVI WALLS_ADDR %rC # put wall address in %rC
MOVI $0 %r3  # i = 0
MOVI MAX_FIXED_VAL %r4 # maxDistance  = (max value)
.RAY_CAST_LOOP
ADDI $4 %rC # add struct size to address
LODW %rC #compute the intersection TODO does this need a destination?
BINT .INTERSECTION_FOUND
JUC .INVALID_INTERSECTION

.INTERSECTION_FOUND
LODRD %r5 # get ray distance into %r5


ADDI $1 %r3 # count up
CMPI WALLS_COUNT %r3
BNE .RAY_CAST_LOOP
JUC %rA # return , might be wrong?

.INVALID_INTERSECTION


@ #preloaded ram values
DECIMAL
1
1
1
5
0
1
5
5
5
0
5
5
5
1
0
5
1
1
1
0

#etc

