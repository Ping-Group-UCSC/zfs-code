#!/usr/bin/env python


import os
import sys
import numpy as np


def die(message):
    sys.stderr.write("Error: {}\n".format(message))
    sys.exit(1)


def readFiles(inFiles):
    npw = []
    evc = []
    for inFile in inFiles:
        with open(inFile) as f:
            lines = f.readlines()
        npw_part = len(lines)
        evc_part = np.zeros(npw_part, dtype=np.complex128)
        for i, line in enumerate(lines):
            evc_part[i] = np.float64(line.split()[0]) + 1j * np.float64(line.split()[2])
        npw.append(npw_part)
        evc.append(evc_part)
    return npw, evc


def calcOverlap(evc):
    # calculate and sum product of wavefunctions
    p1 = np.conjugate(evc[0]) * evc[0]
    p2 = np.conjugate(evc[1]) * evc[1]
    p3 = np.conjugate(evc[0]) * evc[1]
    # return np.absolute(np.sum(product))/ngtot
    return np.absolute(np.sum(p1)), np.absolute(np.sum(p2)), np.absolute(np.sum(p3)) 


def calcSum(evc):
    # calculate sum
    return np.absolute(np.sum(evc[0])), np.absolute(np.sum(evc[1])), np.absolute(np.sum(evc[2]))


lf = False
while len(sys.argv) > 1:
    if sys.argv[1] == "-f":
        lf = True
        del sys.argv[1]
    elif sys.argv[1] == "-w":
        lf = False
        del sys.argv[1]
    elif sys.argv[1].startswith("-"):
        die ("Unrecognized options: {}".format(sys.argv[1]))
    else:
        break

if lf and len(sys.argv) == 4:
    inFiles = sys.argv[1:4]
elif not lf and len(sys.argv) == 3:
    inFiles = sys.argv[1:3]
else:
    die("Incorrect number of files specified: {}".format(len(sys.argv) - 1))

npw, evc = readFiles(inFiles)

for i in range(len(npw) - 1):
    if npw[i] != npw[i+1]:
        die("npw from file{} and file{} differ: npw = {} and {}, respectively".format(i,i+1,npw[i],npw[i+1]))

if not lf:
    p1, p2, p3 = calcOverlap(evc)
else:
    p1, p2, p3 = calcSum(evc)


print("|<wfc1|wfc1>|^2 = {}".format(p1))
print("|<wfc2|wfc2>|^2 = {}".format(p2))
print("|<wfc1|wfc2>|^2 = {}".format(p3))

