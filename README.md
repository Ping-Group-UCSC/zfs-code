Zero Field Splitting Code
===================================

Author
------------------------------------
Original Version Created Wed. June 19th 2019 by Tyler J. Smart
This code calculates the ZFS parameter as in the article:
  [M. J. Rayson and P. R. Briddon, *Physical Review B* **77**, 035119 (2008).](https://journals.aps.org/prb/abstract/10.1103/PhysRevB.77.035119 "First principles method for the calculation of zero-field splitting tensors in periodic systems")

Prerequisites:
------------------------------------
    * mpi fortran compiler (e.g. impi, openmpi)
    * fftw3

Quick Installation:
------------------------------------
    ./configure [options]
    make
("make" will compile all code and link executables in 'bin/')

Further Information:
------------------------------------
The calculation requires scf output with pw_export followed by conversion bash script to generate
simple grid and wfc input files. #TODO -- add this and explain

The flow of the ZFS calculation is as follows:
------------------------------------
    1. input bands to compute and location of grid of wfc files
    2. read npw, grid, and wfc
    3. calculate f1(G), f2(-G), f3(G)
    4. calculate ρ(G-G')
    5. calculate D_(ab); including ZFS parameter

After Installation:
------------------------------------
    Try out the example calculations under the directory 'Examples/'
