.PHONY: all clean
all: clean os-image

clean:
	rm bin/*
	rm os-image

minimal_example: 
	qemu-system-x86_64 -drive file=boot/minimal_example.bin,format=raw -net none

find_the_byte:
	cd boot && \
	nasm find_the_byte.asm -f bin -o ../bin/find_the_byte.bin && \
	qemu-system-x86_64 -drive file=../bin/find_the_byte.bin,format=raw -net none

stack_example:
	cd boot && \
	nasm stack_example.asm -f bin -o ../bin/stack_example.bin && \
	qemu-system-x86_64 -drive file=../bin/stack_example.bin,format=raw -net none

hello_simple:
	cd boot && \
	nasm hello_simple.asm -f bin -o ../bin/hello_simple.bin && \
	qemu-system-x86_64 -drive file=../bin/hello_simple.bin,format=raw -net none

hello_advanced:
	cd boot && \
	nasm hello_advanced.asm -f bin -o ../bin/hello_advanced.bin && \
	qemu-system-x86_64 -drive file=../bin/hello_advanced.bin,format=raw -net none

print_hex_example:
	cd boot && \
	nasm print_hex_example.asm -f bin -o ../bin/print_hex_example.bin && \
	qemu-system-x86_64 -drive file=../bin/print_hex_example.bin,format=raw -net none

segments_example:
	cd boot && \
	nasm segments_example.asm -f bin -o ../bin/segments_example.bin && \
	qemu-system-x86_64 -drive file=../bin/segments_example.bin,format=raw -net none

disk_load_example:
	cd boot && \
	nasm disk_load_example.asm -f bin -o ../bin/disk_load_example.bin  && \
	qemu-system-x86_64 -drive file=../bin/disk_load_example.bin,format=raw -net none

boot_to_pm:
	cd boot && \
	nasm boot_to_pm.asm -f bin -o ../bin/boot_to_pm.bin && \
	qemu-system-x86_64 -drive file=../bin/boot_to_pm.bin,format=raw -net none

basic_example:
	cd kernel && \
	x86_64-elf-gcc -m32 -ffreestanding -c basic_example.c -o basic_example.o && \
	x86_64-elf-ld -melf_i386 -o ../bin/basic_example.bin -Ttext 0x0 --oformat binary basic_example.o && \
	ndisasm -b 32 ../bin/basic_example.bin

local_var_example:
	cd kernel && \
	x86_64-elf-gcc -m32 -ffreestanding -c local_var_example.c -o local_var_example.o && \
	x86_64-elf-ld -melf_i386 -o ../bin/local_var_example.bin -Ttext 0x0 --oformat binary local_var_example.o && \
	ndisasm -b 32 ../bin/local_var_example.bin

calling_example:
	cd kernel && \
	x86_64-elf-gcc -m32 -ffreestanding -c calling_example.c -o calling_example.o && \
	x86_64-elf-ld -melf_i386 -o ../bin/calling_example.bin -Ttext 0x0 --oformat binary calling_example.o && \
	ndisasm -b 32 ../bin/calling_example.bin

string_example:
	cd kernel && \
	x86_64-elf-gcc -m32 -ffreestanding -c string_example.c -o string_example.o && \
	x86_64-elf-ld -melf_i386 -o ../bin/string_example.bin -Ttext 0x0 --oformat binary string_example.o && \
	ndisasm -b 32 ../bin/string_example.bin

bin/kernel.bin:
	cd kernel && \
	nasm enter_kernel.asm -f elf -o enter_kernel.o && \
	x86_64-elf-gcc -m32 -ffreestanding -c kernel.c -o kernel.o && \
	x86_64-elf-ld -melf_i386 -o ../bin/kernel.bin -Ttext 0x1000 --oformat binary enter_kernel.o kernel.o

bin/load_kernel.bin:
	cd boot && \
	nasm load_kernel.asm -f bin -o ../bin/load_kernel.bin

os-image: bin/kernel.bin bin/load_kernel.bin
	cat bin/load_kernel.bin bin/kernel.bin > os-image

run: os-image
	qemu-system-x86_64 -drive file=os-image,format=raw -net none
