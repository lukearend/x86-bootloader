;
; A function for printing the null-terminated string starting at the address stored in B register.
;

print_string:
  pusha
  mov ah, 0xe         ; Set BIOS interrupt 0x10 to teletype mode.
  jmp read_character

read_character:
  mov al, [bx]        ; Take byte value at address stored in B register.

  cmp al, 0           ; Check if this character is null, which indicates end of string.
  jne print_character ; If character is not null, print it.
  popa
  ret

print_character:
  int 0x10            ; BIOS interrupt 0x10 prints ASCII character for byte in `al`.
  add bx, 1           ; Increment B register to point to address of the next character.
  jmp read_character  ; Read next character.
