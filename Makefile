all: 

# Assemble a boot sector code file and run it on x86.
filename=stack_example
assemble-and-boot:
	nasm boot/$(filename).asm -f bin -o bin/$(filename).bin && \
	qemu-system-x86_64 -drive file=bin/$(filename).bin,format=raw -net none

.PHONY: all assemble-and-boot
