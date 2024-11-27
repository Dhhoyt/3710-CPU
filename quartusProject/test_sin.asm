movi 3 loop1
movi 4 255
movi 1 0
loop1:
addi 1 1
mov 5 1
cos 5
stor 4 5
movi 2 1
busy_loop:
addi 2 1
cmpi 2 0
bcond loop1 EQ
bcond busy_loop UC
