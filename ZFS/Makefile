# Makefile for ZFS

include ../make.inc

zfs_objects = \
	input.o \
	fftwmod.o \
	fg_calc.o \
	loop_var.o \
	mpi_var.o \
    main_inner.o \
	main_mpi.o \
	zfs_calc.o

flags_zfs = -I../Basic


# main target
all: main.o
	$(FC) ../Basic/*.o ./*.o -o zfs.x $(flags) $(flags_zfs)

main.o: $(zfs_objects) main.f90
	$(FC) -c main.f90 $(flags) $(flags_zfs)


# sub targets
input.o: input.f90
	$(FC) -c input.f90 $(flags) $(flags_zfs)

fftwmod.o: fftwmod.f90
	$(FC) -c fftwmod.f90 $(flags) $(flags_zfs)

fg_calc.o: fg_calc.f90
	$(FC) -c fg_calc.f90 $(flags) $(flags_zfs)

loop_var.o: loop_var.f90
	$(FC) -c loop_var.f90 $(flags) $(flags_zfs)

mpi_var.o: mpi_var.f90
	$(FC) -c mpi_var.f90 $(flags) $(flags_zfs)

main_inner.o: fg_calc.o zfs_calc.o main_inner.f90
	$(FC) -c main_inner.f90 $(flags) $(flags_zfs)

main_mpi.o: main_inner.o main_mpi.f90
	$(FC) -c main_mpi.f90 $(flags) $(flags_zfs)

zfs_calc.o: zfs_calc.f90
	$(FC) -c zfs_calc.f90 $(flags) $(flags_zfs)


# clean
clean:
	rm -f *.o *.x *.mod
