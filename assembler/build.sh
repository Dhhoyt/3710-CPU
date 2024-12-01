#! /bin/bash


python assembler.py game.asm
python generateMif.py game.dat

cp mifText.mif ../quartusProject/db/GPU.ram0_memory_e411fb78.hdl.mif

cd ../quartusProject
./newHex.sh



