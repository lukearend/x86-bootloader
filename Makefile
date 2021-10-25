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
	rm -f boot/*.bin
	rm -f drivers/*.o
	rm -f example/*.bin example/*.o
	rm -f kernel/*.bin kernel/*.o
	rm -f os-image

# --------------------------------------------------------------------------------------------------
# Examples and learning

# A hand-written binary of a trivially valid boot sector.
minimal_example:
	qemu-system-x86_64 -drive file=example/minimal,format=raw -net none

# An empty boot sector which loops forever.
boot_sector: example/boot_sector.bin
	qemu-system-x86_64 -drive file=$<,format=raw -net none

# A simple boot sector that demonstrates addressing.
find_the_byte: example/find_the_byte.bin
	qemu-system-x86_64 -drive file=$<,format=raw -net none

# Printing a message letter-by-letter using BIOS interrupts.
hello_simple: example/hello_simple.bin
	qemu-system-x86_64 -drive file=$<,format=raw -net none

# Printing a message by calling a `print_string` routine.
hello_advanced: example/hello_advanced.bin
	qemu-system-x86_64 -drive file=$<,format=raw -net none

# Other real mode examples:
# - stack_example: a simple boot sector that demonstrates the stack.
# - print_hex_example: runs a routine that prints out the hex value 0x1fb6.
# - segments_example: an example showing some aspects of segment offsetting.
# - disk_load_example: an example loading magic numbers written to disk.
%_example: example/%_example.bin
	qemu-system-x86_64 -drive file=$<,format=raw -net none

# A boot sector that switches from real to protected mode.
boot_to_pm: example/boot_to_pm.bin
	qemu-system-x86_64 -drive file=$<,format=raw -net none

# Compiler/disassembly examples:
# - basic_disassemble: prints out disassembly of a trivial function call.
# - local_var_disassemble: shows disassembly of allocating an integer.
# - calling_disassemble: disassembles the relationship between a function and its caller.
# - string_disassemble: shows storing a string as a pointer to null-terminated char array.
%_disassemble: example/%_disassemble.bin
	ndisasm -b 32 $<

example/%_disassemble.bin: example/%_disassemble.o
	x86_64-elf-ld -melf_i386 -o $@ -Ttext 0x0 --oformat binary $<

# Kernel code --------------------------------------------------------------------------------------

# Create kernel binary linking kernel entry to kernel main code.
kernel/kernel.bin: kernel/enter_kernel.o kernel/kernel.o
	x86_64-elf-ld -melf_i386 -o $@ -Ttext 0x1000 --oformat binary $^

# Create executable image by prepending kernel binary with boot sector.
os-image: boot/load_kernel.bin kernel/kernel.bin
	cat $^ > $@

# Compile assemblie sources into binary.
%.bin: %.asm
	nasm $< -f bin -o $@

# Assemble the kernel entry to an object file.
%.o: %.asm
	nasm $< -f elf -o $@

# Compile C sources into object files.
%.o: %.c
	x86_64-elf-gcc -m32 -ffreestanding -c $< -o $@

# --------------------------------------------------------------------------------------------------

# Run operating system on emulated x86.
run: os-image
	qemu-system-x86_64 -drive file=$<,format=raw -net none
