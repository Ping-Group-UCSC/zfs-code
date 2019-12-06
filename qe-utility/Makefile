# Auto-generated Makefile from configure -- interfaces QE

# pw binary
pwbin = /Users/tjsmart/Programs/qe-6.1.0

# include pw make.inc
include $(pwbin)/make.inc

# modify F90FLAGS
F90FLAGS = $(FFLAGS) -x f95-cpp-input $(FDFLAGS) $(MODFLAGS)

# location of needed modules and included files (if any)
MODFLAGS= $(MOD_FLAG)$(pwbin)/iotk/src $(MOD_FLAG)$(pwbin)/Modules \
        $(MOD_FLAG)$(pwbin)/FFTXlib $(MOD_FLAG)$(pwbin)/LAXlib $(MOD_FLAG)$(pwbin)/PW/src

# location of objects
PWOBJS = $(pwbin)/PW/src/libpw.a
PPOBJS = $(pwbin)/PP/src/libpp.a
QEOBJS = $(pwbin)/Modules/libqemod.a $(pwbin)/FFTXlib/libqefft.a $(pwbin)/LAXlib/libqela.a
MODULES = $(PPOBJS) $(PWOBJS) $(QEOBJS)

# rules
all : zfs.x

zfs.x : zfs.o
	$(LD) $(LDFLAGS) -o $@ zfs.o $(MODULES) $(LIBOBJS) $(LIBS)

clean :
	- rm -f *.x *.o

