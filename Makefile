all: 

find_the_byte: boot/find_the_byte.asm
	cd boot && \
	nasm find_the_byte.asm -f bin -o ../bin/find_the_byte.bin && \
	qemu-system-x86_64 -drive file=../bin/find_the_byte.bin,format=raw -net none

stack_example: boot/stack_example.asm
	cd boot && \
	nasm stack_example.asm -f bin -o ../bin/stack_example.bin && \
	qemu-system-x86_64 -drive file=../bin/stack_example.bin,format=raw -net none

print_string: boot/print_string.asm
	cd boot && \
	nasm print_string.asm -f bin -o ../bin/print_string.bin

hello_simple:
	cd boot && \
	nasm hello_simple.asm -f bin -o ../bin/hello_simple.bin && \
	qemu-system-x86_64 -drive file=../bin/hello_simple.bin,format=raw -net none

hello_advanced: print_string boot/hello_advanced.asm
	cd boot && \
	nasm hello_advanced.asm -f bin -o ../bin/hello_advanced.bin && \
	qemu-system-x86_64 -drive file=../bin/hello_advanced.bin,format=raw -net none

print_hex: print_string boot/print_hex.asm
	cd boot && \
	nasm print_hex.asm -f bin -o ../bin/print_hex.bin

print_hex_example: print_hex boot/print_hex_example.asm
	cd boot && \
	nasm print_hex_example.asm -f bin -o ../bin/print_hex_example.bin && \
	qemu-system-x86_64 -drive file=../bin/print_hex_example.bin,format=raw -net none

segment_offset: boot/segment_offset.asm
	cd boot && \
	nasm segment_offset.asm -f bin -o ../bin/segment_offset.bin && \
	qemu-system-x86_64 -drive file=../bin/segment_offset.bin,format=raw -net none

disk_load: boot/disk_load.asm
	cd boot && \
	nasm disk_load.asm -f bin -o ../bin/disk_load.bin

print_string_pm: boot/print_string_pm.asm
	cd boot && \
	nasm print_string_pm.asm -f bin -o ../bin/print_string_pm.bin

gdt: boot/gdt.asm
	cd boot && \
	nasm gdt.asm -f bin -o ../bin/gdt.bin

.PHONY: all
