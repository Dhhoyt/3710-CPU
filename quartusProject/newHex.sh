#! /bin/bash

quartus_cdb --update_mif GPU
quartus_asm GPU
quartus_pgm -c DE-SoC[1-2] GPU.cdf

