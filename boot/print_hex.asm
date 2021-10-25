;
; Print the hex value stored in D register.
;

print_hex:
  pusha 

  mov bx, HEX_OUT   ; Store start location of HEX_OUT in B register,
  add bx, 2         ; then skip ahead to first hex character.

  ; Copy first digit of D register value into C register.
  mov cl, dh
  shr cx, 4         ; Shifting `dh` four bits to the right takes the first
  call convert_char ; of the two hex digits that make up the byte.
  add bx, 1

  ; Copy second digit of D register into C register.
  mov cl, dh
  and cx, 00001111b ; AND `dh` with boolean mask to take lower
  call convert_char ; four bits, or second hex digit in the byte.
  add bx, 1

  ; Copy third digit of D register into C register and convert.
  mov cl, dl
  shr cx, 4
  call convert_char
  add bx, 1

  ; Copy fourth digit of D register into C register and convert.
  mov cl, dl
  and cx, 00001111b
  call convert_char

  mov bx, HEX_OUT   ; Point B register at start address of string.
  call print_string ; Print HEX_OUT.

  popa
  ret

convert_char:       ; Get ASCII code for value in C register and write that ASCII
  cmp cx, 10        ; code to current offset in HEX_OUT.
  jge above_ten
  jmp below_ten

above_ten:
  add cx, 87        ; If C register value is above 10, we can subtract 10
                    ; to get it into the range 0-5 representing hex digits
                    ; a-f. ASCII 'a' is at offset 97 in the ASCII table, so
                    ; then we add 97 to get the proper ASCII code.
  mov [bx], cx
  ret

below_ten:
  add cx, 48        ; '0' is at offset 48 in the ASCII table.
  mov [bx], cx
  ret

; This is the memory we fill up with ASCII characters to be written.
HEX_OUT:
  db '0x0000', 0
