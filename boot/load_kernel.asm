;
; A boot sector that will load the kernel from OS image on boot disk.
;

; BIOS loads boot sector code into memory offset 0x7c00.
[org 0x7c00]

KERNEL_OFFSET equ 0x1000  ; This it the memory offset into which we will load our kernel.


  ; BIOS stores index of boot drive it discovered in dl. Hang on to this as we will need to read
  ; from this drive later. Note that this variable is allocated in the globals section below.
  mov [BOOT_DRIVE], dl

  mov bp, 0x9000          ; Set up the stack. This gives us 5 kB above the loaded boot sector
  mov sp, bp              ; at 0x7c00 (there are 638 kB of free memory there).

  mov bx, MSG_REAL_MODE   ; Print message indicating we are in real mode. It prints the null-
  call print_string       ; terminated string whose start is pointed at by register dx.

  call load_kernel        ; Uses BIOS interrupt to read kernel into memory

  call switch_to_pm       ; Switch to protected mode, from which control will not return. After
                          ; making the switch, we enter our 32-bit code at the offset BEGIN_PM.

  jmp $


; Includes
%include "boot/print_string.asm"
%include "boot/disk_load.asm"
%include "boot/gdt.asm"
%include "boot/switch_to_pm.asm"
%include "boot/print_string_pm.asm"


; Since switch_to_pm changed our assembler encoding from 16-bit to 32-bit, switch it back to 16-bit
; before writing the function for loading the kernel.
[bits 16]

; Load the kernel from disk into memory. Note we must read the correct number of sectors or
; else we get a disc error.
load_kernel:

  mov bx, MSG_LOAD_KERNEL ; Print message for kernel load.
  call print_string

  mov bx, KERNEL_OFFSET   ; disk_load loads the first dh sectors from drive dl into memory at the
  mov dh, 1               ; offset es:bx. In this case we do not need to use the extended segment
  mov dl, [BOOT_DRIVE]    ; because we do not need to reach that high into memory.
  call disk_load

  ret


[bits 32]

BEGIN_PM:

  mov ebx, MSG_PROT_MODE  ; Print message indicating we are in real mode.
  call print_string_pm

  call KERNEL_OFFSET      ; Begin executing the kernel.

  jmp $                   ; If return ever controls from the kernel, hang.


; Global variables
BOOT_DRIVE db 0x0

MSG_REAL_MODE:            ; Include line feed/carriage return so next message doesn't overwrite.
  db "started in 16-bit real mode", 0xa, 0xd, 0x0

MSG_LOAD_KERNEL:
  db "loading kernel into memory...", 0x0

MSG_PROT_MODE:
  db "successfully landed in 32-bit protected mode.", 0x0


; Boot sector padding
times 510-($-$$) db 0x0
dw 0xaa55
