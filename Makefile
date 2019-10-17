# Master makefile

all: basic zfs bin
	@printf "\n\nFinished building ZFS code! :)\n\n"

bin: zfs
	@printf "\nMaking bin\n"
	if [ ! -d bin ]; then mkdir bin ; fi
	cd bin ; ln -fs ../ZFS/zfs.x . ; cd ..
	@printf "Done making bin\n"

zfs: basic
	@printf "\nMaking zfs\n"
	cd ZFS ; make all ; cd ..
	@printf "Done making zfs\n"

basic:
	@printf "\nMaking basic\n"
	cd Basic ; make all ; cd ..
	@printf "Done making basic\n"


# clean

clean:
	@printf "\n"
	cd Basic ; make clean ; cd ..
	cd ZFS ; make clean ; cd ..
	if [ -d bin ]; then rm -rf bin ; fi
	if [ -f make.inc ]; then rm -f make.inc ; fi
	@printf "\n\nFinished Cleaning! :)\n\n"

