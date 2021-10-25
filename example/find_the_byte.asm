;
; A simple boot sector program that demonstrates addressing.
;

; [org 0x7c00]   ; Tells where we expect the code to load in memory. Label references are then
                 ; corrected by this offset instead of doing it manually as in third attempt.
                 ; With this uncommented, second and fourth attempts succeed.

mov ah, 0x0e     ; Set 0x10 interrupt to teletype mode.

; First attempt
mov al, the_secret
int 0x10         ; Print ASCII character for value in register `al`.

; First attempt fails because it has printed out the address of the `the_secret` label, not the
; 'X' value stored at that address.

; Second attempt
mov al, [the_secret]
int 0x10

; Second attempt fails because even though it prints out the value stored at the `the_secret`
; address, this offset is from the start of main memory and not the start of BIOS memory.

; Third attempt
mov bx, the_secret
add bx, 0x7c00
mov al, [bx]
int 0x10


; Third attempt succeeds. The offset of the 'X' byte in our loaded code, `the_secret`, is stored in
; the B register. The offset of our code in main memory is added to the B register, giving the
; memory location of the 'X' data byte. The value at this location, the 'X' byte itself, is loaded
; into `al` and printed.

; At this point, we dump out the raw binary created from this assembly file. We see that the byte
; 0x58, the ASCII character 'X', occurs at position 29 in the bytecode. We add 0x1d (29) to the
; start address of BIOS memory, giving 0x7c19.

; Fourth attempt
mov al, [0x7c1d] ; Take value directly from offset 30 from start of BIOS memory.
int 0x10

; Fourth attempt succeeds. The byte value 'X' is read directly from memory.

jmp $            ; Jump forever.

the_secret:      ; This is a label, we can put them anywhere in our programs. They give us a
  db 'X'         ; convenient way to get the offset from the start of the code of some particular
                 ; code or data.

; Padding and magic number.
times 510-($-$$) db 0
dw 0xaa55
