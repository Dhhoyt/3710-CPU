# wolfenstyle rendering engine
# written by the Nibble Noshers


#TODO calculate these out and also fixed point









# FUNCTION main entry point
.FUN_MAIN
#TODO load these from memory
MOVI $0 %r4 # player angle


SUBI $50 %r4 # start on left of FOV
MOVI $3 %r8 # player X, Y
MOVI $3 %r9
MOV %r4 %rB #player angle argument







# FUNCTION do the raycast with the hardcoded map of walls
# return distance in %r8, texture UVX in %r9, texture ID in %rB
.FUN_RAY_CAST # playerX:%r8, playerY:%r9, angle:%rB
MOV %rB %r0
MOV %rB %r1
COS %r0 # ray_dx = cos(angle)
SIN %r1 # ray_dy = sin(angle)
ADD %r8 %r0# move the direction vector to the player position
ADD %r9 %r1

LODP %r8 %r9 # load player position
LODR %r0 %r1 # load ray position

MOVI $8193 %rC # put wall address in %rC
MOVI $0 %r3 # i = 0
MOVI $32767 %r8 # maxDistance = (max value)
MOVI $0 %r9 # default texture location
MOVI $0 %rB # default texture ID
.RAY_CAST_LOOP
ADDI $5 %rC # add struct size to address
LODW %rC #compute the intersection
BINT .INTERSECTION_FOUND
JUC .CONTINUE_LOOP # invalid intersection

.INTERSECTION_FOUND
LODRD %r5 # get ray distance into %r5
CMP %r5 %r8
JGT .CONTINUE_LOOP # do again if r5 > r8 #TODO make sure the > is the right way around
# here the wall is closer than the current max distance
MOV %r5 %r8 #new closest distance
LODUV %r9 # new texture location
MOV %rC %r2
ADDI $4 %r2 # get texture address
LOAD %r2 %rB # new texture ID

.CONTINUE_LOOP
ADDI $1 %r3 # count up
CMPI $4 %r3
BLT .RAY_CAST_LOOP #do again if theres more walls to check

JUC %rA # return , might be wrong?



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

