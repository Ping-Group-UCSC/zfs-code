#!/usr/bin/env python


import pandas as pd
import numpy as np
import sys


def read_D_ab(f):
    return np.array([
        f.readline().split() for _ in range(3)
    ], dtype=np.float64)


def read_eig_and_evec(f):
    eig, evec = [], []
    for _ in range(3):
        lsplit = f.readline().split()
        eig.append(lsplit[2])
        evec.append(lsplit[4:7])
    return np.array(eig, dtype=np.float64), np.array(evec, dtype=np.float64)


def read_zfs_par(f):
    lsplit = f.readline().split()
    return np.float64(lsplit[2]), np.float64(lsplit[4])


def main():
    '''
    script for scrapping D_ab, Eigenvalues, Eigenvectors, and D/E parameters from zfs calculation
    saves in excel spreadsheet 'zfs.xlsx'
    '''
    # read user input specifying path to zfs.x output
    try:
        zfs_out = sys.argv[1]
    except IndexError:
        print("Please provide the path to the zfs.x output file to read")
        sys.exit(1)

    # read data from zfs.x output
    with open(zfs_out) as f:
        for line in f:
            if line.startswith(" Matrix D_ab (GHz) = "):
                D_ab = read_D_ab(f)
            elif line.startswith(" Computing Eigenvalues of D_ab"):
                eig, evec = read_eig_and_evec(f)
            elif line.startswith(" Zero Field Splitting Parameters"):
                D, E = read_zfs_par(f)

    # write data to excel file
    fname = 'zfs.xlsx'
    with pd.ExcelWriter(fname) as writer:
        pd.DataFrame(D_ab).to_excel(writer, sheet_name='D_ab')
        pd.DataFrame(eig).to_excel(writer, sheet_name='eig')
        pd.DataFrame(evec).to_excel(writer, sheet_name='evec')
        pd.DataFrame([D, E]).to_excel(writer, sheet_name='par')


if __name__ == '__main__':
    main()
