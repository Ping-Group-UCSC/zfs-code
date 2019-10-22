# Master makefile

all: basic zfs bin check-config
	@printf "\n\nFinished building ZFS code! :)\n\n"

bin: zfs
	@printf "\nMaking bin\n"
	if [ ! -d bin ]; then mkdir bin ; fi
	cd bin ; ln -fs ../src/ZFS/zfs.x . ; cd ..
	@printf "Done making bin\n"

zfs: basic check-config
	@printf "\nMaking zfs\n"
	cd src/ZFS ; make all ; cd ../..
	@printf "Done making zfs\n"

basic: check-config
	@printf "\nMaking basic\n"
	cd src/Basic ; make all ; cd ../..
	@printf "Done making basic\n"

check-config:
	@if [ ! -f make.inc ]; then printf "\nError: Missing file 'make.inc'\n\
	Please run ./configure before continuing.\n\n"; exit 1 ; fi


# clean

clean:
	@printf "\n"
	cd src/Basic ; make clean ; cd ../..
	cd src/ZFS ; make clean ; cd ../..
	if [ -d bin ]; then rm -rf bin ; fi
	if [ -f make.inc ]; then rm -f make.inc ; fi
	@printf "\n\nFinished Cleaning! :)\n\n"

