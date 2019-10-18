#!/bin/bash


############################## variables ##############################

noInputMessage="Error: Missing input. \
\n\
\n  Usage: \
\n    $ ./conv_export.sh <QE prefix> <QE outdir> <path to ZFS binary (optional)> \
\n  Or (for more info): \
\n    $ ./conv_export.sh [-h] | [--help]"
helpMessage="  This helper script is used to create input for the ZFS code from a QE output. \
\n\
\n  Usage: \
\n    $ ./conv_export.sh <QE prefix> <QE outdir> <path to ZFS binary (optional)> \
\n  Example: \
\n    $ ./conv_export.sh di temp \
\n\
\n  What this script does: \
\n    1. run pw_export.x (if it has not been already ran) \
\n    2. convert pw_export.x to multiple text files \
\n    3. run fortran code to unformat files (not done in current version)\
\n\
\n  NOTE! <path to ZFS binary> is obsolete in current version"
indent="  "
indent2=$(echo "$indent$indent")


############################## funcitons ##############################

function checkArguments(){
    # handles command line arguments
    if [ -z "$1" ]; then
        echo $noInputMessage
        exit 1
    elif [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
        echo $helpMessage
        exit 0
    fi

    # TODO handle options
    # while [ ! -z "$1" ]; do
    #     if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    #         echo $helpMessage
    #         exit 0
    #     elif [ "$1" == "-f" ] || [ "$1" == "--fftdir" ]; then
    #         # handle other options
    #     else
    #         echo "Error: Command line option '$1' is not recognized"
    #         exit 1
    #     fi
    # done

    # TODO (these are the options I want to implement)
    # add the below as options [-q] | [--qedir] and [-z] | [--zfsdir]
    # qedir=$3        # qe binary directory (optional)
    # if [ ! -z $qedir ]; then
    #     echo "    qedir = '$qedir'"
    # fi
    # zfsdir=$4        # zfs binary directory (optional)
    # if [ ! -z $zfsdir ]; then
    #     echo "    zfsdir = '$zfsdir'"
    # fi
}


function run_txt_2_bin() {
    printf "\n${indent}Runnning txt_2_bin.x\n"

    if [ "$nbnd1" -eq "$nbnd2" ]; then
        nbnd=$nbnd1
    elif [ "$nbnd1" -gt "$nbnd2" ]; then
        nbnd=$nbnd2
        echo "Warning nbnd1 > nbnd2 : $nbnd1 > $nbnd2"
    else
        nbnd=$nbnd1
        echo "Warning nbnd1 < nbnd2 : $nbnd1 < $nbnd2"
    fi

    echo "${indent2}making txt_2_bin.in"
    cat > txt_2_bin.in << EOF
My txt_2_bin calculation
export_dir = "$1"
nbnd = $nbnd
EOF

    if [ -z "$2" ]; then
        # zfsdir not set
        t2b_command="txt_2_bin.x"
    else
        # TODO add this functionality
        t2b_command="$2/txt_2_bin.x"
    fi
    echo "    Running txt_2_bin.x as $t2b_command"

    if ! type $t2b_command > /dev/null; then
        echo "Error: Command '$t2b_command' does not exist"
        exit 1
    fi
    echo "    $t2b_command -i txt_2_bin.in > txt_2_bin.out" 
    # $t2b_command -i txt_2_bin.in > txt_2_bin.out
    if ! $t2b_command -i txt_2_bin.in > txt_2_bin.out 2> txt_2_bin.out.err ; then
        echo "Error: txt_2_bin.x raised error"
        exit 1
    fi

}


function run_pw_export() {

    printf "\n  Runnning pw_export.x\n"

    echo "    making pw_export.in"
    cat > pw_export.in << EOF
&inputpp
    prefix='$1'
    outdir='$2'
    ascii=.true.,
/
EOF

    if [ -z "$3" ]; then
        # qedir not set
        pwe_command="pw_export.x"
    else
        pwe_command="$3/pw_export.x"
        
    fi
    echo "    Running pw_export.x as $pwe_command"

    if ! type $pwe_command > /dev/null; then
        echo "Error: Command '$pwe_command' does not exist"
        exit 1
    fi
    echo "    $pwe_command < pw_export.in > pw_export.out" 
    if ! pw_export.x < pw_export.in > pw_export.out 2> pw_export.out.err ; then
        echo "Error: pw_export.x raised error"
        exit 1
    fi

}


function check_export_dir(){

    printf "\n  Checking files under '$1'\n"

    gfile="$1/grid.1"
    w1file="$1/wfc.1"
    w2file="$1/wfc.2"
    for I in $gfile $w1file $w2file; do
        if [ ! -f "$I" ];then
            echo "Error: $I does not exist"
            exit 1
        fi
        echo "    '$I' found"
    done

}


function conv_qe_to_txt() {

    printf "\n  Reading pw_export.x output from '$1'\n"

    dir="Converted_Export"
    if [ ! -d "$dir" ]; then
        mkdir $dir
    else
        # skip this step instead? TODO
        echo "Error: '$dir' already exists please delete or rename it"
        exit 1
    fi
    echo "    Output to be rewritten to text files under directory '$dir'"


    npw=`grep -B 1 "</index>" $gfile | head -1`
    echo "    npw = $npw"

    outfile="$dir/grid.txt"
    grep -A $npw "<grid" $gfile | tail -n $npw > $outfile
    # echo "      $outfile written"

    nbnd1=`grep "nbnd=" $w1file | awk '{print $3}' | awk -F '"' '{print $2}'`
    echo "    Working on spin up wfc  $nbnd1"
    for i in $(seq $nbnd1); do 
        search="<Wfc.${i}"
        outfile="$dir/wfc1_${i}.txt"
        grep -A $npw $search $w1file | tail -n $npw > $outfile
        # echo "      $outfile written    $i/$nbnd1"
    done

    nbnd2=`grep "nbnd=" $w2file | awk '{print $3}' | awk -F '"' '{print $2}'`
    echo "    Working on spin down wfc  $nbnd2"
    for i in $(seq $nbnd2); do 
        search="<Wfc.${i}"
        outfile="$dir/wfc2_${i}.txt"
        grep -A $npw $search $w2file | tail -n $npw > $outfile
        # echo "      $outfile written    $i/$nbnd1"
    done
    
    echo "    Reformatting text files ..."
    for f in $dir/wfc*.txt; do
        sed -i -e 's/^/(/' -e 's/$/)/' $f
    done

}

############################### program ###############################
checkArguments $@
# correct input; begin
printf "\n${indent}Begin.\n\n"
echo "  Reading user input"
prefix=$1       # prefix of qe calculation
echo "    prefix = '$prefix'"
outdir=$(realpath $2)       # outdir of qe calculation
echo "    outdir = '$outdir'"


zfsdir=$3        # zfs binary directory (optional)
if [ ! -z $zfsdir ]; then
    echo "    zfsdir = '$zfsdir'"
fi


# check if export_dir exists
export_dir="$outdir/$prefix.export"
if [ -d "$export_dir" ]; then
    echo "  Found export directory: $export_dir"
    echo "    pw_export.x not reran"
else
    run_pw_export $prefix $outdir
    # run_pw_export $prefix $outdir $qedir # TODO
fi

# check contents of export_dir
check_export_dir $export_dir

# convert pw_export.x output to text files
conv_qe_to_txt $export_dir

# # convert text files to binary files TODO
# run_txt_2_bin $dir $zfsdir


printf "\n  End.\n\n"