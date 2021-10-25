;
; Boot sector demonstrating print_hex function.
;

[org 0x7c00]

  mov dx, 0x1fb6
  call print_hex

  jmp $

%include "../boot/print_string.asm"
%include "../boot/print_hex.asm"

times 510-($-$$) db 0
dw 0xaa55
