/* 
 * Some very basic kernel code in C.
 */

void main() {
    // The first position of video memory (row 0, col 0) is at memory address 0xb8000.
    // We store a pointer to this byte. `(char*) ` is necessary before 0xb8000 to typecast
    // it from a 32-bit int to a pointer-to-char.
    char* video_memory = (char*) 0xb8000;

    // We assign the value 'X' to the byte in memory pointed to by `video_memory`.
    // Note: char, byte and uint8 all contain 8 bits of memory, they just mean different things.
    *video_memory = 'X';
}
