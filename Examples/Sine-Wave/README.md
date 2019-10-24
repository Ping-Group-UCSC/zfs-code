Sine-Wave Example (Incomplete)
===================================

What is computed here
-----------------------------------
In this example we calculate the convolution functions *f(**G**)* for a simple wave function composed by sine functions.

Prerequisites:
-----------------------------------
* [Python](https://www.python.org/)
* [Gnuplot](http://gnuplot.sourceforge.net/)

Instructions:
-----------------------------------
0. As expressed above, the goal of this example is to demonstrate that the code can correctly read in a grid and set of wavefunctions. Then fourier transform these wavefunctions, compute the real-space convolution functions *f(**r**)* and then fourier transform them back to g-space *f(**G**)* (see [M. J. Rayson and P. R. Briddon, *Physical Review B* **77**, 035119 (2008).](https://journals.aps.org/prb/abstract/10.1103/PhysRevB.77.035119 "First principles method for the calculation of zero-field splitting tensors in periodic systems") for more information.)

![f_r](https://latex.codecogs.com/gif.latex?f_1(\mathbf{r})=|\psi_i(\mathbf{r})|^2,\quad\ f_2(\mathbf{r})=|\psi_j(\mathbf{r})|^2,\quad\ f_3(\mathbf{r})=\psi_i^*(\mathbf{r})\psi_j(\mathbf{r}))

![f_g](https://latex.codecogs.com/gif.latex?f_i(\mathbf{G})=\mathcal{F}\\{f_i(\mathbf{r})\\})

1. The file `./Export/grid.txt` contains a typical list of g-vectors borrowed from the NV-Diamond example. The form is rather simple as each line represents a new 3D g-vector of only integer value (units of reciprocal lattice).

```bash
vim ./Export/grid.txt
```
2. In this example we want build to artificial wavefunctions out of simple combination of sine functions as described below. In this way the exact solution at each step of the calculation is known or can be easily computed by other means.

![psi_1](https://latex.codecogs.com/gif.latex?\psi_{1}(x,y,z)=\sin(1x)&plus;\sin(3x)&plus;\sin(2y)&plus;\sin(1z))

![psi_2](https://latex.codecogs.com/gif.latex?\psi_{2}(x,y,z)=\sin(2x)&plus;\sin(1y)&plus;\sin(2y))

3. Since the starting point of the ZFS calculation is reciprocal space wavefunctions these wavefunctions need to begin in G-space.

<img src="https://latex.codecogs.com/gif.latex?\psi_1(G_x,G_yG_z)=\frac{i}{2}&space;\delta&space;(G_x-1&space;)&space;\delta&space;(G_y)&space;\delta&space;(G_z)-\frac{i}{2}&space;\delta&space;(G_x&plus;1&space;)&space;\delta&space;(G_y)&space;\delta&space;(G_z)&space;\\&space;\text{\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;}&plus;\frac{i}{2}&space;\delta&space;(G_x-3&space;)&space;\delta&space;(G_y)&space;\delta&space;(G_z)-\frac{i}{2}&space;\delta&space;(G_x&plus;3&space;)&space;\delta&space;(G_y)&space;\delta&space;(G_z)&space;\\&space;\text{\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;}&plus;\frac{i}{2}&space;\delta&space;(G_x)&space;\delta&space;(G_y-2&space;)&space;\delta&space;(G_z)-\frac{i}{2}&space;\delta&space;(G_x)&space;\delta&space;(G_y&plus;2&space;)&space;\delta&space;(G_z)&space;\\&space;\text{\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;}&plus;\frac{i}{2}&space;\delta&space;(G_x)&space;\delta&space;(G_y)&space;\delta&space;(G_z-1&space;)-\frac{i}{2}&space;\delta&space;(G_x)&space;\delta&space;(G_y)&space;\delta&space;(G_z&plus;1&space;)" />



<img src="https://latex.codecogs.com/gif.latex?\psi_2(G_x,G_yG_z)=\frac{i}{2}&space;\delta&space;(G_x-2&space;)&space;\delta&space;(G_y)&space;\delta&space;(G_z)-\frac{i}{2}&space;\delta&space;(G_x&plus;2&space;)&space;\delta&space;(G_y)&space;\delta&space;(G_z)&space;\\&space;\text{\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;}&plus;\frac{i}{2}&space;\delta&space;(G_x)&space;\delta&space;(G_y-1&space;)&space;\delta&space;(G_z)-\frac{i}{2}&space;\delta&space;(G_x)&space;\delta&space;(G_y&plus;1&space;)&space;\delta&space;(G_z)&space;\\&space;\text{\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;\&space;}&plus;\frac{i}{2}&space;\delta&space;(G_x)&space;\delta&space;(G_y-2&space;)&space;\delta&space;(G_z)-\frac{i}{2}&space;\delta&space;(G_x)&space;\delta&space;(G_y&plus;2&space;)&space;\delta&space;(G_z)"/>


![fourier transform of sine](https://latex.codecogs.com/gif.latex?\Big(\text{Recall,\ }\mathcal{F}\\{\sin(ax)\\}=\mathcal{F}\\{-i/2\left[e^{iax}-e^{-iax}\right]\\}=-i/2\left[\delta(G_x+a)-\delta(G_x-a)\right]\Big))

4. Run the python script `./Scripts/generate_wfc.py` to generate the above wfc's.

```bash
cd ./Export
../Scripts/generate_wfc.py
```
5. Open the generated wavefunctions alongside `./grid.txt` to confirm that they are of the correct form. (Recall: `gt` can be used to switch between tabs when using `vim -p`. Also, `:qall!` can be used to close all tabs without saving.)

```bash
vim -p ./grid.txt ./wfc_1.txt
cd ..
```
6. The file `./zfs.in` contains an input file for the zfs code. Here we set the option `verbosity = "high"` in order to view extra information from the calculation. **Only use this option when the calculation is small as in this case or it will take forever!**

```bash
vim ./zfs.in
```
7. Run the zfs calculation.

```bash
../../bin/zfs.x -i ./zfs.in > ./zfs.out
```
8. The output file `./zfs.out` is not of interest here, instead we are interested in the contents of the dump directory `./zfs.dump/`.

```bash
cd ./zfs.dump/
```
9. The contents of this folder is as follows:

    1. `grid.txt` contains list of g-space vectors. Identical to `../Export/grid.txt`
    2. `wfc1.txt` and `wfc2.txt` contains the complex g-space wavefunctions. Identical to `../Export/wfc1.txt` and `../Export/wfc2.txt`
    3. `wfc1_r.txt` and `wfc2_r.txt` contains the complex real-space wavefunctions.
    4. `f1_r.txt`, `f2_r.txt` and `f3_r.txt` contain the real-space convolution functions defined above ([step 0](###Instructions)).
    5. `f1_g.txt`, `f2_g.txt` and `f3_g.txt` contain the g-space convolution functions defined above ([step 0](###Instructions)).
    6. `*-og.txt` files are counterparts of the aforementioned files which explicitly show how the wfc are defined over the grid (og). For example the head of `wfc1-og.txt` shows that wfc1 has a weight of *i*/2 at *G* = [0, 0, 1] which agrees with its form written in [step 3](###Instructions).
    ```
    0   0   0 :   0.000000E+000 ,  0.000000E+000
    0   0   1 :   0.000000E+000 ,  0.500000E+000
    0   0   2 :   0.000000E+000 ,  0.000000E+000 
    ```
10. While the grid `grid.txt` contains negative g-vectors, the indices of the wavefunctions must remain positive. As such negative must be wrapped to positive ones as follows:

![fft wrap](https://latex.codecogs.com/gif.latex?\\{-n,...,n\\}\rightarrow\\{0,...,2n\\},\text{\ with\ }-i=2n+1-i)

11. In this case the grid is 13x13x13 and so *n* = 6. Now open `./wfc1-og.txt` and confirm that it has the correct form compared to the above expession under [step 3](###Instructions). In this case we can use a simple grep command to extract non-zero elements.

```bash
grep -v "0\.000000E+000 ,  0\.000000E+000" ./wfc1-og.txt | less
```

12. Following the rule -*i* = 2*n*+1-*i* (with *n* = 6), we can understand the transformation between negative and positive g-vectors and comparing with wfc1(G) with its above expression it does indeed have the correct form. You can also confirm that wfc2 is of the correct form by checking `wfc2-og.txt`
```
   G_x G_y G_z       Re(wfc)         Im(wfc)
   ---------------------------------------------
    0   0   1 :   0.000000E+000 ,  0.500000E+000    |  This corresponds to G = [  0,  0,  1]
    0   0  12 :   0.000000E+000 , -0.500000E+000    |  This corresponds to G = [  0,  0, -1]
    0   2   0 :   0.000000E+000 ,  0.500000E+000    |  This corresponds to G = [  0,  2,  0]
    0  11   0 :   0.000000E+000 , -0.500000E+000    |  This corresponds to G = [  0, -2,  0]
    1   0   0 :   0.000000E+000 ,  0.500000E+000    |  This corresponds to G = [  1,  0,  0]
    3   0   0 :   0.000000E+000 ,  0.500000E+000    |  This corresponds to G = [  3,  0,  0]
   10   0   0 :   0.000000E+000 , -0.500000E+000    |  This corresponds to G = [ -3,  0,  0]
   12   0   0 :   0.000000E+000 , -0.500000E+000    |  This corresponds to G = [ -1,  0,  0]
```

13. Now that we have confirmed the form of wfc(G), we will confirm the form in real-space (wfc(r)) by plotting. Since the wavefunctions are 3-dimensional we will plot 1-dimensional cuts of the wavefunction wfc(x,0,0), wfc(0,y,0) and wfc(0,0,z). Exit `zfs.dump` and run the script `./Scripts/plot.sh -w` to plot the real space wavefunctions.

```bash
cd ..
./Scripts/plot.sh -w
```
14. View the generated eps files with a document viewer such as `okular`. The solid lines correspond to the exact solution to wfc(r) and the points are the ones generated by the output of `zfs.x`.

```bash
okular ./wfc1_r.eps ./wfc2_r.eps
```
15. Next we turn our focus to the convolution functions f(r) defined [above](###Instructions). According to their definition, the expected solution of the functions f(r) should be defined as below.

![f1_r](https://latex.codecogs.com/gif.latex?f_{1}(x,y,z)=\big[\sin(1x)&plus;\sin(3x)&plus;\sin(2y)&plus;\sin(1z)\big]^2)

![f2_r](https://latex.codecogs.com/gif.latex?f_{2}(x,y,z)=\big[\sin(2x)&plus;\sin(1y)&plus;\sin(2y)\big]^2)

![f3_r](https://latex.codecogs.com/gif.latex?\dpi{120}&space;\small&space;f_{3}(x,y,z)=\big[\sin(1x)&plus;\sin(3x)&plus;\sin(2y)&plus;\sin(1z)\big]\times\big[\sin(2x)&plus;\sin(1y)&plus;\sin(2y)\big])

16. Plot the convolution functions using the script `./Scripts/plot.sh -f` and view the generated eps files with a document viewer.

```bash
./Scripts/plot.sh -f
okular ./f1_r.eps ./f2_r.eps ./f3_r.eps
```

17. Lastly, we want to confirm that the form of f(G) is correct. In order to better understand the expected output of f(G), the expanded forms of f(r) are included in the pdf `./fft_algebra.pdf` alongside other formulas in this document. In these forms the expected albeit extremely lengthy forms of f(G) are more easily understood. (The mathematica document `./Scripts/algebra.nb` contains more notes on there derivation.)

```bash
okular ./fft_algebra.pdf
```

18. According to `./fft_algebra.pdf` all of the f(G) functions are purely real. Using awk we can quickly confirm that the imaginary part of f(G) is zero everywhere. (The imaginary part of f(G) corresponds to the 7th column of `zfs.dump/f*_G-og.txt`.) The following `awk` command should produce no result

```bash
awk 'sqrt($7^2) > 1e-10 {print $0}' ./zfs.dump/f*_G-og.txt
```
19. Meanwhile the real part of f(G) is non-zero at several spots. (The real part of f(G) corresponds to the 5th column of `zfs.dump/f*_G-og.txt`.). Use the helper script `./Scripts/awk_f_G.sh` to check out the non-zero elements of the convolution functions f(G).

```bash
./Scripts/awk_f_G.sh | less
```
20. Careful inspection of the previous output alongside the exact form of the convolution functions `./fft_algebra.pdf` reveals that the calculated f(G) are all correct.

21. Lastly, we can calculate the convolution functions f(G) using direct convolution which avoids any FFT's but is dramatically slower. First enter the directory `./zfs.dump` and move the contents to a new directory to avoid overwriting them.

```bash
cd ./zfs.dump
mkdir fft
mv *.txt fft
cd ..
```
22. The input `./zfs-conv.in` has the option `direct_flag = .true.`. Run this calculation to produce output with the direct convolution method.

```bash
../../bin/zfs.x -i ./zfs-conv.in > ./zfs-conv.out
```
23. First, we can see that both methods produce the same result.

```bash
grep ! ./zfs.out ./zfs-conv.out
    ./zfs.out: ! ZFS = ********** GHz =  82.620453 cm-1
    ./zfs-conv.out: ! ZFS = ********** GHz =  82.620453 cm-1
```
24. Finally, we can plot each convolution function and see they are exactly the same using the script `Script/f_g.gnu`.

```bash
./Scripts/f_g.gnu
okular fft-vs-con_*.eps
```





