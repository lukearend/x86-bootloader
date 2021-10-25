;
; A simple boot sector program that loops forever.
;

loop:                 ; Define a label "loop" for an address that we can jump
                      ; back to.
    jmp loop          ; Use jmp CPU instruction to jump to the address of the 
                      ; "loop" instruction, which is the current instruction.

times 510-($-$$) db 0 ; Fill file with zero values up through the 510th byte.
                      ; $ represents the current address ("loop") and $$
                      ; represents the address of the start of the current
                      ; section in assembly (this line). `db` is a pseudo
                      ; instruction that initializes a byte with the given
                      ; value.

dw 0xaa55             ; Write magic number in last two bytes. `db` initializes
                      ; two bytes with the given value.