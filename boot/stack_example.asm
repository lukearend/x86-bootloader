;
; A simple boot sector program that demonstrates the stack.
;

mov ah, 0x0e

mov bp, 0x8000   ; Set the base of the stack a little above where BIOS loads our boot sector.
mov sp, bp       ; The top of the stack starts out at the base.

push 'C'         ; Push some characters onto the stack for later retrieval. Since these are pushed
push 'B'         ; on as 16-bit words, they are prepended with the most significant byte 0x00.
push 'A'

pop bx           ; Pop the value on top of the stack into register B. Because the 16-bit word is
mov al, bl       ; stored in the register, we print just the least significant byte, 'A'.
int 0x10

pop bx           ; This should print 'B', as it is the next item on the stack.
mov al, bl
int 0x10

mov al, [0x7ffe] ; This should print 'C', as it is at the word just before the stack base `bp`.
int 0x10

pop bx           ; This should also print 'C', as it is the next item on the stack.
mov al, bl
int 0x10

mov al, [0x7ffe] ; This will print an undefined value, as the stack is now empty.
int 0x10

jmp $            ; Jump forever.

; The final output should be 'ABCC*' where * is an undefined value.

; Padding and magic number.
times 510-($-$$) db 0
dw 0xaa55
