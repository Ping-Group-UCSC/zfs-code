# Makefile for Basic

include ../../make.inc

basic_objects = \
	convtime.o \
	indexmod.o \
	intro_outro.o \
	params.o \
	printmod.o \
	readmod.o \
	writemod.o


# main target
all: $(basic_objects)


# sub targets
convtime.o: convtime.f90
	$(FC) -c convtime.f90 $(flags)

indexmod.o: indexmod.f90
	$(FC) -c indexmod.f90 $(flags)

intro_outro.o: intro_outro.f90
	$(FC) -c intro_outro.f90 $(flags)

params.o: params.f90
	$(FC) -c params.f90 $(flags)

printmod.o: params.o printmod.f90
	$(FC) -c printmod.f90 $(flags)

readmod.o: params.o readmod.f90
	$(FC) -c readmod.f90 $(flags)

writemod.o: params.o writemod.f90
	$(FC) -c writemod.f90 $(flags)


# clean
clean:
	rm -f *.o *.x *.mod
