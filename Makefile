all: 

find_the_byte: boot/find_the_byte.asm
	nasm boot/find_the_byte.asm -f bin -o bin/find_the_byte.bin && \
	qemu-system-x86_64 -drive file=bin/find_the_byte.bin,format=raw -net none

stack_example: boot/stack_example.asm
	nasm boot/stack_example.asm -f bin -o bin/stack_example.bin && \
	qemu-system-x86_64 -drive file=bin/stack_example.bin,format=raw -net none

print_string: boot/print_string.asm
	nasm boot/print_string.asm -f bin -o bin/print_string.bin

hello_advanced: print_string boot/hello_advanced.asm
	cd boot && \
	nasm hello_advanced.asm -f bin -o ../bin/hello_advanced.bin && \
	qemu-system-x86_64 -drive file=../bin/hello_advanced.bin,format=raw -net none

.PHONY: all
