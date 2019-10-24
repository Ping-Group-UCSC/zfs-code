#!/bin/bash

type="f"
nfile=3
labels="\
[sin(1x) + sin(3x) + sin(2y) + sin(1z)]^2|\
[sin(2x) + sin(1y) + sin(2y)]^2|\
[sin(1x) + sin(3x) + sin(2y) + sin(1z)]*[sin(2x) + sin(1y) + sin(2y)]"
functions="\
sin(1*tpi*x)**2+2*sin(1*tpi*x)*sin(3*tpi*x)+sin(3*tpi*x)**2 sin(2*tpi*x)**2 sin(1*tpi*x)**2|\
sin(2*tpi*x)**2 sin(1*tpi*x)**2+2*sin(1*tpi*x)*sin(2*tpi*x)+sin(2*tpi*x)**2 0|\
sin(1*tpi*x)*sin(2*tpi*x)+sin(2*tpi*x)*sin(3*tpi*x) sin(1*tpi*x)*sin(2*tpi*x)+sin(2*tpi*x)**2 0"
fun_labels="f_1|f_2|f_3"
yrange="[-2.2:4.2]"
