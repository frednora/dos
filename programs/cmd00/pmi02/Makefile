# Compiling Gramado Boot Loader
# BL.BIN
# 2018 - Created by Fred Nora.
#      - Adapted from Matheus Castello's script.
# todo:
# The goal here is to create a 64bit boot loader.
# The will loader a 64bit kernel image.

VERSION = 1
PATCHLEVEL = 0
SUBLEVEL = 0
EXTRAVERSION = 
NAME = PMI02

# Make variables (CC, etc...)
AS	= as
LD	= ld
CC	= gcc
AR	= ar
MAKE	= make
NASM	= nasm
OBJCOPY	= objcopy
OBJDUMP	= objdump
LEX	= flex
YACC	= bison
PERL	= perl
PYTHON	= python
PYTHON2	= python2
PYTHON3	= python3
RUBY	= ruby

# We do not need these flags. 
CFLAGS = -m32 \
	--std=gnu89 \
	-nodefaultlibs \
	-nostdinc \
	-nostdlib \
	-static \
	-fgnu89-inline \
	-ffreestanding \
	-fno-builtin \
	-fno-pie \
	-no-pie \
	-fleading-underscore \
	-fno-stack-protector \
	-s

# Objects 
myObjects = head.o main.o globals.o \
loader.o init.o ports.o x86.o \
stdio.o stdlib.o string.o \
keyboard.o pci.o hdd.o ide.o storage.o timer.o \
pages.o \
heap.o \
procedure.o \
fs.o \
shell.o \
r_render.o \
abort.o \
faults.o    


all-bl: bl-x86 link-x86 finalize clean

bl-x86:

# Head
	$(NASM)  -I x86/  x86/head.s -f elf -o head.o
# main
	$(CC) -c main.c -I include/ $(CFLAGS) -o main.o 
	$(CC) -c globals.c -I include/ $(CFLAGS) -o globals.o 
# init
	$(CC) -c init.c -I include/ $(CFLAGS) -o init.o 
# libc
	$(CC) -c stdio.c   -I include/ $(CFLAGS) -o stdio.o
	$(CC) -c string.c  -I include/ $(CFLAGS) -o string.o
	$(CC) -c stdlib.c  -I include/ $(CFLAGS) -o stdlib.o
#x86
	$(CC) -c x86/faults.c  -I include/ $(CFLAGS)  -o faults.o
	$(CC) -c x86/x86.c     -I include/ $(CFLAGS)  -o x86.o
	$(CC) -c x86/ports.c   -I include/ $(CFLAGS)  -o ports.o 
# mm
	$(CC) -c pages.c   -I include/ $(CFLAGS) -o pages.o
	$(CC) -c heap.c    -I include/ $(CFLAGS) -o heap.o
#Sys
	$(CC) -c procedure.c -I include/ $(CFLAGS) -o procedure.o
	$(CC) -c abort.c     -I include/ $(CFLAGS) -o abort.o
#Shell
	$(CC) -c shell.c -I include/ $(CFLAGS) -o shell.o
#fs
	$(CC) -c fs/fs.c     -I include/ $(CFLAGS) -o fs.o
	$(CC) -c fs/loader.c -I include/ $(CFLAGS) -o loader.o

	$(CC) -c render/r_render.c  -I include/ $(CFLAGS) -o r_render.o

	$(CC) -c pci.c  -I include/ $(CFLAGS)  -o pci.o
# dd
	$(CC) -c dd/keyboard.c  -I include/ $(CFLAGS)  -o keyboard.o
	$(CC) -c dd/timer.c     -I include/ $(CFLAGS)  -o timer.o
	$(CC) -c dd/hdd.c       -I include/ $(CFLAGS)  -o hdd.o
	$(CC) -c dd/ide.c       -I include/ $(CFLAGS)  -o ide.o
	$(CC) -c dd/storage.c   -I include/ $(CFLAGS)  -o storage.o

link-x86:
#todo:
# Change to ELF.
	$(LD) -m i386pe -T x86/link.ld -o PMI02.BIN $(myObjects)    
finalize:
	cp PMI02.BIN bin/
clean:
	find . -type f -name '*.o' -delete
	-rm PMI02.BIN
clean2:
	-rm PMI02.BIN
	
