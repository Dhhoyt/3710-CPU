xor  $0, $0             ; set $0 to 0 (The outer iterator)
lodp $8, $9             ; load the players position into the relevent math modules

OUTER_LOOP:

SOMETHING HERE          ; TODO: Load the ray position using the lodr command

xor  $1, $1             ; Set $1 to 0 (It will hold the current address of the pointer to the wall)
xor  $2, $2             
add  $2, 0xffff         ; Set $2 to be the max value (It will keep track of the lowest distance)
add  $1, WALL_ARRAY_ADR ; Set $1 to the start of the wall array

INNER_LOOP:

lodw $1                 ; Load the walls data by feeding it the address
bint INTERSECTION_FOUND ; break if intersection found
j CONTINUE_INNER        ; jmp if no intersect

INTERSECTION_FOUND:
dist $3                 ; Store the distance to the intersection in 3

cmp  $3, $2             
jgt  CONTINUE_INNER     ; Jump to the end if the new distance is greater than what we have right now

uvx  $4                 ; Store the x uv coord in $4
tid  $5                 ; Store the texture id in $5

SOMETHING HERE          ; TODO: Store the values in the memmapped location

CONTINUE_INNER:         ; If we want to continue the inner loop

add  $1, 5              ; Add 5 (the length of a wall struct) to the pointer
SOMETHING HERE          ; TODO: Check if we have hit the end of the walls array and jump to END_INNER_LOOP if we have
j    INNER_LOOP         ; Go to OUTER_LOOP if were not done

END_INNER_LOOP:

add  $0, 1              ; Increment $0
cmp  $0, 320            ; Check if weve hit the number of columns
bz   END_OUTER_LOOP     ; Break if zero to end
j    OUTER_LOOP         ; Go to OUTER_LOOP if were not done

END_OUTER_LOOP:
