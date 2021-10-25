;
; A simple routine for entering the kernel at the function `main`.
;

[bits 32]     ; We're in protected mode, so use 32-bit instructios.
[extern main] ; Expect `main` to be defined in an assembly file assembled alongside this one.

jmp main      ; Enter the main function.
jmp $         ; When control returns from the kernel, hang.
