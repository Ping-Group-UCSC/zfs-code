#!/bin/bash

type="wfc"
nfile=2
labels="\
sin(1x) + sin(3x) + sin(2y) + sin(1z)|\
sin(2x) + sin(1y) + sin(2y)"
functions="\
sin(1*tpi*x)+sin(3*tpi*x) sin(2*tpi*x) sin(1*tpi*x)|\
sin(2*tpi*x) sin(1*tpi*x)+sin(2*tpi*x) 0"
fun_labels="{/Symbol y}_1|{/Symbol y}_2"
yrange="[-2.5:2.5]"
