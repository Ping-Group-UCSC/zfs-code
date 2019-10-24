#!/bin/bash


############################## variables ##############################

description="Description: This script cleans the Examples/ folder\n"
usage="Usage: ./clean_examples.sh [-h, --help] || [options]\n"
options="Options: \n\
    [-h, --help]        print help menu\n\
    [-s, --sine]        only clean Examples/Sine-Wave folder\n\
    [-d, --diam]        only clean Examples/NV-Diamond folder\n"
indent="    "
files="\
    Examples/*/Converted_Export/ \
    Examples/*/pw_export* \
    Examples/*/temp/*.export/ \
    Examples/*/temp/*.wfc1 \
    Examples/*/short.out \
    Examples/*/zfs.out \
    Examples/*/zfs.dump/ \
    Examples/Sine-Wave/zfs-conv.out \
    Examples/Sine-Wave/Export/wfc1_*.txt \
    Examples/Sine-Wave/*_r.eps \
    Examples/Sine-Wave/fft-vs-con_*.eps
    " # copied and pasted from .gitignore -- but don't want to assume .gitignore exists or is the same
pathToExamples='..' # change me if file is moved!!!


############################## funcitons ##############################

function checkArguments(){
    # handles command line arguments
    while [ ! -z "$1" ]; do
        if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
            printf "$description\n$usage\n$options"
            exit 0
        elif [ "$1" == "-s" ] || [ "$1" == "--sine" ]; then
            ldiam=false
        elif [ "$1" == "-d" ] || [ "$1" == "--diam" ]; then
            lsine=false
        else
            echo "Error: Command line option '$1' is not recognized"
            exit 1
        fi
    done
}

function confirmRemoval(){
    # confirm that user wants to clean these example directories TODO -- code below is incomplete
    while true; do
        read -p "${indent}Do you wish to clean Examples/? [y/n]  " yn
        case $yn in
            [Yy]* ) break;;
            [Nn]* ) exit 0;  break;;
            * ) echo "Please answer y or n.";;
        esac
    done
}


function cleanExamples(){
    #
    for file in $files; do
        file=$pathToExamples/$file
        for f in $(echo $file); do
            if [ -f $f ] || [ -d $f ]; then
                echo "${indent}rm -rf $f"
                # rm -rf $f
            fi
        done
    done
}

############################### program ###############################

lsine=true ; ldiam=true
checkArguments $@
echo "Cleaning Examples Folders"
if ! lsine; then
    echo "${indent}Skipping over Examples/Sine-Wave (warning not-implemented!!)" #TODO
fi
if ! ldiam; then
    echo "${indent}Skipping over Examples/NV-Diamond (warning not-implemented!!)" #TODO
fi
confirmRemoval
cleanExamples
echo "Done! :)"

