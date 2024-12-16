# ECE 3710 Project -- Wolfenstein-Style 2.5D Renderer

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
- [x] Comment `gpuLookup.v`
- [x] Comment `textureROM.v`
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

## User Guide

This guide provides comprehensive instructions on how to set up, program, and operate the custom Wolfenstein-style 3D raycasting engine on a DE1-SoC FPGA system with an Arduino-based Nunchuk controller interface. It also covers troubleshooting, performance considerations, and maintenance guidelines.

## Table of Contents
1. [Introduction](#introduction)
2. [System Requirements](#system-requirements)
3. [Hardware Setup](#hardware-setup)
4. [Software Installation](#software-installation)
5. [Project Configuration](#project-configuration)
6. [FPGA Programming](#fpga-programming)
7. [Operation and Controls](#operation-and-controls)
8. [Troubleshooting](#troubleshooting)

## Introduction

The Wolfenstein-style 3D renderer is a hardware/software co-designed project that demonstrates how early 3D rendering techniques can be implemented on a modern FPGA platform. By leveraging a custom CPU, GPU pipeline, and memory-mapped I/O interfaces, the system efficiently transforms a 2D grid of walls into a compelling first-person perspective scene in real time.

**Key Features:**
- Real-time raycasting-based 3D environment rendering
- Texture-mapped walls for enhanced visual detail
- Smooth double-buffered VGA output
- Responsive joystick (Nunchuk) input for player movement and orientation
- Extensible architecture for future enhancements

## System Requirements

### Hardware Requirements
- **DE1-SoC FPGA Development Board** (Cyclone V device recommended)
- **USB Type-B cable** (for FPGA programming and power)
- **VGA-compatible display** (capable of 640x480@60Hz)
- **Arduino Uno** (or compatible microcontroller board)
- **Wii Nunchuk controller**
- **VGA cable** (HD-15 connector)

### Software Requirements
- **Intel Quartus Prime Lite (v23.1 or compatible)** with Cyclone V support
- **Arduino IDE** (latest version)
- **WiiChuck Arduino library** (installable via Arduino Library Manager)
- **USB Blaster drivers** (for FPGA programming)
- **Serial Monitor** (optional, for debugging Arduino outputs)

## Hardware Setup

1. **FPGA Board Setup**
   - Connect the DE1-SoC board to your PC using the USB Type-B cable.
   - Attach a VGA cable from the DE1-SoC VGA port to your display.
   - If powering via USB, ensure the power switch on DE1-SoC is set to USB.  
     If using an external adapter, connect it and switch to the appropriate power setting.
   - Turn on the DE1-SoC board; ensure power and configuration LEDs indicate normal operation.

2. **Arduino and Nunchuk Setup**
   - Connect the Arduino Uno to your PC via USB.
   - Wire the Wii Nunchuk to the Arduino as follows:
     ```
     Nunchuk Pin  | Arduino Pin
     -------------|------------
     VCC (3.3V)   | 3.3V
     GND          | GND
     SDA          | A4
     SCL          | A5
     ```
   - Connect Arduino’s TX pin (D1) to the specified DE1-SoC GPIO pin (refer to project documentation for exact pin assignment).
   - Confirm all connections are secure and shielded from noise.

## Software Installation

1. **Quartus Prime:**
   - Download from the Intel website.
   - Install with Cyclone V support and the USB Blaster drivers.
   - Restart your PC if prompted.

2. **Arduino IDE:**
   - Download and install the latest Arduino IDE.
   - In the Arduino IDE, open “Library Manager” and install the “WiiChuck” library.
   - Test the Arduino environment by uploading a simple “Blink” example to ensure everything is functioning correctly.

## Project Configuration

1. **FPGA Project Setup:**
   - Launch Quartus Prime.
   - Open the provided project file `GPU.qpf`.
   - Go to `Assignments -> Device` and confirm:
     - Family: Cyclone V
     - Device: 5CSEMA5F31C6 (or your specific model)
   - Use the `Pin Planner` or `Assignment Editor` to verify all pin assignments match your hardware setup (VGA pins, GPIO for Arduino serial input, etc.).

2. **Arduino Code Upload:**
   - Open `nunchuk_interface.ino` in the Arduino IDE.
   - Select “Arduino Uno” as the board and choose the correct COM port.
   - Upload the sketch. The Arduino will now continuously read Nunchuk input and send data to the FPGA via the specified TX line.

## FPGA Programming

1. **Compiling the Project:**
   - In Quartus Prime, run the following steps:
     - Analysis & Synthesis
     - Fitter
     - Assembler
     - Timing Analysis
   - Address any errors or warnings by reviewing messages and adjusting pin assignments or constraints as needed.

2. **Programming the Device:**
   - Connect the DE1-SoC via USB Blaster (already done via the same USB cable).
   - Open the `Programmer` tool in Quartus.
   - Select “USB-Blaster” as the hardware.
   - Add the `.sof` configuration file generated by the Assembler.
   - Check “Program/Configure” and click `Start`.
   - Wait for the “100% Successful” message.

## Operation and Controls

1. **Power-On Sequence:**
   - Ensure the VGA display is connected and powered on.
   - Power on the DE1-SoC and wait for configuration to complete.
   - Verify that the VGA screen shows a startup pattern or blank display awaiting frame data.

2. **System Initialization:**
   - Press `KEY0` on the DE1-SoC board to reset the system.
   - Confirm that the Arduino is running the Nunchuk interface code and that the Nunchuk is connected.

3. **Movement and Rotation Controls:**
   - Move the Nunchuk joystick forward/backward to move the player.
   - Move the joystick left/right to rotate the player’s viewing angle.
   - The rendered scene should update each frame to reflect the player’s motion.

4. **Reset and Configuration Keys:**
   - `KEY0`: System reset.
   - Other keys currently unused but reserved for future features.

5. **LED Indicators:**
   - LEDs on the DE1-SoC may display debug patterns.
   - Specific LED patterns indicate states (e.g., frame processing, memory access). Refer to project documentation for LED pattern meanings.

## Troubleshooting

1. **No Display Output:**
   - Check VGA cable and monitor compatibility (640x480@60Hz recommended).
   - Press `KEY0` to reset.
   - Reprogram the FPGA if needed.

2. **Controller Not Responding:**
   - Check Arduino-to-FPGA connection.
   - Verify Nunchuk wiring and power.
   - Re-upload Arduino code and reset Arduino.

3. **Visual Artifacts or Flickering:**
   - Check timing constraints and VGA signal integrity.
   - Ensure double-buffering is working; poll GPU status registers before swapping.
   - Reset system if needed.

4. **Slow Performance:**
   - Reduce resolution or texture complexity.
   - Ensure no warnings during compilation that might indicate timing violations.
