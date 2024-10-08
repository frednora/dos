# fn-dos 16bit.
# Compiling on gcc 11.4.0
# Linking on ld 2.38


BASE = your/base

BOOT_DIR = source/bootload
KERNEL_DIR = source

# Let's import the 32bit pmi.
# Levels
#DEP_L4  = ../pmi
#DEP_L3  = ../pmi
#DEP_L2  = ../pmi
#DEP_L1  = ../pmi


# Make variables (CC, etc...)
AS      = as
LD      = ld
CC      = gcc
AR      = ar
MAKE    = make
NASM    = nasm
PYTHON  = python
PYTHON2 = python2
PYTHON3 = python3

#
# Config
#

# verbose
# Quiet compilation or not.
ifndef CONFIG_USE_VERBOSE
	CONFIG_USE_VERBOSE = 1
endif

ifeq ($(CONFIG_USE_VERBOSE),1)
# Not silent. It prints the commands.
	Q =
else
# silent
	Q = @
endif

# --------------------------------------
# == Start ====
# build: User command.
PHONY := all
all:  \
build-gramado-os \
copy-extras \
/mnt/M86VD \
vhd-mount \
vhd-copy-files \
vhd-unmount \
clean    

# Giving permitions to run.
	chmod 755 ./run
	chmod 755 ./runnokvm

# tests
	chmod 755 ./runt1
	chmod 755 ./runt2
	@echo "Done?"

# --------------------------------------
# build: Developer comand 1.
# install
# Build the images and put them all into $(BASE)/ folder.
PHONY := install
install: do_install
do_install: \
build-gramado-os  


# --------------------------------------
# build: Developer comand 2.
# image
# Copy all the files from $(BASE)/ to the VHD.
PHONY := image
image: do_image
do_image: \
/mnt/M86VD    \
vhd-mount          \
vhd-copy-files     \
vhd-unmount        \

# --------------------------------------
#::0
# ~ Step 0: gramado files.
PHONY := build-gramado-os  
build-gramado-os:     
	@echo ":: [] Building VHD, bootloaders and kernel image."
# options: 
# main.asm and main2.asm
# O mbr só consegue ler o root dir para pegar o BM.BIN
# See: stage1.asm
# O BM.BIN só consegue ler o root dir pra pegar o BL.BIN
# See: main.asm
# the kernel image
# O BL.BIN procura o kernel no diretorio GRAMADO/
# See: fs/loader.c

#----------------------------------
# (1) boot/

# Create the virtual disk 0.
	$(Q)$(NASM) diskimg/vd/fat/main.asm \
	-I diskimg/vd/fat/ \
	-o FNDOS.VHD 

# Create backup for MBR 0.
	$(Q)$(NASM) $(BOOT_DIR)/stage1.asm \
	-I $(BOOT_DIR)/ \
	-o BOOTLOAD.BIN
	cp BOOTLOAD.BIN  $(BASE)/

# bew kernel
# 16 bit kernel loader (KLDR.BIN)
	$(Q)$(MAKE) -C $(KERNEL_DIR)/ 
# Copy to the target folder.
	cp $(KERNEL_DIR)/bin/KERNEL.BIN  $(BASE)/


# ---------
# CMD00.BIN
	$(Q)$(MAKE) -C programs/cmd00/cmd00/ 
# Copy to the target folder.
	cp programs/cmd00/cmd00/bin/CMD00.BIN  $(BASE)/

# ---------
# CMD01.BIN
	$(Q)$(MAKE) -C programs/cmd01/cmd01/ 
# Copy to the target folder.
	cp programs/cmd01/cmd01/bin/CMD01.BIN  $(BASE)/
# APP00.COM
	$(Q)$(MAKE) -C programs/cmd01/app00/ 
# Copy to the target folder.
	cp programs/cmd01/app00/bin/APP00.COM  $(BASE)/

#----------------------------------
# () userland/


# Install BMPs from cali assets.
# Copy the assets/
# We can't survive without this one.
	cp your/assets/themes/theme01/*.BMP  $(BASE)/

	@echo "~build-gramado-os end?"

# --------------------------------------
# Let's add a bit of shame in the project.
PHONY := copy-extras
copy-extras:

	@echo "copy-extras"

# ------------------------
# LEVEL 4: (aurora/) 3D demos.
#	-cp $(DEP_L4)/bin/DEMO00.BIN  $(BASE)/
#

# ------------------------
# LEVEL 3: (browser/) browser.
# Teabox web browser

# ------------------------
# LEVEL 2: (commands/)  Posix comands.
#	-cp $(DEP_L2)/base/bin/CAT.BIN       $(BASE)/

# ------------------------
# LEVEL 1: (de/) Display servers and applications.

	@echo "~ copy-extras"

# --------------------------------------
#::2
# Step 2: /mnt/M86VD  - Creating the directory to mount the VHD.
/mnt/M86VD:
	@echo "========================="
	@echo "Build: Creating the directory to mount the VHD ..."
	sudo mkdir /mnt/M86VD

# --------------------------------------
#::3
# ~ Step 3: vhd-mount - Mounting the VHD.
vhd-mount:
	@echo "=========================="
	@echo "Build: Mounting the VHD ..."
	-sudo umount /mnt/M86VD
	sudo mount -t vfat -o loop,offset=32256 FNDOS.VHD /mnt/M86VD/

# --------------------------------------
#::4
# ~ Step 4 vhd-copy-files - Copying files into the mounted VHD.
# Copying the $(BASE)/ folder into the mounted VHD.
vhd-copy-files:
	@echo "========================="
	@echo "Build: Copying files into the mounted VHD ..."
	# Copy $(BASE)/
	# sends everything from disk/ to root.
	sudo cp -r $(BASE)/*  /mnt/M86VD

# --------------------------------------
#:::5
# ~ Step 5 vhd-unmount  - Unmounting the VHD.
vhd-unmount:
	@echo "======================"
	@echo "Build: Unmounting the VHD ..."
	sudo umount /mnt/M86VD

# --------------------------------------
# Run on qemu using kvm.
PHONY := run
run: do_run
do_run:
	sh ./run

# --------------------------------------
# Run on qemu with no kvm.
PHONY := runnokvm
runnokvm: do_runnokvm
do_runnokvm:
	sh ./runnokvm


# --------------------------------------
# Basic clean.
clean:
	-rm *.o
	-rm *.BIN
	-rm kernel/*.o
	-rm kernel/*.BIN
	@echo "~clean"

# --------------------------------------
# Clean up all the mess.
clean-all: clean

	-rm *.o
	-rm *.BIN
	-rm *.VHD
	-rm *.ISO

# 16 programs and 32bit pmi.
	-rm programs/bin/*.o
	-rm programs/bin/*.BIN
	#-rm programs/cmd00/bin/*.BIN
	#-rm programs/cmd01/bin/*.BIN

	-rm programs/cmd00/cmd00/bin/*.BIN
	#-rm programs/cmd01/cmd01/bin/*.BIN
	#...

# 16bit kernel
	-rm $(KERNEL_DIR)/bin/*.o
	-rm $(KERNEL_DIR)/bin/*.BIN

# ==================
# Clear the disk cache
	-rm -rf $(BASE)/*.BIN 
	-rm -rf $(BASE)/*.BMP
	-rm -rf $(BASE)/EFI/BOOT/*.EFI 
	-rm -rf $(BASE)/GRAMADO/*.BIN 
	-rm -rf $(BASE)/PROGRAMS/*.BIN 
	-rm -rf $(BASE)/USERS/*.BIN 

	@echo "~clean-all"

# --------------------------------------
# Usage instructions.
usage:
	@echo "Building everything:"
	@echo "make all"
	@echo "Clear the mess to restart:"
	@echo "make clean-all"
	@echo "Testing on qemu:"
	@echo "./run"
	@echo "./runnokvm"

# --------------------------------------
# Danger zone!
# This is gonna copy th image into the real HD.
# My host is running on sdb and i copy the image into sda.
# It is because the sda is in primary master IDE.
# Gramado has been tested on sda
# and the Fred's Linux host machine is on sdb.
danger-install-sda:
	sudo dd if=./FNDOS.VHD of=/dev/sda
danger-install-sdb:
	sudo dd if=./FNDOS.VHD of=/dev/sdb

qemu-instance:
	-cp ./FNDOS.VHD ./QEMU.VHD 
#xxx-instance:
#	-cp ./FNDOS.VHD ./XXX.VHD 


# End

