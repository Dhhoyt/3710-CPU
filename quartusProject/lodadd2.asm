movi 1 0       # r1 = 0 (loop counter)
movi 2 0       # r2 = 0 (F[n-1], initially 0)
movi 3 1       # r3 = 1 (F[n], initially 1)
movi 4 64      # r4 = 64 (base memory address for Fibonacci storage)
movi 6 loop1   # r6 = address of loop1 (jump destination)

loop1:
stor 4 2       # Store r2 (F[n-1]) in memory at address r4
add 2 3        # r2 = r2 + r3 (F[n-1] + F[n], update F[n-1])
mov 5 3        # r5 = r3 (temporary: save old F[n])
mov 3 2        # r3 = r2 (update F[n] = new Fibonacci value)
mov 2 5        # r2 = r5 (restore F[n-1] = previous Fibonacci value)
addi 4 1       # Increment memory address r4 by 1
addi 1 1       # Increment loop counter r1
cmpi 1 24       # Compare r1 with 24 (stop after 24 iterations)
jcond 6 NE     # Jump to loop1 if r1 != 24

movi 6 loop2   # r6 = address of loop2 (jump destination)
movi 5 255     # r5 = address of memmaped IO
loop2:
load 1 5       # r1 = Data inputted by switches
addi 1 64      # r1 = the index of the array + the offset of the array
load 2 1       # load the value in the array at index
stor 5 2       # display the value of the 
jcond 6 UC     # Repeat the loop