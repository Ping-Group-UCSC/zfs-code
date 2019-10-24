#!/usr/bin/gnuplot

set term postscript eps color 'Helvetica,20'

set output 'fft-vs-con_1.eps'
set key t r vertical
set xrange [0-10:1357+10]
set yrange [-0.5-0.2:2+0.2]
set xlabel '(G_x,G_y,G_z)'
set ylabel 'f_1(G_x,G_y,G_z)'
p \
'zfs.dump/f1_G.txt' u :(-$1) w lp ls 5 lc rgb '#0000FF' lw 3 ps 1.5 t 'con', \
'zfs.dump/fft/f1_G.txt' u :1     w lp ls 7 lc rgb '#FF0000' lw 2 ps 1.0 t 'fft'
unset xlabel ; unset ylabel


set output 'fft-vs-con_2.eps'
set key t r vertical
set xrange [0-10:1357+10]
set yrange [-0.5-0.2:2+0.2]
set xlabel '(G_x,G_y,G_z)'
set ylabel 'f_1(G_x,G_y,G_z)'
p \
'zfs.dump/f2_G.txt' u :(-$1) w lp ls 5 lc rgb '#0000FF' lw 3 ps 1.5 t 'con', \
'zfs.dump/fft/f2_G.txt' u :1     w lp ls 7 lc rgb '#FF0000' lw 2 ps 1.0 t 'fft'
unset xlabel ; unset ylabel


set output 'fft-vs-con_3.eps'
set key t r vertical
set xrange [0-10:1357+10]
set yrange [-0.5-0.2:2+0.2]
set xlabel '(G_x,G_y,G_z)'
set ylabel 'f_1(G_x,G_y,G_z)'
p \
'zfs.dump/f3_G.txt' u :(-$1) w lp ls 5 lc rgb '#0000FF' lw 3 ps 1.5 t 'con', \
'zfs.dump/fft/f3_G.txt' u :1     w lp ls 7 lc rgb '#FF0000' lw 2 ps 1.0 t 'fft'
unset xlabel ; unset ylabel


# set output 'fft-vs-con_small.eps'
# set xrange [1:260]
# set yrange [-0.5-0.1:0.5+0.1]
# unset key
# p \
# 'zfs.dump/f1_G.txt' u :(-$1) w lp ls 5 lc rgb '#0000FF' lw 3 ps 1.5 t 'con', \
# 'zfs.dump/fft/f1_G.txt' u :1     w lp ls 7 lc rgb '#FF0000' lw 2 ps 1.0 t 'fft'
