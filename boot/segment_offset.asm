;
; A simple boot sector that demonstrates segment offsetting.
;

mov ah, 0x0e            ; Set BIOS interrupt 0x10 to teletype mode.

mov al, [the_secret]    ; Does not print 'X'. This is because `the_secret` is not offset
int 0x10                ; from the start of BIOS memory.

mov bx, 0x7c0           ; Can't set ds directly so we copy to B register first.
mov ds, bx              ; Data segment is 0x7c0 so addresses are offset by 0x7c00.
mov al, [the_secret]    ; This prints 'X', because we have the proper offset.
int 0x10

mov al, [es:the_secret] ; Tell CPU to use `es` (explicit segment) for offsetting addresses.
int 0x10                ; This does not print 'X' because `es` is not set to offset
                        ; to the start of BIOS memory.

mov bx, 0x7c0
mov es, bx
mov al, [es:the_secret] ; This should work.
int 0x10

jmp $

the_secret:
  db 'X'

times 510-($-$$) db 0
dw 0xaa55
