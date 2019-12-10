#!/usr/bin/env bash

cellfile=$1
if [ ! -f "$cellfile" ] ; then echo "Error: file '$1' does not exist" ; exit 1 ; fi

grep "omega=" "$cellfile" | awk '{print $3}' | sed -e 's/\"/ /g' | awk '{print $2}' # > $outfile
for opt in 'a' 'b' ; do
    for i in $(seq 1 3); do 
        grep "<${opt}${i} " "$cellfile" | sed -e 's/\"/ /g' | awk '{print $3, $4, $5}' # >> $outfile
    done
done
