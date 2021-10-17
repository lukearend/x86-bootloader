;
; A routine for switching from 16-bit real mode to 32-bit protected mode.
;

[bits 16]

switch_to_pm:

  cli         ; We must switch off interrupts until we have setup the protected-mode interrupts
              ; otherwise the BIOS interrupt vector will run wild.
  
  lgdt [gdt_descriptor] ; Load our global descriptor table, which defines the PM segments.

  mov eax, cr0          ; Make the actual switch by setting `cr0` bit 0.
  or eax, 0x1
  mov cr0, eax

  jmp CODE_SEG:init_pm  ; Issue a far jump to our 32-bit code (flushes CPU pipeline).

[bits 32]

; Initialize registers and the stack once in PM.

init_pm:

  mov ax, DATA_SEG      ; Now in PM, our segment register values from real mode are meaningless.
                        ; So, we initialize all registers to point to the data segment offset.

  mov ds, ax            ; Data segment register (default offset for data addresses)
  mov ss, ax            ; Stack segment register (points to segment holding stack)
  mov es, ax            ; General-purpose register
  mov fs, ax            ; General-purpose register (e.g. for exception handling chain)
  mov gs, ax            ; General-purpose register

  mov ebp, 0x90000      ; Update our stack position so it is right at the top of free space. This
  mov esp, ebp          ; value is left-shifted by 3 since our code segment granularity is set to 1,
                        ; thus the stack base is at physical address 0x9000000.

  call BEGIN_PM         ; Finally, call a well-known label which will be used at the start of the
                        ; protected-mode code. This is the entry point for our 32-bit code and we
                        ; will not return from it.
