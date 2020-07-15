#!/usr/bin/env python

import signal # for handling ctrl-c
import sys
import os
import numpy as np

# Edit the value of vbu_dir to include the path to the vasp band unfolding code
# can download this code from gitlab: https://github.com/QijingZheng/VaspBandUnfolding
vbu_dir = os.path.join(os.path.dirname(__file__), 'VBU')
if not os.path.exists(vbu_dir):
    sys.stderr.write(
        'Error: Directory \'{}\' does not exist. \
Please update the script with the path to the code from: \n\
    https://github.com/QijingZheng/VaspBandUnfolding\n'.format(vbu_dir)
        )
    sys.exit(1)

# import vbu code
sys.path.append(vbu_dir)
from vaspwfc import vaspwfc

'''
Defining functions
'''

def handler(signal_received, frame):
    # Handle any cleanup here
    sys.stderr.write('\nSIGINT or CTRL-C detected. Exiting gracefully\n')
    sys.exit(1)


def die(message):
    sys.stderr.write("Error: {}\n".format(message))
    sys.exit(1)


def checkFile(filename):
    if not os.path.isfile(filename):
        die('File \'{}\' does not exist'.format(filename))


def readNBND():
    checkFile('OUTCAR')
    with open('OUTCAR') as f:
        for line in f:
            if 'NBANDS=' in line:
                return int(line.split('NBANDS=')[1])
    return 0


def calcB(wav):
    # compute reciprocal lattice vectors form real space lattice parameters
    pre = 2 * np.pi / np.dot( wav._Acell[0], np.cross( wav._Acell[1], wav._Acell[2] ) )
    b = np.zeros((3,3), dtype=float)
    for i in range(3):
        b[i] = pre * np.cross( wav._Acell[ (i + 1) % 3 ], wav._Acell[ (i + 2) % 3 ] )
    return b


def writeCell(wav, outdir):
    # write cell
    bohr = 1.8897259886 # convert angstrom to bohr

    outfile = os.path.join(outdir, "cell.txt")
    sys.stdout.write(indent + indent + "Writing Cell to '{}'\n".format(outfile))

    omega = wav._Omega * bohr**3    # volume
    a = wav._Acell * bohr           # real space vectors
    b = calcB(wav) * bohr           # reciprocal vectors calculated as above

    with open(outfile, 'w') as f:
        f.write( "  {:20.10e}\n".format(omega) )
        for i in range(3):
            f.write( "  {:20.10e}  {:20.10e}  {:20.10e}\n".format(*a[i]) )
        for i in range(3):
            f.write( "  {:20.10e}  {:20.10e}  {:20.10e}\n".format(*b[i]) )
    return None


def writeGrid(wav, outdir, kpt=1):
    # write grid
    outfile = os.path.join(outdir, "grid.txt")
    sys.stdout.write(indent + indent + "Writing grid to '{}'\n".format(outfile))
    grid = wav.gvectors(ikpt=kpt)
    with open(outfile, 'w') as f:
        for i in range( len(grid) ):
            f.write( "  {:5d}  {:5d}  {:5d}\n".format(*grid[i]) )
    return None


def writeWFC(wav, outdir, nbnd, kpt=1):
    # write wfc files
    for ispin in range(1,3):
        sys.stdout.write(indent + indent + "Writing {} wfc of spin {} ... ".format(nbnd, ispin))
        sys.stdout.flush()
        for iband in range(1,nbnd+1):
            outfile = os.path.join( outdir, "wfc{}_{}.txt".format(ispin, iband) )
            wfc_g = wav.readBandCoeff(ispin=ispin, ikpt=kpt, iband=iband)
            with open(outfile, 'w') as f:
                for i in range( len(wfc_g) ):
                    f.write( "( {:20.10e} , {:20.10e} )\n".format( wfc_g[i].real,  wfc_g[i].imag ) )
        sys.stdout.write("done\n")
    return None


# # # alternative write wfc_r
# # wfc_r = wav.wfc_r(ispin=spin, ikpt=kpt, iband=band, ngrid=wav._ngrid * mult) 
# # with open(outinfo, 'w') as f:
# #     f.write("{} {} {}".format(wfc_r.shape[0], wfc_r.shape[1], wfc_r.shape[2]))
# # wfc_r_flat = wfc_r.flatten()
# # with open(outdata, 'w') as f:
# #     for i in range( len(wfc_r_flat) ):
# #         f.write( "{}  {} \n".format( wfc_r_flat[i].real,  wfc_r_flat[i].imag ) )


'''
main program defined below
'''

def main():

    # call handler if SIGINT or ctrl-c received
    signal.signal(signal.SIGINT, handler)
    
    help_message = "\
    This helper script is used to create input for the ZFS code from a VASP output. \n\
    Important Note!!! This code uses routines from 'https://github.com/QijingZheng/VaspBandUnfolding'\n\
\n\
    Usage: \n\
        $ ./{} <options> \n\
\n\
    Options:\n\
        -h | --help     display this help menu and quit\
\n".format(os.path.basename(sys.argv[0]))
    
    # handle help or wrong usage
    if "-h" in sys.argv or "--help" in sys.argv:
        sys.stdout.write( "{}\n".format(help_message) )
        sys.exit(0)
    # read command line
    # spin, kpt, band, mult = tuple(map(int, sys.argv[1:5]))

    global indent 
    indent = "    "
    sys.stdout.write(indent + "Converting vasp wavecar to format for ZFS code\n")

    
    # read nbnd from OUTCAR
    nbnd = readNBND()
    if nbnd == 0:
        die('Trouble reading nbnd from OUTCAR')
    sys.stdout.write(indent + indent + "nbnd = {}\n".format(nbnd))
    # define wave as from vaspwfc module
    sys.stdout.write(indent + indent + "Checking WAVECAR ... ")
    sys.stdout.flush()
    checkFile('WAVECAR')
    wav = vaspwfc('WAVECAR')
    sys.stdout.write("good\n")
    sys.stdout.flush()

    # folder where all files will be dumped to
    outdir = 'Converted_Export'
    if not os.path.exists(outdir):
        os.mkdir(outdir)
    sys.stdout.write(indent + indent + "Output to be written to '{}'\n".format(outdir))
    sys.stdout.flush()

    # write cell, grid, and wfc
    writeCell(wav, outdir)
    writeGrid(wav, outdir)
    writeWFC(wav, outdir, nbnd)
    
    sys.stdout.write(indent + "All done!\n")


'''
if ran as main call main
'''
if __name__ == "__main__":
    main()
