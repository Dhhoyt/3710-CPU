# wolfenstyle rendering engine
# written by the Nibble Noshers



# FOV / 320






# these are now all preserved registers





#%r6 is buffer ID









# FUNCTION main entry point
.FUN_MAIN
#init stuff
MOVI $0 %r4
LUI $3 %r4
MOVI $0 %r8
LUI $4 %r8
MOVI $0 %r9
LUI $2 %r9
MOVI $1 %r6 # Frame buffer ID

.FRAME_LOOP
# do the player motion before rendering
MOVI $253 %r0
LUI $255 %r0
LOAD %r1 %r0 # load joystick delta
SUBI $8 %r1 # 8 - %r1 , invert axis
ADD %r1 %r4 # add to player angle

MOVI $254 %r0
LUI $255 %r0
LOAD %r3 %r0
ADDI $-8 %r3
MOV %r4 %r1 # duplicate player angle
MOV %r4 %r2 # duplicate player angle
COS %r0 %r1
SIN %r0 %r2
MUL %r3 %r1 # multiply cos and sin by the Y delta
MUL %r3 %r2

ADD %r8 %r1 # move direction vector to player
ADD %r9 %r2

# Set up collision check by loading player position and movement direction
LODP %r8 %r9 # Load current player position into raycast hardware
LODR %r1 %r2 # Load movement vector into raycast hardware

# Begin collision check loop for all walls
MOVI $0 %r0
LUI $32 %r0
MOVI $0 %r7 # Initialize wall counter to 0

.CHECK_WALLS
LODW %r0 # Load current wall data into raycast hardware
BINT .COLLISION_INTERSECTION_FOUND
BUC .COLLISION_NO_INTERSECTION_FOUND

.COLLISION_INTERSECTION_FOUND
DIST %rE # Get distance to wall in current movement direction
MOVI $51 %rF
LUI $0 %rF
CMP %rF %rE # Check if closer than ~0.05 units
BLT .NO_MOVE # If too close, skip movement update

.COLLISION_NO_INTERSECTION_FOUND
ADDI $5 %r0 # Move to next wall (walls are 5 words apart)
ADDI $1 %r7 # Increment wall counter
CMPI $52 %r7 # Check if we've checked all walls
BLT .CHECK_WALLS # If more walls to check, continue loop

# No collisions detected, safe to move
MOV %r1 %r8 # Update X position with movement vector
MOV %r2 %r9 # Update Y position with movement vector
# BUC .CONTINUE_GAME # Continue to rendering

.NO_MOVE # Collision detected - don't update position
# Position stays the same, fall through to continue
.CONTINUE_GAME

#set column angle to the left of screen
MOVI $64 %r1
LUI $1 %r1
MOV %r4 %rB # reset column angle to be player angle
SUB %r1 %rB # start on left of FOV
MOVI $0 %r5 # column count = 0

.COL_LOOP

# FUNCTION do the raycast with the hardcoded map of walls
# return distance in %rC, texture UVX in %rD
# input argument registers are preserved
.FUN_RAY_CAST # playerX:%r8, playerY:%r9, angle:%rB
MOV %rB %r0
MOV %rB %r1
SIN %r0 %r0 # ray_dx = sin(angle)
COS %r0 %r1 # ray_dy = cos(angle)
ADD %r8 %r0# move the direction vector to the player position
ADD %r9 %r1

LODP %r8 %r9 # load player position
LODR %r0 %r1 # load ray position

MOVI $0 %r0
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
BGT .CONTINUE_LOOP # do again if rC < r2
# here the wall is closer than the current max distance
MOV %r2 %rC #new closest distance
TXUV %rD # new texture UV

.CONTINUE_LOOP
ADDI $5 %r0 # add struct size to wall pointer
ADDI $1 %r1 # count up
CMPI $52 %r1
BLT .RAY_CAST_LOOP #do again if theres more walls to check
.END_RAY_CAST

CMPI $0 %r6 # pick the right buffer
BNE .BUFFER_1

.BUFFER_0
MOVI $0 %r0
LUI $248 %r0
ADD %r5 %r0 # add the column to the address
STOR %rC %r0

MOVI $0 %r0
LUI $250 %r0
ADD %r5 %r0 # add the column to the address
STOR %rD %r0
BUC .CONTINUE_COL_LOOP

.BUFFER_1
MOVI $0 %r0
LUI $252 %r0
ADD %r5 %r0 # add the column to the address
STOR %rC %r0

MOVI $0 %r0
LUI $254 %r0
ADD %r5 %r0 # add the column to the address
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

MOVI $255 %r0
LUI $255 %r0
.WAIT_FOR_RENDERING # wait for rendering the previous frame to finish
LOAD %r1 %r0 # load the flag register
ANDI $1 %r1 # mask out the lowest bit
CMPI $0 %r1 # check if lowest bit is set
BEQ .WAIT_FOR_RENDERING # repeat until it is set

# write to the GPU flag
# write the buffer ID that we just filled
MOV %r6 %r1 # copy frame buffer ID
LSHI $1 %r1 # shift to the second bit
STOR %r1 %r0 # set the flag

# now switch which one we write to
XORI $1 %r6 # switch frame buffer to write to

BUC .FRAME_LOOP

.END_MAIN

@ #preloaded ram values
IMMEDIATE
#outer walls, 20 walls
$$1
$$1
$$6
$$1
$0
$$6
$$1
$$7
$$0
$1
$$7
$$0
$$8
$$0
$2
$$8
$$0
$$9
$$1
$1
$$9
$$1
$$14
$$1
$0
$$1
$$14
$$6
$$14
$0
$$6
$$14
$$7
$$15
$1
$$7
$$15
$$8
$$15
$2
$$8
$$15
$$9
$$14
$1
$$9
$$14
$$14
$$14
$0
$$1
$$1
$$1
$$6
$0
$$1
$$6
$$0
$$7
$1
$$0
$$7
$$0
$$8
$2
$$0
$$8
$$1
$$9
$1
$$1
$$9
$$1
$$14
$0
$$14
$$1
$$14
$$6
$0
$$14
$$6
$$15
$$7
$1
$$15
$$7
$$15
$$8
$2
$$15
$$8
$$14
$$9
$1
$$14
$$9
$$14
$$14
$0
# labyrinth, 16 walls
$$4
$$4
$$9
$$4
$0
$$9
$$4
$$9
$$9
$1
$$9
$$9
$$8
$$9
$3
$$8
$$9
$$8
$$5
$1
$$8
$$5
$$5
$$5
$1
$$5
$$5
$$5
$$11
$1
$$5
$$11
$$4
$$11
$0
$$4
$$11
$$4
$$4
$0
$$11
$$11
$$6
$$11
$0
$$6
$$11
$$6
$$6
$1
$$6
$$6
$$7
$$6
$3
$$7
$$6
$$7
$$10
$1
$$7
$$10
$$10
$$10
$1
$$10
$$10
$$10
$$4
$1
$$10
$$4
$$11
$$4
$0
$$11
$$4
$$11
$$11
$0
# columns, 16 walls
$$2
$$2
$$2
$$3
$1
$$2
$$3
$$3
$$3
$1
$$3
$$3
$$3
$$2
$1
$$3
$$2
$$2
$$2
$1
$$2
$$12
$$2
$$13
$1
$$2
$$13
$$3
$$13
$1
$$3
$$13
$$3
$$12
$1
$$3
$$12
$$2
$$12
$1
$$12
$$2
$$12
$$3
$1
$$12
$$3
$$13
$$3
$1
$$13
$$3
$$13
$$2
$1
$$13
$$2
$$12
$$2
$1
$$12
$$12
$$12
$$13
$1
$$12
$$13
$$13
$$13
$1
$$13
$$13
$$13
$$12
$1
$$13
$$12
$$12
$$12
$1
