#!/usr/bin/env python3


import sys
import os
import re
import numpy as np

import signal
from vasp_interface import die, handler 


'''
functions
'''

# routine to read files and sum
def sumFile(filename):
    # read file to array
    with open(filename) as f:
        ar = []
        for ln in f:
            ln = re.sub('[()]','',ln).split(',')
            ar.append( float(ln[0]) + 1j * float(ln[1]) )
        ar = np.array(ar)
    # sum
    s = 0
    for a in ar:
        s += np.conj(a) * (a)
    return s


'''
code
'''

def main():

    signal.signal(signal.SIGINT, handler)
    
    # check input
    if len(sys.argv) == 1:
        print('Usage: ./test_sum.py <list of wfc txt files to sum>')
        sys.exit(0)
    
    files = sys.argv[1:]
    
    # check files
    for filename in files:
        if not os.path.isfile(filename):
            die("File '{}' does not exist or is not a file".format(filename))
        s = sumFile(filename)
        print("Sum {}: {}".format(filename, s))
    
    return None


if __name__ == "__main__":
    main()



