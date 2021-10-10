;
; A function for printing the null-terminated string starting at the address stored in B register.
;
; [org 0x7c00]            ; Tell assembler where this code is loaded.

print_string:
    pusha
    mov ah, 0xe         ; Set BIOS interrupt 0x10 to teletype mode.
    jmp read_character

read_character:
    mov al, [bx]        ; Take byte value at address stored in B register.

    cmp al, 0           ; Check if this character is null, which indicates end of string.
    je  end             ; If character is null, exit.
    jmp print_character ; Otherwise, print it.

print_character:
    int 0x10            ; BIOS interrupt 0x10 prints ASCII character for byte in `al`.
    add bx, 1           ; Increment B register to point to address of the next character.
    jmp read_character  ; Read next character.

end:
    popa
    ret
