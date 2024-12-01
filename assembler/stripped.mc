MOVI $0 %r4 
LUI $0 %r4 
MOVI $0 %r8 
LUI $3 %r8 
MOVI $0 %r9 
LUI $3 %r9 
MOVI $1 %r6 
MOVI $1 %r1 
ADD %r1 %r4 
MOVI $64 %r1 
LUI $1 %r1 
MOV %r4 %rB 
SUB %r1 %rB 
MOVI $0 %r5 
MOV %rB %r0 
MOV %rB %r1 
COS %r0 %r0 
SIN %r0 %r1 
ADD %r8 %r0 
ADD %r9 %r1 
LODP %r8 %r9 
LODR %r0 %r1 
MOVI $0 %r0 
LUI $32 %r0 
MOVI $0 %r1 
MOVI $255 %rC 
LUI $127 %rC 
MOVI $0 %rD 
LODW %r0 
BINT .INTERSECTION_FOUND 
BUC .CONTINUE_LOOP 
DIST %r2 
CMP %rC %r2 
BGT .CONTINUE_LOOP 
MOV %r2 %rC 
TXUV %rD 
ADDI $5 %r0 
ADDI $1 %r1 
CMPI $4 %r1 
BLT .RAY_CAST_LOOP 
CMPI $0 %r6 
BNE .BUFFER_1 
MOVI $0 %r0 
LUI $248 %r0 
ADD %r5 %r0 
STOR %rC %r0 
MOVI $0 %r0 
LUI $250 %r0 
ADD %r5 %r0 
STOR %rD %r0 
BUC .CONTINUE_COL_LOOP 
MOVI $0 %r0 
LUI $252 %r0 
ADD %r5 %r0 
STOR %rC %r0 
MOVI $0 %r0 
LUI $254 %r0 
ADD %r5 %r0 
STOR %rD %r0 
MOVI $1 %r1 
LUI $0 %r1 
ADD %r1 %rB 
ADDI $1 %r5 
MOVI $64 %r2 
LUI $1 %r2 
CMP %r5 %r2 
BGT .COL_LOOP 
MOVI $255 %r0 
LUI $255 %r0 
LOAD %r1 %r0 
ANDI $1 %r1 
CMPI $0 %r1 
BEQ .WAIT_FOR_RENDERING 
MOV %r6 %r1 
LSHI $1 %r1 
STOR %r1 %r0 
XORI $1 %r6 
BUC .FRAME_LOOP 
