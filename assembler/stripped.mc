MOVI $10 %r1 
MOVI $0 %r2 
ADD %r1 %r2 
SUBI $1 %r1 
CMP %r0 %r1 
BNE .loop 
MOVI $255 %r3 
STOR %r2 %r3 
