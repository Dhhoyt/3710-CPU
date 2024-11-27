# wolfenstyle rendering engine
# written by the Nibble Noshers



# 100 / 320





















# FUNCTION main entry point
.FUN_MAIN
#init stuff
MOVI $0 %r2
LUI $0 %r2
MOVI $0 %r8
LUI $3 %r8
MOVI $0 %r9
LUI $3 %r9
MOVI $2 %r0
LUI $64 %r0
STOR %r2 %r0
MOVI $0 %r0
LUI $64 %r0
STOR %r8 %r0
MOVI $1 %r0
LUI $64 %r0
STOR %r9 %r0


.FRAME_LOOP
MOVI $0 %r1 # column count
MOVI $4 %r0
LUI $64 %r0
STOR %r1 %r0

# do the player motion before rendering
MOVI $2 %r0
LUI $64 %r0
LOAD %r2 %r0
#MOVW 65533 %r3
#LOAD %r4 %r3 # load joystick delta
MOVI $1 %r4 # temp set angle delta to the smallest possible value, a slow rotation hopefully
ADD %r4 %r2 # add to player angle
STOR %r2 %r0 # store new player angle

MOVI $0 %r0
LUI $64 %r0
LOAD %r8 %r0
MOVI $1 %r0
LUI $64 %r0
LOAD %r9 %r0
#MOVW 65534 %r0 # load joystick Y delta
#LOAD %r4 %r0
MOVI $0 %r4
LUI $0 %r4
MOV %r2 %r3 # duplicate angle
COS %r0 %r2
SIN %r0 %r3
MUL %r4 %r2 # multiply cos and sin by the Y delta
MUL %r4 %r3
ADD %r2 %r8 # add the cos to X
ADD %r3 %r9 # add the sin to Y
MOVI $0 %r0
LUI $64 %r0
STOR %r8 %r0
MOVI $1 %r0
LUI $64 %r0
STOR %r9 %r0

#set column angle to the left of screen
MOVI $0 %r0
LUI $50 %r0
SUB %r0 %r2 # start on left of FOV
MOVI $3 %r0
LUI $64 %r0
STOR %r2 %r0 # r2 is now the col angle


.COL_LOOP
MOVI $0 %r0
LUI $64 %r0
LOAD %r8 %r0
MOVI $1 %r0
LUI $64 %r0
LOAD %r9 %r0
MOVI $3 %r0
LUI $64 %r0
LOAD %rB %r0
MOVI $80 %r1
LUI $0 %r1
ADD %r1 %rB # add the step
STOR %rB %r0 # store the new angle for the next iteration

MOVI .FUN_RAY_CAST %rA
LUI .FUN_RAY_CAST %rA
JAL %rA %rA

MOVI $4 %r0
LUI $64 %r0
LOAD %r1 %r0 # get current column

MOVI $0 %r0
LUI $248 %r0
ADD %r1 %r0 # add the column to the address
STOR %r8 %r0

MOVI $0 %r0
LUI $250 %r0
ADD %r1 %r0 # add the column to the address
STOR %r9 %r0
#TODO ignore texture ID for now

MOVI $64 %r2
LUI $1 %r2
CMP %r2 %r1
BGT .COL_LOOP # repeat for every column
.END_COL_LOOP

#TODO set GPU flags and switch frame buffer
BUC .FRAME_LOOP

.END_MAIN


# FUNCTION do the raycast with the hardcoded map of walls
# return distance in %r8, texture UVX in %r9, texture ID in %rB
.FUN_RAY_CAST # playerX:%r8, playerY:%r9, angle:%rB
MOV %rB %r0
MOV %rB %r1
COS %r0 %r0 # ray_dx = cos(angle)
SIN %r0 %r1 # ray_dy = sin(angle)
ADD %r8 %r0# move the direction vector to the player position
ADD %r9 %r1

LODP %r8 %r9 # load player position
LODR %r0 %r1 # load ray position

MOVI $1 %rC
LUI $32 %rC
MOVI $0 %r3 # i = 0
MOVI $255 %r8
LUI $127 %r8
MOVI $0 %r9 # default texture UV
.RAY_CAST_LOOP
ADDI $5 %rC # add struct size to address
LODW %rC #compute the intersection
BINT .INTERSECTION_FOUND
BUC .CONTINUE_LOOP # invalid intersection

.INTERSECTION_FOUND
DIST %r5 # get ray distance into %r5
CMP %r5 %r8
BGT .CONTINUE_LOOP # do again if r5 > r8 #TODO make sure the > is the right way around
# here the wall is closer than the current max distance
MOV %r5 %r8 #new closest distance
TXUV %r9 # new texture UV

.CONTINUE_LOOP
ADDI $1 %r3 # count up
CMPI $4 %r3
BLT .RAY_CAST_LOOP #do again if theres more walls to check

JUC %rA # return , might be wrong?
.END_RAY_CAST


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

