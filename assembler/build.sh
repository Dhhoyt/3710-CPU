#! /bin/bash


python assembler.py 3test.asm
python generateMif.py 3test.dat

cp mifText.mif ../quartusProject/db/GPU.ram0_memory_e411fb78.hdl.mif

