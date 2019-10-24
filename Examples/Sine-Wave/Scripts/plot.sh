#!/bin/bash


############################## variables ##############################

dump_dir="zfs.dump"
description="Description: This script plots data from '${dump_dir}'.\n"
usage="Usage: ./Scripts/plot.sh [-h, --help] || [options]\n"
options="Options: \n\
    [-h, --help]            print help menu\n\
    [-w, --wfcr]            plot real space wfc\n\
    [-f, --funr]            plot real space convolution functions f(r)\n\
    [-b, --both]            plot both real space wfc and convolution functions f(r)\n"
indent="    "
patterns="^   ..   0   0|^    0  ..   0|^    0   0  .."
rundir="Scripts"


############################## funcitons ##############################

function checkArguments(){
    # handles command line arguments
    if [ ! -z "$2" ]; then
        echo "WARNING: script only supports one option. Ignoring all but first option"
    fi
    while [ ! -z "$1" ]; do
        if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
            printf "$description\n$usage\n$options"
            exit 0
        elif [ "$1" == "-w" ] || [ "$1" == "--wfcr" ]; then
            incfile="${rundir}/include-wfc_r.sh"
            break
        elif [ "$1" == "-f" ] || [ "$1" == "--funr" ]; then
            incfile="${rundir}/include-f_r.sh"
            break
        elif [ "$1" == "-fw" ] || [ "$1" == "-b" ] || [ "$1" == "--both" ]; then
            if [ ! -f $rundir/plot.sh ]; then
                echo "Error: File '$rundir/plot.sh' does not exist."
                exit 1
            fi
            $rundir/plot.sh -w
            $rundir/plot.sh -f
            exit 0
        fi
    done
}


function checkIncFile(){
    # check to see that plot option was chosen and include file exists 
    if [ -z $incfile ]; then
        echo "Error: No plot option given. Please use a valid option:"
        printf "$options"
        exit 1
    fi
    if [ ! -f $incfile ]; then
        echo "Error: The file '$incfile' does not exist."
        exit 1
    fi
    source $incfile
}


function fileNames(){
    # gelabel input and output file names
    for i in $(seq $nfile); do
        in=$(echo "$in $dump_dir/${type}${i}_r-og.txt")
        out=$(echo "$out ${type}${i}_r.eps")
    done
    # check input
    for fin in $in ; do
        if [ ! -f $fin ]; then
            echo "Error: File '$fin' does not exist."
            exit 1
        fi
    done
}


function plotData(){
    # plot data files (makes a call to runGnuplot)
    for i in $(seq $nfile); do
        fin=$(echo $in | awk -v i=$i '{print $i}')
        fout=$(echo $out | awk -v i=$i '{print $i}')
        echo "${indent}Reading data from ... '$fin'"
        echo "${indent}Plotting data to  ... '$fout'"
        tfiles=$(mktemp; mktemp; mktemp)
        for j in $(seq 3); do
            pattern=$(echo "$patterns" | awk -v j=$j -F "|" '{print $j}')
            tfile=$(echo $tfiles | awk -v j=$j '{print $j}')
            grep "$pattern" $fin > $tfile
        done
        label=$(echo $labels | awk -v i=$i -F "|" '{print $i}')
        function=$(echo $functions | awk -v i=$i -F "|" '{print $i}')
        fun_label=$(echo $fun_labels | awk -v i=$i -F "|" '{print $i}')
        runGnuplot $tfiles $function
        rm $tfiles
    done
}


function runGnuplot(){
    # run gnuplot to generate plots
    gnuplot -persist <<-EOFMarker
        set term postscript eps color "Helvetica,20"
        set output '$fout'
        set xrange [0:1]
        set xtics 0.25
        set key horizontal t l width 3 spacing 1.5 font ',18'
        set yrange $yrange
        set ytics 1
        # set label 1 '${fun_label}(x,y,z) = ${label}' at 0.05,-2.1
        set xlabel '(x, y, z)'
        set ylabel '${fun_label}(x,y,z)'
        tpi=2*pi
        wt=3
        p \
        $4 lw wt lc 1 t '${fun_label}(x,0,0)', \
        "$1" u (\$1/13):5 w p ps 2 lw wt lc 1 t 'codex', \
        $5 lw wt lc 2 t '${fun_label}(0,y,0)', \
        "$2" u (\$2/13):5 w p ps 2 lw wt lc 2 t 'codey', \
        $6 lw wt lc 3 t '${fun_label}(0,0,z)', \
        "$3" u (\$3/13):5 w p ps 2 lw wt lc 3 t 'codez'
EOFMarker
}

############################### program ###############################
checkArguments $@
checkIncFile
echo "Plotting data from '$dump_dir'"
fileNames
plotData
echo "Done! :)"
