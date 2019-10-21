NV-Diamond Example (Incomplete)
===================================

What is computed here
-----------------------------------
In this example we calculate the zero-field splitting of the negatively charge NV center in Diamond

Prerequisites:
-----------------------------------
* [Quantum ESPRESSO](http://www.quantum-espresso.org/)

Instructions:
-----------------------------------
0. The first step is to obtain the output of a pw.x calculation. This is already done for a 2x2x2 supercell of diamond with a single NV- center. (see input: './scf.in', output: './scf.out', and outdir: './temp/')
1. Run conv_export.sh found at the root of the repository. This runs pw_export.x and rewrites files for zfs calculation.

```bash
../../conv_export.sh di temp
```
2. You can now view the list of g-vectors in 'Converted_Export/grid.txt' and wfc files in 'Converted_Export/wfc(spin)_(band).txt'

```bash
vim Converted_Export/grid.txt
vim Converted_Export/wfc1_1.txt
```
3. The file './zfs.in' contains the typical input for the zero-field splitting code. The file format is not flexible so be careful to not adjust it's format significantly. Further information on the input can be found in '../../ZFS/input.f90' under the subroutine 'parse_input'.

```bash
vim ./zfs.in
vim ../../ZFS/input.f90
```
4. Run ZFS calculation using the acceptable options [-i] | [-in] | [-inp] | [-input]. The exact time for the calculation to finish will vary between systems but should take around 3.5 minutes in this case.

```bash
../../bin/zfs.x -i ./zfs.in > ./zfs.out
```
5. The final ZFS is can be grepped from the file output.

```bash
grep ! ./zfs.out
```
6. Comparing with experiment and other calculations ... TODO


<!-- may eventually add help menu's such as download QE -->

