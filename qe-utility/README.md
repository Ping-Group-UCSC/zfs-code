qe-utility
======================

qe-utility is a fortran program which can be run as any other pp code of QE

Requirement: [qe version 6.1](https://github.com/QEF/q-e/releases/tag/qe-6.1.0) or older.

Compilation:
```bash
./qe-utility/configure -q [/path/to/qedir]
make
```

Generates executable: `qe-utility/zfs.x`

Example input:
```bash
cat > qe-zfs.in << EOF
&inputpp
 prefix = 'di',
 outdir = 'temp',
 ibnd1 =383, ibnd2 =384
/
EOF
```

Run it:
```bash
./qe-utlity/zfs.x -i qe-zfs.in > qe-zfs.out
```

Generates `qe.dump` folder with data:
* `wfc1.txt`, `wfc2.txt`                - wfc ibnd1 and ibnd2 defined in G space
* `wfc1_r.txt`, `wfc2_r.txt`            - wfc ibnd1 and ibnd2 defined in R space
* `f1_r.txt`, `f2_r.txt`, `f3_r.txt`    - convolution functions defined in R space
* `f1_G.txt`, `f2_G.txt`, `f3_G.txt`    - convolution functions defined in G space

Use `qe-utility/check_norm.py` for checking sum rules of output wavefunctions or 'f' functions
```bash
./qe-utility/check_norm.py -w qe.dump/wfc1.txt qe.dump/wfc2.txt
./qe-utility/check_norm.py -w qe.dump/wfc1_r.txt qe.dump/wfc2_r.txt
./qe-utility/check_norm.py -f qe.dump/f1_r.txt qe.dump/f2_r.txt qe.dump/f3_r.txt
./qe-utility/check_norm.py -f qe.dump/f1_G.txt qe.dump/f2_G.txt qe.dump/f3_G.txt
```
