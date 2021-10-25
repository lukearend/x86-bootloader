;
; Load `dh` sectors to `es:bx` from drive `dl`.
;

disk_load:
  pusha

  push dx      ; Push D register to the stack so we can get `dh` from it later
               ; when we need to confirm whether the read was successful.
  mov ah, 0x02 ; BIOS read sector function.
  mov al, dh   ; Read `dh` sectors.
  mov ch, 0    ; Select cylinder 0.
  mov dh, 0    ; Select first side.
  mov cl, 2    ; Start reading from the second sector.

  int 0x13     ; Perform the actual read.

  pop dx
   
  ; Check carry flag.
  jc disk_error
   
  ; Check that the expected number of sectors were read.
  cmp al, dh
  jne disk_error

  popa
  ret
 
disk_error:
  mov bx, ERROR_MSG
  call print_string
  jmp $

ERROR_MSG:
  db 'disk error', 0
