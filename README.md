Zero Field Splitting Code
===================================

Author & Description
------------------------------------
Original Version Created Wed. June 19th 2019 by Tyler J. Smart

This code calculates the ZFS parameter as in the article:

[M. J. Rayson and P. R. Briddon, *Physical Review B* **77**, 035119 (2008).](https://journals.aps.org/prb/abstract/10.1103/PhysRevB.77.035119 "First principles method for the calculation of zero-field splitting tensors in periodic systems")

Prerequisites:
------------------------------------
* MPI Library (e.g. [Intel MPI](https://software.intel.com/en-us/mpi-library), [Open MPI](https://www.open-mpi.org/))
* [FFTW3](http://www.fftw.org/)

Quick Installation:
------------------------------------
    ./configure [options]
    make
("make" will compile all code and link executables in 'bin/')

After Installation:
------------------------------------
Try out the example calculations under the directory 'Examples/'
* [Sine-Wave](Examples/Sine-Wave/README.md)
* [NV-Diamond](Examples/NV-Diamond/README.md)

Known/Possible Issues:
------------------------------------
* FFT and convolution calculation of the functions f(G) give different results (see [Sine-Wave Example](Examples/Sine-Wave/README.md))
* Possible issue (not considered by Sine-Wave Example) is larger frequencies are not correctly wrapped and padding of wavefunctions is necessary. For example in this example frequencies can go up to 6 but only up to 3 is fully tested. (Further testing on this is ongoing.)
* Another possible issue is that the order of f1(G) and f2(G) is incorrect (need to try swapping).
* I/O needs to be improved (a fix is in progress).
* MPI needs further testing on diferent machines.
* Please let me know if you run into any unexpected issues: @tjsmart

To-Do:
------------------------------------
* Add verbosity option to zfs code
* Add Sine-Wave example
* Finish NV-Diamond example
* Clean up script for Examples/ folder

Help:
------------------------------------

<details>
<summary>FFTW3</summary>
<p>
Automatic installation:

```bash
./FFTW_install.sh
```

Or manual installation:

```bash
wget http://www.fftw.org/fftw-3.3.8.tar.gz
tar -xzvf fftw-3.3.8.tar.gz
cd fftw-3.3.8
configure
make
make install
```
</p>
</details>

Flow of the ZFS Code:
------------------------------------
1. input file specifies bands to compute and location of grid and wfc files
2. read npw, grid, and wfc
3. calculate f1(G), f2(-G), f3(G) [fft or convolution]
4. calculate ρ(G-G')
5. calculate D_(ab); including ZFS parameter
