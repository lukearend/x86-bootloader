;
; Load two sectors, filled with '0xdead' and '0xbeef' respectively, after a boot sector and
; demonstrate disk_load function by loading those sectors and printing a value from each.
;

[org 0x7c00]

  ; BIOS stores the drive it has auto-detected as boot-drive in `dl`.
  mov [BOOT_DRIVE], dl

  ; Initialize stack with plenty of headroom.
  mov bp, 0x8000
  mov sp, bp

  ; Load 5 sectors to 0x0000(es):0x9000(bx). `es` is initially 0x0000.
  mov bx, 0x9000
  mov dh, 2
  mov dl, [BOOT_DRIVE]
  call disk_load

  ; Check word at 0x9000 (start of 1st sector read), should be '0xdead'.
  mov dx, [0x9000]
  call print_hex

  ; Check word at 0x9000 + 512 (start of 2nd sector read), should be '0xbeef'.
  mov dx, [0x9000 + 512]
  call print_hex

  jmp $

%include "print_string.asm"
%include "print_hex.asm"
%include "disk_load.asm"

BOOT_DRIVE:              ; Variable to store boot drive.
  db 0

; Padding and magic number.
times 510-($-$$) db 0 
dw 0xaa55

times 256 dw 0xdead      ; Second sector consists of words 0xdead.
times 256 dw 0xbeef      ; Third sector consists of words 0xbeef.
