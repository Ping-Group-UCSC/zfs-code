#!/usr/bin/env bash

git checkout kairay

module purge
module load openmpi fftw

fftw="/cm/shared/apps/fftw/fftw-3.3.8"

./configure -f $fftw
make
