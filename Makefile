# Automatically generate lists of sources using wildcared.
C_SOURCES = $(wildcard kernel/*.c drivers/*.c)
HEADERS = $(wildcard kernel/*.h drivers/*.h)

# Todo: make sources depend on header files.

# Convert *.c filenames to *.o as a list of object files to build.
OBJJ = ${C_SOURCES:.c=.o}

# Clean, build and run.
all: clean os-image run

# Removes all built files.
clean:
	# Save 'minimal.bin', our one handwritten binary.
	rm boot/*.bin
	rm drivers/*.bin
	rm example/*.bin
	rm kernel/*.bin
	rm -f os-image

# --------------------------------------------------------------------------------------------------
# Examples and learning

# Handwritten binary of a trivially valid boot sector.
minimal_example: 
	cd example && \
	cp minimal minimal.bin
	qemu-system-x86_64 -drive file=minimal_example.bin,format=raw -net none

# An empty boot sector which loops forever.
boot_sector:
	cd example && \
	nasm boot_sector.asm -f bin -o boot_sector.bin && \
	qemu-system-x86_64 -drive file=boot_sector.bin,format=raw -net none

# A simple boot sector that demonstrates addressing.
find_the_byte:
	cd example && \
	nasm find_the_byte.asm -f bin -o find_the_byte.bin && \
	qemu-system-x86_64 -drive file=find_the_byte.bin,format=raw -net none

# Printing a message letter-by-letter using BIOS interrupts.
hello_simple:
	cd example && \
	nasm hello_simple.asm -f bin -o hello_simple.bin && \
	qemu-system-x86_64 -drive file=hello_simple.bin,format=raw -net none

# Printing a message by calling a `print_string` routine.
hello_advanced:
	cd example && \
	nasm hello_advanced.asm -f bin -o hello_advanced.bin && \
	qemu-system-x86_64 -drive file=hello_advanced.bin,format=raw -net none

# Real mode examples:
# - stack_example: a simple boot sector that demonstrates the stack.
# - print_hex_example: runs a routine that prints out the hex value 0x1fb6.
# - segments_example: an example showing some aspects of segment offsetting.
# - disk_load_example: an example loading magic numbers written to disk.
%_example:
	cd example && \
	nasm $*_example.asm -f bin -o $*_example.bin && \
	qemu-system-x86_64 -drive file=$*_example.bin,format=raw -net none

# A boot sector that switches from real to protected mode.
boot_to_pm:
	cd example && \
	nasm boot_to_pm.asm -f bin -o boot_to_pm.bin && \
	qemu-system-x86_64 -drive file=boot_to_pm.bin,format=raw -net none

# Compiler/disassembly examples:
# - basic_disassemble: prints out disassembly of a trivial function call.
# - local_var_disassemble: shows disassembly of allocating an integer.
# - calling_disassemble: disassembles the relationship between a function and its caller.
# - string_disassemble: shows storing a string as a pointer to null-terminated char array.
%_disassemble:
	cd example && \
    x86_64-elf-gcc -m32 -ffreestanding -c $*_disassemble.c -o $*_disassemble.o && \
    x86_64-elf-ld -melf_i386 -o $*_disassemble.bin -Ttext 0x0 --oformat binary $*_disassemble.o && \
    ndisasm -b 32 $*_disassemble.bin

# Kernel code --------------------------------------------------------------------------------------

# Compile object file for entering the kernel.
kernel/enter_kernel.o:
	cd kernel && \
	nasm enter_kernel.asm -f elf -o enter_kernel.o

# Create kernel binary file by prepending kernel main code with kernel entry code.
bin/kernel.bin: kernel/enter_kernel.o
	cd kernel && \
	x86_64-elf-gcc -m32 -ffreestanding -c kernel.c -o kernel.o && \
	x86_64-elf-ld -melf_i386 -o kernel.bin -Ttext 0x1000 --oformat binary enter_kernel.o kernel.o

# Compile boot sector for loading kernel code.
bin/load_kernel.bin:
	cd boot && \
	nasm load_kernel.asm -f bin -o load_kernel.bin

# Create executable image by prepending kernel binary with boot sector.
os-image: bin/kernel.bin bin/load_kernel.bin
	cat boot/load_kernel.bin kernel/kernel.bin > os-image

# Generic rule for building `anyfile.o` from `anyfile.c`.
%.o: %.c
	x86_64-elf-gcc -m32 -ffreestanding -c $< -o $@

# --------------------------------------------------------------------------------------------------

# Run operating system on emulated x86.
run: os-image
	qemu-system-x86_64 -drive file=os-image,format=raw -net none
