;
; A simple boot sector that prints "Hello" to the screen using a BIOS routine.
;

mov ah, 0x0e ; Indicate scrolling teletype to BIOS routine 0x10.

mov al, 'h'
int 0x10
mov al, 'e'
int 0x10
mov al, 'l'
int 0x10
mov al, 'l'
int 0x10
mov al, 'o'
int 0x10
mov al, ' '
int 0x10
mov al, 'w'
int 0x10
mov al, 'o'
int 0x10
mov al, 'r'
int 0x10
mov al, 'l'
int 0x10
mov al, 'd'
int 0x10
mov al, 0x0A ; line feed
int 0x10
mov al, 0x0D ; carriage return
int 0x10

jmp $ ; Jump to the current address forever.

;
; Padding and BIOS magic number.
;
times 510-($-$$) db 0
dw 0xaa55
