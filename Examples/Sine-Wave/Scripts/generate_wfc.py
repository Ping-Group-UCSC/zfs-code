#!/usr/bin/python

import numpy as np


############################## variables ##############################

npw = 1357
form = " ( {} , {} ) \n"

freqs_1 = np.array(
    [np.array([1, 0, 0]), np.array([3, 0, 0]), np.array([0, 2, 0]), np.array([0, 0, 1])]
)

freqs_2 = np.array([np.array([2, 0, 0]), np.array([0, 1, 0]), np.array([0, 2, 0])])


############################## functions ##############################


def readGrid():
    with open("grid.txt") as f:
        lines = f.readlines()
    grid = np.array([np.array([int(val) for val in line.split()]) for line in lines])
    return grid


def writeWFC(freqs, fName):
    with open(fName, "w") as f:
        for i in range(npw):
            case = -1
            for freq in freqs:
                if np.array_equal(grid[i], freq):
                    case = 1
                    break
            for freq in -freqs:
                if case == 1:
                    break
                if np.array_equal(grid[i], freq):
                    case = 2
                    break
            if case == 1:
                f.write(form.format(0.0, 0.5))
            elif case == 2:
                f.write(form.format(0.0, -0.5))
            else:  # case == -1:
                f.write(form.format(0.0, 0.0))
    return None


############################### program ###############################

grid = readGrid()
writeWFC(freqs_1, "wfc1_1.txt")
writeWFC(freqs_2, "wfc1_2.txt")

