Zero Field Splitting Code
===================================

Description
------------------------------------
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
(`make` will compile all code and link executables in `./bin/`)

After Installation:
------------------------------------
Try out the example calculations under the directory `./Examples/`
* [Sine-Wave](Examples/Sine-Wave/README.md)
* [NV-Diamond](Examples/NV-Diamond/README.md)

Help:
------------------------------------

<details>
<summary>More installation options</summary>
<p>
Specify mpi path of `~/.openmpi` and fftw path of `~/.fft-3.3.8`

```bash
./configure -m ~/.openmpi -f ~/.fft-3.3.8
```
</p>
</details>
<details>
<summary>Help installing fftw</summary>
<p>
Automatic installation:

```bash
./scripts/FFTW_install.sh
```

For local installation:

```bash
./scripts/FFTW_install.sh -l
```

Or manual installation:

```bash
wget http://www.fftw.org/fftw-3.3.8.tar.gz
tar -xzvf fftw-3.3.8.tar.gz
cd fftw-3.3.8
configure [options]
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

Author
------------------------------------
Original Version Created Wed. June 19th 2019 by Tyler J. Smart

