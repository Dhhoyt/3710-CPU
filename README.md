# ECE 3710 Project -- Wolfenstein-style 2.5d renderer

TODO: Copy paste abstract here.

This file contains a description of the project contents, including a
code listing and schematics which provide a visual overview of the
hardware. It also includes a short user guide for reproducing the
project by loading it on the Altera Terasic DE1-SoC FPGA using the
Intel Quartus/Questa software package.

## Project contents

Code describing the hardware, including the CPU, GPU, IO controller,
and memory module, live in `quartusProject/`. The `quartusProject`
directory also contains a collection of Verilog test benches, test and
verification scripts, and assembly test programs.

Specifically, the files are organized in the following way:

- Main file: `system_mapped1.v`
- CPU
  - `controller.v`
  - `cpu.v`
  - `datapath.v`
  - `rayCast.v`
  - `rayCastReg.v`
  - `sin_cos.v`
  - `sqrt.v`
  - `sqrt32to16.v`
  - `utilities.v`
- GPU
  - `GPU.v`
  - `GPUController.v`
  - `gpuLookup.v`
  - `textureROM.v`
  - `vgaContoller.v`
- IO
  - `uartrx.v`
- Memory
  - `memory.v`
  - `memoryMappedIO.v`
  - `MemoryTest/CPUMemory.v`
  - `MemoryTest/memory.v`
- Test benches
  - `GPUTest.v`
  - `cpu_test1.v`
  - `cpu_test2.v`
  - `cpu_test3.v`
  - `cpu_test4.v`
  - `gpuTester.v`
  - `rayCastTB.v`
  - `rayCast_tb.v`
  - `sin_cos_tb.v`
  - `tb_ALU.v`
  - `tb_CPUMemory.v`
  - `tb_gpuLookup.v`
  - `tb_memoryMappedIO.v`
- Test/verification scripts
  - `rayCastCheck.py`
  - `sqrt32to16Check.py`
  - `sqrt32to16TB.py`
  - `sqrtCheck.py`
  - `sqrtTB.py`
  - `verify_sin_cos.py`
- Test programs
  - `fibonacci.c`
  - `fibonacci3`
  - `test_assembly1`
  - `test_assembly2`
  - `test_assembly3`
  - `test_assembly4`
  - `test_sin.asm`
- Still need?
  - `binary_to_bcd.v`
  - `data_memory_mapped1.v`
  - `hexTo7Seg.v`
  - `leftShift.v`
  - `rightShift.v`
  
The assembly code for the project is contained in the `assembler`
directory. 
- `assembler.py` is the main assembler we use to
generate machine code for the CPU. It is a modified version of the
class provided assembler. 
- `AssemblerNotes.txt` contains some notes documenting our added 
features, and some notes and conventions about how the assembler is supposed to
be used.
- `game.asm` is the main code to run the movement and wall
calculation algorithm.
- `build.sh` quickly compiles the code and loads it into the
programming files, without having to recompile the whole Quartus
project.


The `docs` directory contains a few reference files and diagrams.
- `map.png` is a line drawing of the playable map.
- `memmap_layout.txt` documents all the reserved memory locations.

The `Arduino` directory Contains the arduino code for the joystick
adapter.

The `MemoryTest` directory contains the early memory checkpoint
verilog code.




## TODOs

- [x] Comment `controller.v`
- [x] Comment `datapath.v`
- [x] Comment `cpu.v`
- [x] Comment `system_mapped1.v`
- [x] Comment `utilities.v`
- [x] Comment `rayCast.v`
- [x] Comment `rayCastReg.v`
- [x] Comment `sin_cos.v`
- [x] Comment `sqrt.v`
- [ ] Comment `sqrt32to16.v`
- [ ] Comment `GPU.v`
- [ ] Comment `GPUController.v`
- [ ] Comment `gpuLookup.v`
- [ ] Comment `textureROM.v`
- [ ] Comment `vgaContoller.v`
- [x] Comment `uartrx.v`
- [x] Comment `memory.v`
- [x] Comment `memoryMappedIO.v`
- [x] Comment `MemoryTest/CPUMemory.v`
- [x] Comment `MemoryTest/memory.v`
- [ ] Paste abstract from report at the top
- [x] Document `assembler` directory.
- [x] `docs` directory
  - `ALUInstructionList.txt` still relevant?
  - Move `AssemblerNotes.txt` here or mention it here
  - Prolly move `instructionList.txt` here?
  - `memmap_layout.txt` still relevant?
  - Mention `Modules.jpg` and `overall.jpg` here
- [x] Handle `MemoryTest/` directory 
  - MemoryTest files should be moved to quartusProject in my opinion

## User guide
