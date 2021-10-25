;
; A routine for printing the string pointed to by B register.
;

VIDEO_MEMORY equ 0xb8000
WHITE_ON_BLACK equ 0x0f

print_string_pm:
	pusha
	mov edx, VIDEO_MEMORY

print_string_pm_loop:
	mov al, [ebx]           ; Store first character ASCII code in `al`.
	mov ah, WHITE_ON_BLACK  ; Store first character color in `ah`.

	cmp al, 0               ; Reaching null character means end of string.
	je  print_string_pm_end

	mov [edx], ax           ; Store character and attributes in video memory.

	add ebx, 1              ; Move to next character in string.
	add edx, 2              ; Move to next cell in video memory.

	jmp print_string_pm_loop

print_string_pm_end:
	popa
	ret
