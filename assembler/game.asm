


# loop 0 to 10 sum
# store at 0xFF

MOVI $10 %r1
MOVI $0  %r2
.loop
ADD %r1 %r2
SUBI $1 %r1
CMP %r0 %r1
BNE .loop
MOVI $255 %r3
STOR %r2 %r3

