The boot process
----------------

We take the BIOS as a given. The BIOS is a set of software routines stored on a chip which is loaded into memory and initialized when the computer is switched on. The BIOS detects and gives basic control of the essential devices (keyboard, screen and hard disks).

The BIOS's job is to boot the computer by reading the _boot sector_ into memory. The boot sector is a portion of memory (in 512-byte chunks) starting at the very first physical location on the hard disk. The BIOS knows it has reached the end of the boot sector when it encounters the 2-byte magic number 0xaa55.

In memory, these bytes will be written '55 aa' as the x86 is a little-endian system, meaning that multi-byte values are written with the least-significant preceding the most-significant bytes. This magic number will occur at the end of a 512-byte block.

While booting, the BIOS loops through each physical device and finds the one which contains the boot sector. The data in the boot sector is then loaded into memory as the operating system's ~~machine code~~ bootloader (?). We are the ones who write this bootloader and operating system.

The simplest example of machine code would be a block of 512 bytes which:

 - ends with the magic number
 - begins with a loop containing a very simple jump instruction
 - is padded the rest of the way with zero-valued bytes[^1].

We can write the following machine code, using a hex editor like Hex Fiend, to the file _miminal.bin_:

```
eb fe 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
...
00 00 00 00 00 00 00 00 00 00 00 00 00 00 55 aa
```

The file is padded with zero values to contain 512 bytes in all.

Next, we must emulate the x86 64-bit processor into which this machine code is booted and executed. We can do this using a hardware emulator like QEMU:

    qemu-system-x86_64 miminal.bin

The result is that it should launch the boot process and then hang as there is no operating system code to be executed[^2].

Assembly language
-----------------

An x86 assembler such as nasm can be used to convert assembly language into bytecode for an x86 processor. Assembly language is meant to provide a human-readable way to write machine code, with short mnemonics for many CPU instructions in the x86 instruction set. _boot_sector.asm_ is an assembly code file for the minimal boot sector we created in the last section. We can assemble the machine code with the following command:

    nasm boot_sector.asm -f bin -o boot_sector.bin

It is worth noting that at this point our processor boots into _16-bit real mode_, which means that its instructions have a length of 16 bits and addresses refer to the corresponding real locations in physical memory. Real mode stands in opposition to _protected mode_, which prevents a userspace process from accessing kernel memory.

When programming assembly, we can make use of interrupts. These are a mechanism that have the CPU temporarily halt what it is doing and run a BIOS routine. Each interrupt is represented by an index in the interrupt vector, a table initially set up by the BIOS at physical address 0x0 in memory. The entries in this table are pointers to _interrupt service routines_ (ISRs), or sequences of instructions in memory that perform the function of a specific interrupt.

The CPU has four registers for quick storage of two-byte values:

- `ax`, with high-byte `ah` and low-byte `al`,
- `bx`, with high-byte `bh` and low-byte `bl`,
- `cx`, ...
- `dx`, ...

A value can be assigned to a register using the `mov` operation:

    mov ax, 1234 ; store the decimal number 1234 in ax

Let us now write a boot sector that prints "hello world" to the screen. We need the interrupt code for a BIOS routine that prints a character to the screen. It turns out we need the BIOS interrupt 0x10, with `ah` set to 0x0e to indicate teletype mode. This prints to screen the ASCII character stored in byte `al` and advances the cursor by one character. The assembly code for this is in _hello_simple.asm_.

We know that the BIOS loads our 512-byte boot sector into some place in memory and then, after initializing, leaves the CPU to jump to the start of the boot sector and begin executing. During initialization, the BIOS stored the interrupt vector at the very start of memory (0x0) and stored ISR code in various places as well. To avoid collision with any of these, the BIOS loads the boot sector machine code to a reserved block at address 0x7c00.

This figure represents the typical layout of lower memory after boot:

```

        |                                  |
        | free                             |
0x100000|----------------------------------|
        | BIOS (256 kB)                    |
 0xC0000|----------------------------------|
        | video memory (128 kB)            |
 0xA0000|----------------------------------|
        | extended BIOS data area (639 kB) |
 0x9fc00|----------------------------------|
        | free (638 kB)                    |
  0x7e00|----------------------------------|
        | loaded boot sector (512 bytes)   |
  0x7c00|----------------------------------|
        |                                  |
   0x500|----------------------------------|
        | BIOS data area (256 bytes)       |
   0x400|----------------------------------|
        | interrupt vector table (1 kB)    |
     0x0====================================

```

An exercise in locating data with these offsets is contained in the assembly code _find_the_byte.asm_.

#### The stack

The CPU also has an important functionality called the _stack_. The stack is a way to easily store and retrieve values beyond what can be stored in the registers without worrying about those values' actual locations in memory. The stack is defined by two values, `bp` and `sp`. `bp` is the memory location which serves as the base of the stack. `sp` is the location of the item on top of the stack, which is initially `bp`. When a word (i.e. two bytes in 16-bit real mode) is added to the stack, those bytes are written at location `sp` and `sp` is decremented to point to the next space down in memory. Thus the stack begins at `bp` and extends downward in memory according to the number of words it contains. For this reason it is important to allocate `bp`, the base of the stack, far enough above memory regions used for other code that the stack will never grow to the point those regions are overwritten. The assembly program `stack_example.asm` demonstrates usage of the stack to print "ABC".

Several more stack utilities:

 - `call`: stores the return address (address after current one) on the stack and then jumps to function
 - `ret`: used at the end of the function, pops top value (return address) off the stack and jumps to it
 - `pusha`: used at the beginning of a function, pushes all registers to the stack to avoid overwriting data they contained if function uses those registers
 - `popa`: used at the end of a function, pops top values from the stack back into the registers

So code with a function will look like:

```
some_function:
  pusha        ; Push all registers to the stack.
  mov bx, 10   ; Do some stuff with registers.
  add bx, 20
  mov ah, 0x0e ; Setup BIOS teletype output.
  int 0x10     ; Print character.
  popa         ; Pop values from stack back into registers.
  ret          ; Return to address right after function call that got us here.
```

#### Include files

The statement

    %include "my_file.asm"    

will be completely replaced by the contents of the file.

A more sophisticated "hello world" program that ties these things together is _hello_advanced.asm_, which makes use of labels, the stack, and a _print_string.asm_ function as well. _print_hex.asm_ makes use of the assembly operations `and` and `shr` to convert a register value to a hex string and print to screen. _print_string_example.asm_ demonstrates usage.

Reading the disk
----------------

So that we can reach addresses higher than 65535 on a 16-bit CPU, we introduce segments that provide a programmable data offset to the assembler, like the usage of the `[org 0x7c00]`. Segments provide an offset equal to the value they contain times 16 (which is easy to compute through a leftwise bit-shift). For example, setting a segment to 0x7c0 and then getting an address using that segment will offset the address by 0x7c00. It turns out that by default data addresses are offset by the `ds` segment. However we can explicitly use another segment, like the `es` segment, like so: `mov al, [es:my_label]`. See a demonstration of segment usage in _segment_offset.asm_.

#### Spinning disk drives

Locations on the disks are addressed by three physical coordinates:

1. head, which describes which platter and side are to be read from
2. cylinder, which describes which ring-shaped track of data is to be read from
3. sector, a 512-byte segment of the track

#### Reading the disk with BIOS

Though various disk types use different data bus technologies, BIOS abstracts this away and provides several routines to interact with common disk devices.

One such routing is BIOS interrupt 0x13. This requires setting `ah` to 0x02 and several other registers to tell the CPU where to read the data from and to. See the following:

```
mov ah, 0x02 ; BIOS read sector function.
mov dl, 0    ; Read drive 0 (i.e. first floppy drive).
mov ch, 3    ; Select cylinder 3.
mov dh, 1    ; Select 2nd side of floppy (this has zero-based indexing)
mov cl, 4    ; Select the 4th sector on the track (this has one-based indexing)
mov al, 5    ; Read 5 sectors (512-byte chunks) from the start point.
 
; Set address we want to move data to by writing to `es:bx`. Let's say 0xa1234.
mov bx, 0xa000
mov es, bx
mov bx, 0x1234
 
int 0x13     ; Perform the actual read.
```

We can evaluate the success of this operation by looking in the carry flag (CF) of the `flags` register. This flag is set to signal a general fault. Furthermore, the number of sectors _actually_ read is stored in `al` after the interrupt. We can check the carry flag using the jump operator `jc`, which only jumps if the carry flag was set:

```
int 0x13
 
; Check carry flag.
jc disk_error
 
; Check that 5 (the expected number) of sectors were read.
cmp al, 5
jne disk_error
 
disk_error:
  mov bx, ERROR_MSG
  call print_string
  jmp $
 
ERROR_MSG:
  db 'disk error', 0
```

We put this all together in the function _disk_load.asm_, which reads the first _n_ sectors following the boot sector from drive `dh` and where _n_ equals `dl`.

32-bit protected mode
---------------------

32-bit protected mode is different from 16-bit real mode:

- registers are extended to 32-bits e.g.: `mov ebx, 0274fe8fe`
- two more general purpose registers `fs`, `gs`
- 32-bit offsets
    - offset can reference up to 4 GB of memory (`0xffffffff`)
- memory segmentation
    - protect kernel from user applications
    - virtual memory with page swapping
- more sophisticated interrupt handling

## Printing to screen without BIOS

There is a display device which can be configured into text mode, wherein what is displayed on the screen is a visual representation of a specific range of memory. Specifically, each character cell of the display device is represented by two bytes in memory: the first byte is the ASCII code of the character to display and the second encodes attributes such as colors or blinking. This memory begins at the offset 0xb8000 and is laid out sequentially with 80 characters per row. _print_string_pm.asm_ gives an example of printing a string a string by writing directly to video memory.

## The global descriptor table

The global descriptor table is an important data structure in memory which is used for the protected-mode memory addressing system. In protected mode, a logical address is the combination of a segment register and an offset (i.e. `[es:0x0f`] for the 15th byte 15 of the segment starting at the address stored in `es`). And the way a logical address is mapped to a physical address is different as well. Whereas:

- in 16-bit real mode, the physical address was obtained by multiplying the segment register by 16 and adding the offset,
- in 32-bit protected mode, the physical address is obtained by indexing into the global descriptor table with the segment register and adding the offset described by that entry.

An entry in the global descriptor table occupies 8 bytes and looks like this:

```

     31        24 23   22   21   20   19             16 15  14  13 12  11   8 7          0
    +------------+---+-----+---+-----+-----------------+---+------+---+------+------------+ byte
    | base 31:24 | G | D/B | L | AVL | seg limit 19:16 | P | DPL  | S | type | base 23:16 |  4
    +------------+---+-----+---+-----+-----------------+---+------+---+------+------------+

     31                                   16 15                                    0
    +------------------------------------------+------------------------------------------+ byte
    |            base address 15:00            |            segment limit 15:00           |  0
    +------------------------------------------+------------------------------------------+
    base/limit:
        LIMIT (2 bytes, 4 bits) segment limit
        BASE  (1 byte, 2 bytes) segment base address

    1st flags:
        P     (1 bit)           segment present (use 1, indicates segment is present in memory)
        DPL   (2 bits)          descriptor privilege level (00 is highest privilege)
        S     (1 bit)           descriptor type (0=system, 1=code or data)

    type flags:
        TYPE  (4 bits)          segment type
            code        (1 bit) 1 (this is a code segment) or 0

        [if code segment]
            conforming  (1 bit) 0 (not conforming [protects memory]) or 1 (conforming)
            readable    (1 bit) 1 (readable) or 0 (execute-only)
        [if data segment]
            expand down (1 bit) 1 (allow segment to expand down) or 0
            writeable   (1 bit) 1 (writeable) or 0 (read-only)
      
            accessed    (1 bit) 0 (set to 1 once accessed)

    2nd flags:
        G     (1 bit)           granularity (left-shift limit by 3)
        D/B   (1 bit)           default operation size (0=16-bit segment, 1=32-bit segment)
        L     (1 bit)           64-bit code segment (IA-32e mode only)
        AVL   (1 bit)           available for user by system software

```

* **segment base address**: this is the offset that this entry describes.
* **default operation size**: whether segment is to be interpreted as 32-bit or 16-bit code.
* **descriptor privilege level**: 0 is the highest privilege.
* **descriptor type**: 1 for code or data segment, 0 is used for traps
* **type**:
    * highest bit: _code_: 1 if code segment
    * next bit: _conforming_: 0 (not conforming) means code in a segment with lower privilege may not call code in this segment, which is key to memory protection.
    * next bit: _readable_: 1 means readable, 0 means execute-only. Readable allows us to read constants defined in the code.
    * lowest bit: _accessed_: used for debugging and virtual memory techniques since the CPU sets this bit to 1 when it accesses the segment.
* **granularity**: if set to 1, limit is left-shifted by 3 (multiplied by 4 K).
* **64-bit code segment**: set to 0, unused on 32-bit processor.
* **AVL**: can be used for our purposes (e.g. debugging)

We point the CPU to the GDT through a simple 6-byte structure called the GDT descriptor:
* first two byte: GDT size
* next four bytes: GDT address

The preparation of a global descriptor table is shown in _gdt.asm_.

## Switching into 32-bit mode

The actual switch from 16-bit real to 32-bit protected mode involves the following steps:

1. Clear interrupts: `cli`. This is important to avoid attempting to use the IVT that BIOS set up at the start of memory.
2. Inform the CPU about the GDT: `lgdt [gdt_descriptor]`.
3. Make the actual switch over by setting the first bit of the CPU control register `cr0`:

    ```
    mov eax, cr0 ; We cannot set a single bit in `cr0` directly, so we store in `eax` and
    or eax, 0x1  ; leave the top seven bits untouched but set lowest bit to 1, then
    mov cr0, eax ; put the result back into `cr0` with the updated lowest bit.
    ```


4. Clear the instruction pipeline by issuing a far jump[^3] to the code segment, which we labelled earlier while creating the GDT. Because this is a far jump, the `cs` register is set to the offset of the segment being jumped to. We pass in the offset of the code segment in the GDT and jump to a well-defined label at the start of our 32-bit, protected mode code:

    ```      
      jmp CODE_SEG:start_protected_mode

    [bits 32]

    start_protected_mode:
      ...                 ; Here we begin initialization in protected mode.
    ```
5. Use the `[bits 32]` directive to tell our assembler that, from this point onwards, it should encode in 32-bit intsructions.

We combine these steps into a reusable switchover routine in _switch_to_pm.asm_. Note that the first thing we do for initialization in protected mode is reset our segment registers to the data segment in our GDT and set up the stack.

We combine everything we have learned thus far into a boot sector that demonstrates the switch from 16-bit real mode into 32-bit protected mode: _boot_to_pm.asm_.

## Registers and their usage

From https://www.eecg.utoronto.ca/~amza/www.mindsec.com/files/x86regs.html.

```

    32 bits:    EAX   EBX   ECX    EDX
    16 bits:     AX    BX    CX    DX
     8 bits:  AH AL BH BL CH CL DH DL

    EAX,AX,AH,AL: Called the **a**ccumulator register. 
                  Used for I/O port access, arithmetic, interrupt calls, etc...

    EBX,BX,BH,BL: Called the **b**ase register.
                  Used as a base pointer for memory access, gets some interrupt return values.

    ECX,CX,CH,CL: Called the **c**ounter register
                  Used as a loop counter and for shifts gets some interrupt values.

    EDX,DX,DH,DL: Called the **d**ata register
                  Used for I/O port access, arithmetic, some interrupt calls.

```

Experiments in C compilation
----------------------------

We will be writing our kernel in C and compiling it to machine code. At boot, our boot sector will be loaded into memory and executed to read in the kernel code. In preparation for writing the kernel, we will study C compilation, the process by which C source code is converted to assembly code.

Consider the following C code in the file `basic.c`:

```
// Define an empty function that returns an integer
int my_function() {
    return 0xbaba;
}

```

We can compile the code to the file `basic.o` using gcc:

    x86_64-elf-gcc -m32 -ffreestanding -c basic.c -o basic.o

and then disassemble it using `objdump`:

    objdump -d basic.o

The output of `objdump` is the following:

```
basic.o:    file format elf32-i386


Disassembly of section .text:

00000000 <my_function>:
       0: 55                            pushl   %ebp
       1: 89 e5                         movl    %esp, %ebp
       3: b8 ba ba 00 00                movl    $47802, %eax
       8: 5d                            popl    %ebp
       9: c3                            retl
```

We can make that a bit friendlier by translating to NASM and commenting:

```
basic.o: 32-bit i386

Machine code:               Assembly:          
00000000 <_my_function>:    my_function:
0: 55                         push bp         ; Preserve current frame pointer in case we call
                                              ; another function inside this one. That way we can
                                              ; reset the frame pointer to its value before calling
                                              ; this function at the end of our function code.
1: 89 e5                      mov bp, sp      ; Create new pointer to current stack top, so that we
                                              ; can use the stack for our own purposes during this
                                              ; function.
3: b8 ba ba 00 00             mov eax, 0xbaba ; Move return value into A register, which is the
                                              ; register expected to hold the return value when  
                                              ; flow of control exits this function.
8: 5d                         pop bp          ; Replace stack pointer with what it was before the
                                              ; call to this function. That way we return to the
                                              ; context we had before this function was called.
9: c3                         ret             ; Pop return address off the stack and jump back to
                                              ; the address from which this routine was called.
```

To implement functions on top of assembly routines, we introduce the concept of a frame. For noew it suffices to know that a frame is a stack pointer associated to a call to a function in context. When a function is called, the start address of its caller's frame is pushed onto the stack. Upon starting, the function sets up its own stack frame at the top of the stack of its caller. Once the function returns, the top value on the stack is popped to the `ebp` register. This is the equivalent of saying the new current frame has a stack back at address `ebp`, the caller's frame.

The object files output by the compiler contain the raw machine code plus some annotation. This annotation associates label to their relative addresses and is there to be used by the _linker_. During compilation, the linker stitches together the machine code from the object files into one executable binary. When writing this binary, it substitutes labels for absolute addresses using the object file annotations.

To use the linker to create an executable using the object file above, run:

    x86_64-elf-ld -melf_i386 -o basic.bin -Ttext 0x0 --oformat binary basic.o

* `-melf_i386` sets e**m**ulation to `elf_i386`, the original 32-bit x86 architecture.
* `-o basic.bin` specifies the output file as `basic.bin`,
* `-Ttext 0x0` says to offset all addresses in the binary relative to 0x0. This option is important when writing our kernel later, as the kernel is loaded to some known location in memory and we must offset addresses relative to it.
* `--oformat binary` specifies the output format as binary (leaving no metadata in the machine code).
* `basic.o` is an input argument, the file to be linked.

Now let us dissassemble this binary using a NASM dissassembler:

    ndisasm -b 32 basic.bin

The result is:

```
00000000  55                push ebp
00000001  89E5              mov ebp,esp
00000003  B8BABA0000        mov eax,0xbaba
00000008  5D                pop ebp
00000009  C3                ret
```

This is essentially the same as our "nice" version of the dissassembly output from `objdump`. The left-hand column shows the file offsets of the instructions. The middle columns shows the machine code as one or multiple bytes. The right column shows the NASM assembly instruction GCC generated.

Now we can write some C code declaring a local variable and compile, link and disassemble it as before. We write the following to _local_var.c_:

```
// Declare a local variable.
int my_function() {
    int my_var = 0xbaba;
    return my_var;
}
```

And then run:

    x86_64-elf-gcc -m32 -ffreestanding -c local_var.c -o local_var.o
    x86_64-elf-ld -melf_i386 -o local_var.bin -Ttext 0x0 --oformat binary local_var.o
    ndisasm -b 32 local_var.bin

We get the following output:

```
00000000  55                push ebp
00000001  89E5              mov ebp,esp
00000003  83EC10            sub esp,byte +0x10
00000006  C745FCBABA0000    mov dword [ebp-0x4],0xbaba
0000000D  8B45FC            mov eax,[ebp-0x4]
00000010  C9                leave
00000011  C3                ret
```

Let's walk through this line by line:

* `00`: First we push `ebp` to the stack, storing the frame pointer of the caller's stack frame.
* `01`: Next, we set the stack base to the current top of the stack, in order to use the stack for the current function.
* `03`: reserves 16 (0x10) bytes on the stack for local use. This is enough for one variable of whatever size it may be, though we will only use the first four bytes to store the 32-bit `int`.
* `06`: store the double-word value 0xbaba at the address `ebp` - 4, filling up the 4 bytes at the base of this function's stack. Here we use a CPU shortcut called _effective address manipulation_, where the CPU calculates the specified offset of 0x4 on-the-fly from the value in `ebp` (which is only known at runtime). `dword` states explicitly that we are storing a double word (4 bytes) on the stack, 0x0000baba (not a single word, 0xbaba or four words 0x000000000baba).
* `0D`: load the value 0xbaba (at the address `ebp` - 4) into the A register.
* `10`: `leave` is equivalent to:

    ```
    mov esp, ebp    ; Put the stack back to how it was before calling this function. This is the
    pop ebp         ; reciprocal of the first two lines of this function.
    ```

    - Line 1 of `leave` says the new top of the stack is ebp, or the value at the bottom of the stack from of the function that is exiting. It should be fine to overwrite any memory there because anything above it is leftover values on the stack 

* `11`: pop return address off the stack and jump (back) to it.

Throughout all of this, what we think of as `my_var` is tracked by the compiler as `ebp - 0x4`, i.e., the first four bytes of the stack. The compiler stores the return value `my_var` in A register knowing this is interpreted as `my_var`'s return value.

## Calling functions

Now see the following code featuring one function which calls another:

```
void callee_function(int my_arg) {
    return my_arg;
}

void caller_function() {
    callee_function(0xdede);
}
```

Compilation/linking and dissasembly gives:

```
00000000  55                push ebp          ; callee start
00000001  89E5              mov ebp,esp
00000003  8B4508            mov eax,[ebp+0x8]
00000006  5D                pop ebp
00000007  C3                ret               ; callee end
00000008  55                push ebp          ; caller start
00000009  89E5              mov ebp,esp
0000000B  68DEDE0000        push dword 0xdede
00000010  E8EBFFFFFF        call 0x0
00000015  83C404            add esp,byte +0x4
00000018  90                nop
00000019  C9                leave
0000001A  C3                ret               ; caller end
```

It's useful to start with the caller function.

* `08` and `09` are the familiar function prolog.
* `0B` pushes double-word 0xdede to the stack as an argument to the function about to be called.
* `10`: we call the function starting at 0x0, the callee.
* `00` and `01` are the familiar function prolog.
* `03` copies the four bytes from ebp+0x8:ebp+0x4 into the A register. Here we are actually reaching up into the callee's stack frame to get the argument's value. The callee's address occupies bytes 0x4:0x0 on the stack and the argument occupies 0x8:0x4. By convention in C, when calling arguments are pushed to the stack in reverse order, so the first argument is on the top. The A register is where the `int` return value for this function is supposed to be stored.
* `06` return stack base to the stack frame of the caller by grabbing it off the stack.
* `07` pop caller address off the stack and jump back to it to return flow of control.

## Pointers, addresses and data

A variable is simply a reference to an allocated memory address, where sufficient space has been reserved to accomodate a particular data type.

Consider the following C code:

```
def my_function() {
    int a = 3;
    int b = 4;
    int total = a + b;
}
```

How would this look in assembly?

* Prolog

        push bp             ; Prolog
        mov bp, sp

    * The stack now looks like

        0x10== . . . ==0x06====0x04====0x02====0x0 <- bp, sp


* `int a = 3` becomes
    
        sub sp, 0x10        ; Allocate 16 bytes on the stack for int a.
        push dword 3        ; Load the number 3 as a double word, or 32-bit integer (0x00000003) 

    * The stack now looks like

        0x10== . . . ==0x04====0x03====0x02====0x01====0x0  <- bp
        |              |  0x03 |  0x00 |  0x00 |  0x00 |
        0x20-- . . . --0x14----0x13----0x12----0x11----0x10 <- sp

* `int b = 4` becomes

        sub sp, 0x10        ; Allocate 16 bytes on the stack for int b.
        push dword 4        ; Load the number 4 as a double word.

    * The stack now looks like

        0x10== . . . ==0x04====0x03====0x02====0x01====0x0  <- bp
        |              |  0x03 |  0x00 |  0x00 |  0x00 |
        0x20-- . . . --0x14----0x13----0x12----0x11----0x10
        |              |  0x04 |  0x00 |  0x00 |  0x00 |
        0x30-- . . . --0x24----0x23----0x22----0x21----0x20 <- sp

* `int total = a + b` becomes

        mov ebx, [bp + 0x04]    ; LSB of 32-bit double word at base of stack
        add ebx, [bp + 0x14]    ; LSB of 32-bit double word at second position on stack
        sub sp, 0x10            ; Allocate 16 bytes on the stack for int `total`.
        push dword ebx

    * The stack is then

        0x10== . . . ==0x04====0x03====0x02====0x01====0x0  <- bp
        |              |  0x03 |  0x00 |  0x00 |  0x00 |
        0x20-- . . . --0x14----0x13----0x12----0x11----0x10
        |              |  0x04 |  0x00 |  0x00 |  0x00 |
        0x30-- . . . --0x24----0x23----0x22----0x21----0x20
        |              |  0x07 |  0x00 |  0x00 |  0x00 |
        0x40-- . . . --0x34----0x33----0x32----0x31----0x30 <- sp

* To return, we might set the return value (A register) to `total`:

        mov eax, [bp + 0x24]
        leave
        ret

Function setup and teardown aside, note how memory is managed for us by the stack; that is, we do not have to worry about the addresses of `a` and `b` when allocating space for them and writing data to those addresses. But suppose, in the course of our C programming, we want to store a value at an explicitly provided location in memory? Or how about if we want to read the value at a specific location in memory? For this, we introduce the concept of a _pointer_. A pointer is a special type of variable which holds a reference to the storage address for an object of some specified type. We can write to location 0xb8000 directly by creating a pointer to the address 0xb8000 called, say, `ptr`, and issuing a command to "write to the address referred to by `ptr`". The "address referred to by `ptr`" is represented by `*ptr`, where `*` is an operator that can be used on a pointer variable to directly access the value to which it refers. This operation is called _dereferencing_ and `*` is called the _dereference operator_.

For instance, knowing the first character of video memory maps onto the address 0xb8000, we could print an 'X' to line 1, col 1 in the following way:

    char video_address = 0xb8000 ; Declare a pointer to an integer stored at address 0xb8000.
    *video_address = 'X'         ; Assign ASCII value 'X' to the integer at address 0xb8000.

The concept of dereferencing should feel familiar because the syntax `[ax]` from assembly code essentially dereferences a register; that is, it refers to the value stored at the address in `ax`. In this context, `ax` is being used as a pointer rather than as a data container in itself. On a 32-bit operating system, all pointers (no matter what type they point to) will be 32-bits. This is because 32-bit numbers are used to specify addresses.

---

## Dependencies
- MacOSX: host operating system, runs QEmu and editors.
- Hex Fiend: hex editor, used to write and read raw binaries.
- QEmu: x86 emulator, emulates a 64-bit x86 processor.
- nasm: x86 assembler, assembles bytecode for an x86 processor.
- Make: compilation tool, automates build process.
- `x86_64-elf-gcc`, `x86_64-elf-ld` (`brew install i386-elf-binutils i386-elf-gcc`): binary utilities and GCC compiler for x86, cross-compiled for M1 Mac.

## Routines vs. functions
* _routine_: assembly code, compiled to machine code, labeled by address, parametrized by registers.
* _function_: C code: offset by compiler annotation, parametrized by contents of the stack.

[^1]: The CPU interprets zero-valued bytes as no-ops and thus knows to keep reading past them. If these bytes remain uninitialized, the CPU will attempt to execute them and either get itself into a bad state and reboot, or stumble upon a BIOS function that reformats the disk.

[^2]: If you change the magic numbers at the end of the file and try again, the BIOS should crash saying "no bootable device".

[^3]: To issue a far jump, as opposed to a near (standard) jump, we additionally provide the target segment: `jmp <segment>:<address offset>`.
