;
; A boot sector that prints a string using our function.
;
[org 0x7c00]                ; Tell assembler where this code is loaded.

    mov bx, HELLO_MSG       ; B register is parameter to our function specifying address
    call print_string       ; of string's first byte.

    mov bx, GOODBYE_MSG
    call print_string

    jmp $                   ; Hang

%include "print_string.asm"

; Data
HELLO_MSG:
    db 'hello ', 0     ; Null-terminated string

GOODBYE_MSG:
    db 'goodbye', 0

; Padding and magic number.
times 510-($-$$) db 0
dw 0xaa55
