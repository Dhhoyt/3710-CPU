# wolfenstyle rendering engine
# written by the Nibble Noshers

`define COL_COUNT $320
`define FOV_HALF $$50
# 100 / 320
`define ANGLE_STEP $$0.3125 
`define DIST_BUFFER_1_ADDR $63488
`define DIST_BUFFER_2_ADDR $64512
`define UV_BUFFER_1_ADDR $64000
`define UV_BUFFER_2_ADDR $65024

`define PLAYER_X_ADDR $16384
`define PLAYER_Y_ADDR $16385
`define PLAYER_ANGLE_ADDR $16386
`define COL_ANGLE_ADDR $16387
`define COL_ADDR $16388



`define WALLS_ADDR $8193 #RAM_START + 1
`define WALLS_COUNT $4
`define MAX_FIXED_VAL $32767



# FUNCTION main entry point
.FUN_MAIN
	#init stuff
	MOVW $$0 %r2 # player angle
	MOVW $$3 %r8 # player X
	MOVW $$3 %r9 # player Y
	MOVW `PLAYER_ANGLE_ADDR %r0
	STOR %r2 %r0
	MOVW `PLAYER_X_ADDR %r0
	STOR %r8 %r0
	MOVW `PLAYER_Y_ADDR %r0
	STOR %r9 %r0

	
	.FRAME_LOOP
		MOVI $0 %r1 # column count
		MOVW `COL_ADDR %r0
		STOR %r1 %r0
		MOVW `PLAYER_ANGLE_ADDR %r0
		LOAD %r2 %r0
		MOVW `FOV_HALF %r0
		SUB  %r0 %r2 # start on left of FOV
		MOVW `COL_ANGLE_ADDR %r0
		STOR %r2 %r0 # r2 is now the col angle

		
		.COL_LOOP
			MOVW `PLAYER_X_ADDR %r0 # load player x and y
			LOAD %r8 %r0 
			MOVW `PLAYER_Y_ADDR %r0
			LOAD %r9 %r0 
			MOVW `COL_ANGLE_ADDR %r0 # load the angle
			LOAD %rB %r0 
			MOVW `ANGLE_STEP %r1
			ADD %r1 %rB # add the step
			STOR %rB %r0 # store the new angle for the next iteration

			#CALL .FUN_RAY_CAST

			MOVW `COL_ADDR %r0
			LOAD %r1 %r0 # get current column

			MOVW `DIST_BUFFER_1_ADDR %r0 # save the distance
			ADD %r1 %r0 # add the column to the address
			STOR %r8 %r0

			MOVW `UV_BUFFER_1_ADDR %r0 # save the UVX
			ADD %r1 %r0 # add the column to the address
			STOR %r9 %r0
			#TODO ignore texture ID for now

			MOVW `COL_COUNT %r2
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
	COS %r0 # ray_dx = cos(angle)
	SIN %r1 # ray_dy = sin(angle)
	ADD %r8 %r0# move the direction vector to the player position
	ADD %r9 %r1

	LODP %r8 %r9 # load player position
	LODR %r0 %r1 # load ray position

	MOVI `WALLS_ADDR %rC # put wall address in %rC
	MOVI $0 %r3  # i = 0
	MOVI `MAX_FIXED_VAL %r8 # maxDistance  = (max value)
	MOVI $0 %r9 # default texture location
	MOVI $0 %rB # default texture ID
	.RAY_CAST_LOOP
	ADDI $5 %rC # add struct size to address
	LODW %rC #compute the intersection 
	BINT .INTERSECTION_FOUND
	BUC .CONTINUE_LOOP # invalid intersection

	.INTERSECTION_FOUND
	LODRD %r5 # get ray distance into %r5
	CMP %r5 %r8
	BGT .CONTINUE_LOOP # do again if r5 > r8  #TODO make sure the > is the right way around
	# here the wall is closer than the current max distance
	MOV %r5 %r8 #new closest distance
	LODUV %r9 # new texture location
	MOV %rC %r2
	ADDI $4 %r2 # get texture address
	LOAD %r2 %rB # new texture ID

	.CONTINUE_LOOP
	ADDI $1 %r3 # count up
	CMPI `WALLS_COUNT %r3
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

