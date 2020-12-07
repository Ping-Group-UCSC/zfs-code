#!/usr/bin/env python3


# ============================================================
'''
This script reads the matrix Dab from the zfs output, diagonalizes it,
then reorders eigenvalues according to x, y, z (principal axis), finally
return the zero-field splitting parameters D and E

Useful for the branch of code with lapack diagonalization
'''
# ============================================================

import numpy as np

GHz2cm1 = 0.033357


def array_2_str(arr, sep=' ', fmt="9.6f", start="[ ", end=" ]"):
    assert len(arr.shape) == 1, "1d arrays only"
    return start + sep.join([f"%{fmt}" % a for a in arr]) + end


def read_dab(filename: str) -> np.ndarray:
    with open(filename) as f:
        for line in f:
            if 'Matrix D_ab (GHz) = ' in line:
                return np.array(
                        [f.readline().split() for _ in range(3)], dtype=float
                    )

def reorder_eig(eigs, evecs):
    '''
    reorder eigs and evecs from np.linalg.eig
    '''
    evecs = evecs.T
    iz = eigs.argmax()
    ix = (iz+1)%3
    iy = (iz+2)%3
    test_cross = np.allclose(np.cross(evecs[ix], evecs[iy]), evecs[iz], atol=1e-2)
    ix, iy = (ix, iy) if test_cross else (iy, ix)
    return eigs[[ix, iy, iz]], evecs[[ix, iy, iz]]

if __name__ == '__main__':
    dab = read_dab('zfs.out')
    eigs, evecs = np.linalg.eig(dab)
    eigs, evecs = reorder_eig(eigs, evecs)
    print("# eigenvalue [eigenvector]")
    for eig, evec in zip(eigs, evecs):
        print(f"{eig:12.6f}: {array_2_str(evec)}")
    print()
    print("# D (GHz)  E(GHz)")
    D = eigs[2]*1.5
    E = (eigs[1] - eigs[0])*0.5
    print(f"{D:12.6f} {E:12.6f}")
    print()
    print("# D (cm-1)  E(cm-1)")
    print(f"{D*GHz2cm1:12.6f} {E*GHz2cm1:12.6f}")
