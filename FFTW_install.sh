#!/bin/bash


############################## variables ##############################

description="Description: This script installs FFTW3\n"
usage="Usage: ./FFTW_install.sh [-h, --help] || [options]\n"
options="Options: \n\
    [-h, --help]            print help menu\n\
    [-f, --fftdir] fftdir   path to fft header files (e.g. '/usr/local/include')\n"
indent="    "
fftdirs="/usr/include /usr/local/include"
fftwfile="fftw3.f03"
fftwver="3.3.8"
fftwurl="http://www.fftw.org/fftw-${fftwver}.tar.gz"
fftwtar="fftw-${fftwver}.tar.gz"
fftwdir="fftw-${fftwver}"
lfftdir=false


############################## funcitons ##############################

function checkArguments(){
    # handles command line arguments
    while [ ! -z "$1" ]; do
        if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
            printf "$description\n$usage\n$options"
            exit 0
        elif [ "$1" == "-f" ] || [ "$1" == "--fftdir" ]; then
            if [ -d "$2" ]; then
                fftdirs=$(echo "$(realpath $2) $fftdirs")
                shift ; shift
            else
                echo "Error: Directory '$2' does not exist"
                exit 1
            fi
        else
            echo "Error: Command line option '$1' is not recognized"
            exit 1
        fi
    done
}


function findFFTW(){
    # find fftw installation
    for fftdir in $fftdirs; do
        if [ -f "$fftdir/$fftwfile" ]; then
            lfftdir=true
            break
        fi
    done
    if $lfftdir; then
        echo "${indent}FFTW lib found ... $fftdir"
    else
        echo "${indent}FFTW lib not found."
    fi
}


function installFFTW(){
    # install FFTW from web
    while true; do
        read -p "${indent}Do you wish to install fftw-${fftwver}? [y/n]  " yn
        case $yn in
            [Yy]* ) installFFTWInternal; break;;
            [Nn]* ) echo "${indent}Skipping installation.";  break;;
            * ) echo "Please answer y or n.";;
        esac
    done
}


function installFFTWInternal(){
    echo "wget $fftwurl"
    if wget $fftwurl ; then
        echo "tar -xzvf $fftwtar"; tar -xzvf $fftwtar
        echo "cd $fftwdir"; cd $fftwdir
        echo "./configure"; ./configure
        echo "make -j 8"; make -j 8
        echo "make install"; make install
        echo "cd .."; cd ..
        echo "rm -f $fftwtar"; rm -f $fftwtar
    else
        echo "Error: Unable to download FFTW"
        exit 1
    fi
}

############################### program ###############################

checkArguments $@
echo "Searching for FFTW3 and installing version ${fftwver} if FFTW3 not found"
findFFTW
if ! $lfftdir; then
    echo "${indent}Installing FFTW."
    installFFTW
else
    echo "${indent}Skipping installation."
fi
echo "Done! :)"

