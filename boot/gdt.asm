;
; Program for generating the global descriptor table.
;
; Each entry in the global descriptor table (GDT) consists of the following:
;
;  31        24 23   22   21   20   19             16 15  14  13 12  11   8 7          0
; +------------+---+-----+---+-----+-----------------+---+------+---+------+------------+ byte
; | base 31:24 | G | D/B | L | AVL | seg limit 19:16 | P | DPL  | S | type | base 23:16 |  4
; +------------+---+-----+---+-----+-----------------+---+------+---+------+------------+
;
;  31                                   16 15                                    0
; +------------------------------------------+------------------------------------------+ byte
; |            base address 15:00            |            segment limit 15:00           |  0
; +------------------------------------------+------------------------------------------+
; base/limit:
;     LIMIT (2 bytes, 4 bits) segment limit
;     BASE  (1 byte, 2 bytes) segment base address
;
; 1st flags:
;     P     (1 bit)           segment present (use 1, indicates segment is present in memory)
;     DPL   (2 bits)          descriptor privilege level (00 is highest privilege)
;     S     (1 bit)           descriptor type (0=system, 1=code or data)
;
; type flags:
;     TYPE  (4 bits)          segment type
;         code        (1 bit) 1 (this is a code segment) or 0
;
;     [if code segment]
;         conforming  (1 bit) 0 (not conforming [protects memory]) or 1 (conforming)
;         readable    (1 bit) 1 (readable) or 0 (execute-only)
;     [if data segment]
;         expand down (1 bit) 1 (allow segment to expand down) or 0
;         writeable   (1 bit) 1 (writeable) or 0 (read-only)
;
;         accessed    (1 bit) 0 (set to 1 once accessed)
;
; 2nd flags:
;     G     (1 bit)           granularity (left-shift limit by 3)
;     D/B   (1 bit)           default operation size (0=16-bit segment, 1=32-bit segment)
;     L     (1 bit)           64-bit code segment (IA-32e mode only)
;     AVL   (1 bit)           available for user by system software
;

gdt_start: ; We label the GDT start so it can be pointed later on in to in the GDT descriptor.

gdt_null:  ; The GDT must begin with a null segment of empty bytes.
  dd 0x0   ; `dd` declares a double word (4 bytes)
  dd 0x0   ; A GDT entry is 8 bytes long, or four words.

gdt_code:  ; The code segment descriptor.

  ; Base address : 0x0
  ; Segment limit: 0xfffff
  ; 1st  flags   : (present)    1 (privilege)     0                 0 (descriptor type)1 -> 1001b
  ; Type flags   : (code)       1 (conforming)    0 (readable)      1 (accessed)       0 -> 1010b
  ; 2nd  flags   : (granularity)1 (32-bit default)1 (64-bit segment)0 (available)      0 -> 1100b

  dw 0xffff                  ; Bytes 0-1: segment limit 15:00.
  dw 0x0                     ; Bytes 2-3: base address 15:00.
  db 0x0                     ; Byte 4: base address 23:16.
  db 10011010b               ; Byte 5: 1st flags and type flags.
  db 11001111b               ; Byte 6: 2nd flags and highest four bits of segment limit (0xf).
  db 0x0                     ; Byte 7: base address 31:24.

gdt_data:  ; The data segment descriptor.

  ; Same as code segment, except for type flags:
  ; Type flags: (code)0 (expand down)0 (writeable)1 (accessed)0 -> 0010b

  dw 0xffff
  dw 0x0
  db 0x0
  db 10010010b               ; Byte 5: 1st flags and type flags.
  db 11001111b
  db 0x0

gdt_end:   ; We label the GDT end for our GDT descriptor as well.

gdt_descriptor:

  ; GDT size   : gdt_end - gdt_start (but see comment below).
  ; GDT address: gdt_start

  dw gdt_end - gdt_start - 1 ; Bytes 2-5: GDT size (always 1 less than true size).
                             ; The GDT may reach a size of 65536 bytes if it has a full 8192
                             ; entries), but an unsigned int can only store 65535. Thus we subtract
                             ; 1 from the true size and the CPU knows the true size is 1 greater
                             ; than the size given in the GDT descriptor.
  dd gdt_start               ; Bytes 0-1: GDT address.

; Define some constants for the GDT segment descriptor offsets, which we will use later when
; specifying addresses in protected mode. These values are the offset into the GDT at which each
; segment entry will be found by the CPU. `equ` means that the assembler will replace every
; occurrence of the symbol with the value on the right. This is different from `db` which writes a
; byte of data directly into the assembly code on the spot.
CODE_SEG equ gdt_code - gdt_start ; 0x08
DATA_SEG equ gdt_data - gdt_start  ; 0x10
