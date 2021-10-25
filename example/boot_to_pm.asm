;
; A boot sector that enters 32-bit protected mode.
;

[org 0x7c00]

  ; Setup stack in free memory above loaded boot sector.
  mov ax, 0x8000
  mov bp, ax     ; We cannot directly load stack register with a literal value, so we write value to
  mov sp, bp     ; ax and load from ax.

  ; Print out string in real mode. `print_string` prints the null-terminated string of ASCII chars
  ; starting at the address stored in bx.
  mov bx, MSG_REAL_MODE
  call print_string

  ; Switch to pm.
  call switch_to_pm

  jmp $               ; Never reached

; Includes
%include "../boot/print_string.asm"
%include "../boot/gdt.asm"
%include "../boot/switch_to_pm.asm"
%include "../boot/print_string_pm.asm"

[bits 32]

; This is where we arrive after switching to and initializing protected mode.
BEGIN_PM:
  ; Print out null-terminated string pointed to by ebx.
  mov bx, MSG_PROT_MODE

  ; Print out string in protected mode.
  call print_string_pm

  jmp $               ; Hang.

; Global constants
MSG_REAL_MODE:
  db "Hello from real mode", 0x0

MSG_PROT_MODE:
  db "Hello from protected mode", 0x0

; Bootsector padding
times 510-($-$$) db 0x0
dw 0xaa55
