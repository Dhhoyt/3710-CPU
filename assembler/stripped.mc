MOVI $64 %r0 
LUI $1 %r0 
MOVI $0 %r1 
LUI $252 %r1 
MOVI $0 %r2 
LUI $254 %r2 
MOVI $0 %r3 
LUI $0 %r3 
MOVI $0 %r4 
LUI $2 %r4 
STOR %r4 %r1 
STOR %r3 %r2 
ADDI $1 %r1 
ADDI $1 %r2 
ADDI $1 %r3 
CMP %r3 %r0 
BEQ .LOOP_END 
BUC .LOOP 
MOVI $255 %r0 
LUI $255 %r0 
MOVI $2 %r1 
LUI $0 %r1 
STOR %r1 %r0 
