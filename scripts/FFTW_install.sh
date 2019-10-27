#!/bin/bash


############################## variables ##############################

description="Description: This script installs FFTW3\n"
usage="Usage: ./FFTW_install.sh [-h, --help] || [options]\n"
options="Options: \n\
    [-h, --help]            print help menu\n\
    [-f, --fftdir] fftdir   path to where a preinstalled fftw can be found (e.g. '/usr/local')\n\
    [-o, --over]            continue to download fftw regardless if it is found\n\
    [-s, --skip]            skip 'make install' after downloading and making fftw\n\
    [-l, --local]           install fftw in local directory (default: ~/.fftw-<ver>)\n\
    [-i, --insdir] insdir   specify directory to install local fftw\n"
indent="    "
fftwfile="fftw3.f03"
lfftdir=false; lskip=false; llocal=false; lover=false
rundir=$PWD
scriptdir=$(dirname $0)
downloaddir=$(realpath "$scriptdir/..")

# for installation only:
fftwver="3.3.8"
fftwurl="http://www.fftw.org/fftw-${fftwver}.tar.gz"
fftwtar="fftw-${fftwver}.tar.gz"
fftwdir="fftw-${fftwver}"
fftw_install_commands="\
    cd $downloaddir | \
    wget $fftwurl | \
    tar -xzvf $fftwtar | \
    cd $fftwdir | \
    ./configure | \
    make -j 8 | \
    make install | \
    cd .. | \
    rm -f $fftwtar*"


############################## funcitons ##############################

function checkArguments(){
    # handles command line arguments
    while [ ! -z "$1" ]; do
        if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
            printf "$description\n$usage\n$options"
            exit 0
        elif [ "$1" == "-f" ] || [ "$1" == "--fftdir" ]; then
            if [ -d "$2" ]; then
                fftdir=$(realpath $2)
                shift ; shift
            else
                echo "Error: Directory '$2' does not exist"
                exit 1
            fi
        elif [ "$1" == "-o" ] || [ "$1" == "--over" ]; then
            lover=true
            shift
        elif [ "$1" == "-s" ] || [ "$1" == "--skip" ]; then
            lskip=true
            shift
        elif [ "$1" == "-l" ] || [ "$1" == "--local" ]; then
            llocal=true
            shift
            if [ -z $insdir ]; then
                insdir="$(realpath ~/.${fftwdir})"
            fi
        elif [ "$1" == "-i" ] || [ "$1" == "--insdir" ]; then
            llocal=true
            insdir=$(realpath $2)
            shift ; shift
        else
            echo "Error: Command line option '$1' is not recognized"
            exit 1
        fi
    done
}


function checkUserFFTW(){
    # locate fftw installation
    echo "${indent}Checking user pvodided FFTW ... $fftdir"
    if [ -d "$fftdir/include" ] && [ -f "$fftdir/include/$fftwfile" ] && [ -d "$fftdir/lib" ]; then
        lfftdir=true
    fi
    if $lfftdir; then
        echo "${indent}FFTW provided is valid ... yes"
    else
        echo "${indent}FFTW provided is valid ... no"
        echo "Error: Invalid fftw directory provided."
        exit 1
    fi
}


function locateFFTW(){
    # check user provided fftw
    for fftdir in $(dirname $(locate fftw | grep include | grep "$fftwfile")); do 
        fftdir=$(realpath $fftdir | rev | sed -e 's/edulcni\///' | rev)
        if [ -d "$fftdir/lib" ]; then
            lfftdir=true
            break
        fi
    done
    if $lfftdir; then
        echo "${indent}FFTW found ... $fftdir"
    else
        echo "${indent}FFTW not found or version is not supported."
    fi
}


function installFFTW(){
    # install FFTW from web
    while true; do
        read -p "${indent}Do you wish to install fftw-${fftwver}? [y/n]  " yn
        case $yn in
            [Yy]* ) installFFTWInnner; break;;
            [Nn]* ) echo "${indent}Skipping installation.";  break;;
            * ) echo "Please answer y or n.";;
        esac
    done
}


function installFFTWInnner(){
    # iterate through install commands defined above
    num_commands=$(echo "$(echo "$fftw_install_commands" | grep -o "|" | wc -l)+1" | bc -l)
    for (( i=1; i<=$num_commands; i++)); do
        fftw_install_command=$(echo "$fftw_install_commands" | awk -v i=$i -F "|" '{print $i}')
        if $(echo "$fftw_install_command" | grep -q "\./configure"); then
            if $llocal ; then
                fftw_install_command="$fftw_install_command --prefix $insdir"
            fi
        elif $(echo "$fftw_install_command" | grep -q "make install"); then
            if $lskip ; then
                echo "${indent}Skipping make install"
                continue
            fi
            if [ "$(id -u)" -ne 0 ] && ! $llocal ; then
                printf "\nWarning!!!!   User Does not have root priveleges and did not specify local build.\n\n"
                echo "${indent}Skipping make install"
                continue
            fi
        fi
        echo $fftw_install_command
        if ! $fftw_install_command ; then
            echo "Error: In installFFTWInnner, could not install fftw."
            echo "Exiting $downloaddir"
            cd $rundir
            exit 1
        fi
    done
    cd $rundir
}

############################### program ###############################

checkArguments $@
echo "Searching for FFTW3 and installing version ${fftwver} if FFTW3 not found"
if [ ! -z $fftdir ]; then
    checkUserFFTW
else
    locateFFTW
fi
if ! $lfftdir || $lover ; then
    echo "${indent}Installing FFTW."
    installFFTW
else
    echo "${indent}Skipping installation."
fi
echo "Done! :)"

