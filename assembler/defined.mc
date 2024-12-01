# wolfenstyle rendering engine
# written by the Nibble Noshers



# FOV / 320






# these are now all preserved registers





#%r6 is buffer ID











# FUNCTION main entry point
.FUN_MAIN
#init stuff
MOVI $0 %r4
LUI $0 %r4
MOVI $0 %r8
LUI $3 %r8
MOVI $0 %r9
LUI $3 %r9
MOVI $1 %r6 # Frame buffer ID

# MOVW $1 %rD
# MOVW $1 %rF


.FRAME_LOOP
# do the player motion before rendering
#MOVW $65533 %r0
#LOAD %r1 %r0 # load joystick delta
# MOVI $1 %r1 # temp set angle delta to the smallest possible value, a slow rotation hopefully
# ADD %r1 %r4 # add to player angle

#MOVW $65534 %r0 # load joystick Y delta
#LOAD %r3 %r0
# MOVW $$0 %r3 # temp add nothing to the player position
# MOV %r4 %r1 # duplicate player angle
# MOV %r4 %r2 # duplicate player angle
# COS %r1
# SIN %r2
# MUL %r3 %r1 # multiply cos and sin by the Y delta
# MUL %r3 %r2
# ADD %r1 %r8 # add the cos to X
# ADD %r2 %r9 # add the sin to Y

# set column angle to the left of screen
MOVI $64 %r1
LUI $1 %r1
MOV %r4 %rB # reset column angle to be player angle
SUB %r1 %rB # start on left of FOV
MOVI $0 %r5 # column count = 0

# MOVW $$2 % store singer distance

.COL_LOOP
MOVI .FUN_RAY_CAST %rA
LUI .FUN_RAY_CAST %rA
JAL %rA %rA

.BUFFER_0
MOVI $0 %r0
LUI $248 %r0
ADD %r5 %r0 # add the column to the address
STOR %rC %r0

MOVI $0 %r0
LUI $250 %r0
ADD %r5 %r0 # add the column to the address
ADD %rF %rD
STOR %rD %r0

.CONTINUE_COL_LOOP
MOVI $1 %r1
LUI $0 %r1
ADD %r1 %rB # add the angle step

ADDI $1 %r5 # next column

MOVI $64 %r2
LUI $1 %r2
CMP %r5 %r2
BGT .COL_LOOP # repeat for every column
.END_COL_LOOP

# MOVW $65535 %r0 #get flag address
# MOVW $2 $r1 # flag = 10
# STOR %r1 %r0 # set the flag


.END
BUC .END

.END_MAIN


# FUNCTION do the raycast with the hardcoded map of walls
# return distance in %rC, texture UVX in %rD
# input argument registers are preserved
.FUN_RAY_CAST # playerX:%r8, playerY:%r9, angle:%rB
MOV %rB %r0
MOV %rB %r1
COS %r0 %r0 # ray_dx = cos(angle)
SIN %r0 %r1 # ray_dy = sin(angle)
ADD %r8 %r0# move the direction vector to the player position
ADD %r9 %r1

LODP %r8 %r9 # load player position
LODR %r0 %r1 # load ray position

MOVI $1 %r0
LUI $32 %r0
MOVI $0 %r1 # i = r1 = 0
MOVI $255 %rC
LUI $127 %rC
MOVI $0 %rD # default texture UV
.RAY_CAST_LOOP
LODW %r0 #compute the intersection
BINT .INTERSECTION_FOUND
BUC .CONTINUE_LOOP # invalid intersection

.INTERSECTION_FOUND
DIST %r2 # get ray distance into %r2
CMP %rC %r2
# BGT .CONTINUE_LOOP # do again if rC < r2
# here the wall is closer than the current max distance
MOV %r2 %rC #new closest distance
TXUV %rD # new texture UV

.CONTINUE_LOOP
ADDI $5 %r0 # add struct size to wall pointer
ADDI $1 %r1 # count up
CMPI $1 %r1
BLT .RAY_CAST_LOOP #do again if theres more walls to check

JUC %rA # return
.END_RAY_CAST


@ #preloaded ram values
IMMEDIATE
$$1
$$1
$$1
$$5
$0
$$1
$$5
$$5
$$5
$0
$$5
$$5
$$5
$$1
$0
$$5
$$1
$$1
$$1
$0

#etc

