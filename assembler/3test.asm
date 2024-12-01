# wolfenstyle rendering engine
# written by the Nibble Noshers

`define COL_COUNT $320
`define FOV_HALF $$1.25
# FOV / 320
`define ANGLE_STEP $1
`define DIST_BUFFER_0_ADDR $63488
`define DIST_BUFFER_1_ADDR $64512
`define UV_BUFFER_0_ADDR $64000
`define UV_BUFFER_1_ADDR $65024

# these are now all preserved registers
`define PLAYER_X_ADDR $16384 # %r8
`define PLAYER_Y_ADDR $16385 # %r9
`define PLAYER_ANGLE_ADDR $16386 # %r4
`define COL_ANGLE_ADDR $16387 # %rB
`define COL_ADDR $16388 #r5
#%r6 is buffer ID

`define JOYSTICK_X_ADDR $65533
`define JOYSTICK_Y_ADDR $65534
`define GPU_FLAG_ADDR $65535

`define WALLS_ADDR $8192 #RAM_START + 1
`define WALLS_COUNT $2
`define MAX_FIXED_VAL $32767



# FUNCTION main entry point
.FUN_MAIN
	#init stuff
	MOVW $$-1 %r4 # player angle 
	MOVW $$3 %r8 # player X
	MOVW $$3 %r9 # player Y
	MOVI $1  %r6 # Frame buffer ID

	# MOVW $1 %rD
	MOVI $1 %rE

	
	.FRAME_LOOP
		# do the player motion before rendering 
		#MOVW `JOYSTICK_X_ADDR %r0
		#LOAD %r1 %r0 # load joystick delta
		# MOVI $1 %r1 # temp set angle delta to the smallest possible value, a slow rotation hopefully
		# ADD %r1 %r4 # add to player angle

		#MOVW `JOYSTICK_Y_ADDR %r0 # load joystick Y delta
		#LOAD %r3 %r0
		# MOVW $$0 %r3 # temp add nothing to the player position
		# MOV %r4 %r1 # duplicate player angle
		# MOV %r4 %r2 # duplicate player angle
		# COS %r1
		# SIN %r2
		# MUL %r3 %r1 # multiply cos and sin by the Y delta
		# MUL %r3 %r2
		# ADD %r1 %r8 # add the cos to X
		# ADD %r2 %r9	# add the sin to Y
		
		# set column angle to the left of screen
		MOVW `FOV_HALF %r1
		MOV %r4 %rB # reset column angle to be player angle
		SUB  %r1 %rB # start on left of FOV
		MOVI $0 %r5 # column count = 0
		
		# MOVW $$0 %rC #store single distance 

		.COL_LOOP
			# FUNCTION do the raycast with the hardcoded map of walls
			# return distance in %rC, texture UVX in %rD
			# input argument registers are preserved
			.FUN_RAY_CAST # playerX:%r8, playerY:%r9, angle:%rB
				MOV %rB %r0
				MOV %rB %r1
				COS %r0 # ray_dx = cos(angle)
				SIN %r1 # ray_dy = sin(angle)
				ADD %r8 %r0# move the direction vector to the player position
				ADD %r9 %r1

				LODP %r8 %r9 # load player position
				LODR %r0 %r1 # load ray position

				MOVW `WALLS_ADDR %r0 # put first wall address in %r0
				MOVI $0 %r1  # i = r1 = 0
				MOVW `MAX_FIXED_VAL %rC # maxDistance  = (max value)
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
				CMPI `WALLS_COUNT %r1
				BLT .RAY_CAST_LOOP #do again if theres more walls to check
			.END_RAY_CAST

			.BUFFER_0
			MOVW `DIST_BUFFER_0_ADDR %r0 # save the distance
			ADD %r5 %r0 # add the column to the address
			STOR %rC %r0

			MOVW `UV_BUFFER_0_ADDR %r0 # save the UVX
			ADD %r5 %r0 # add the column to the address
			STOR %rD %r0

			.CONTINUE_COL_LOOP
			MOVW `ANGLE_STEP %r1
			ADD %r1 %rB # add the angle step

			ADDI $1 %r5 # next column

			MOVW `COL_COUNT %r2 // number of columns
			CMP %r5 %r2
			BGT .COL_LOOP # repeat for every column
		.END_COL_LOOP

		# MOVW `GPU_FLAG_ADDR %r0 #get flag address
		# MOVW $2 $r1 # flag = 10
		# STOR %r1 %r0 # set the flag


		.END
		BUC .END

.END_MAIN





@ #preloaded ram values
IMMEDIATE
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

