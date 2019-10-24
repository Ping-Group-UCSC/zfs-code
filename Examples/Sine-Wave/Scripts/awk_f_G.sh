#!/bin/bash

dir="zfs.dump"

if [ ! -d $dir ]; then
    echo "Error: Directory '$dir' does not exist"
    exit 1
fi

for i in $(seq 3); do
    file="$dir/f${i}_G-og.txt"
    if [ ! -f $file ]; then
        echo "Error: Cannot locate file '$file'"
        exit 1
    fi
    echo "$file"
    awk 'sqrt($5^2) > 1e-10 {print $0}' $file
    echo
done
