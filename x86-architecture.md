From wikipedia: x86 instruction listings

```
Original 8086/8088 instruction set
Instruction Meaning Notes   Opcode
AAA ASCII adjust AL after addition  used with unpacked binary-coded decimal 0x37
AAD ASCII adjust AX before division 8086/8088 datasheet documents only base 10 version of the AAD instruction (opcode 0xD5 0x0A), but any other base will work. Later Intel's documentation has the generic form too. NEC V20 and V30 (and possibly other NEC V-series CPUs) always use base 10, and ignore the argument, causing a number of incompatibilities 0xD5
AAM ASCII adjust AX after multiplication    Only base 10 version (Operand is 0xA) is documented, see notes for AAD  0xD4
AAS ASCII adjust AL after subtraction       0x3F
ADC Add with carry  destination = destination + source + carry_flag 0x10…0x15, 0x80…0x81/2, 0x82…0x83/2 (since 80186)
ADD Add (1) r/m += r/imm; (2) r += m/imm;   0x00…0x05, 0x80/0…0x81/0, 0x82/0…0x83/0 (since 80186)
AND Logical AND (1) r/m &= r/imm; (2) r &= m/imm;   0x20…0x25, 0x80…0x81/4, 0x82…0x83/4 (since 80186)
CALL    Call procedure  push eip; eip points to the instruction directly after the call 0x9A, 0xE8, 0xFF/2, 0xFF/3
CBW Convert byte to word        0x98
CLC Clear carry flag    CF = 0; 0xF8
CLD Clear direction flag    DF = 0; 0xFC
CLI Clear interrupt flag    IF = 0; 0xFA
CMC Complement carry flag       0xF5
CMP Compare operands        0x38…0x3D, 0x80…0x81/7, 0x82…0x83/7 (since 80186)
CMPSB   Compare bytes in memory     0xA6
CMPSW   Compare words       0xA7
CWD Convert word to doubleword      0x99
DAA Decimal adjust AL after addition    (used with packed binary-coded decimal) 0x27
DAS Decimal adjust AL after subtraction     0x2F
DEC Decrement by 1      0x48…0x4F, 0xFE/1, 0xFF/1
DIV Unsigned divide (1) AX = DX:AX / r/m; resulting DX = remainder (2) AL = AX / r/m; resulting AH = remainder  0xF7/6, 0xF6/6
ESC Used with floating-point unit       0xD8..0xDF
HLT Enter halt state        0xF4
IDIV    Signed divide   (1) AX = DX:AX / r/m; resulting DX = remainder (2) AL = AX / r/m; resulting AH = remainder  0xF7/7, 0xF6/7
IMUL    Signed multiply (1) DX:AX = AX * r/m; (2) AX = AL * r/m 0x69, 0x6B (both since 80186), 0xF7/5, 0xF6/5, 0x0FAF (since 80386)
IN  Input from port (1) AL = port[imm]; (2) AL = port[DX]; (3) AX = port[imm]; (4) AX = port[DX];   0xE4, 0xE5, 0xEC, 0xED
INC Increment by 1      0x40…0x47, 0xFE/0, 0xFF/0
INT Call to interrupt       0xCC, 0xCD
INTO    Call to interrupt if overflow       0xCE
IRET    Return from interrupt       0xCF
Jcc Jump if condition   (JA, JAE, JB, JBE, JC, JE, JG, JGE, JL, JLE, JNA, JNAE, JNB, JNBE, JNC, JNE, JNG, JNGE, JNL, JNLE, JNO, JNP, JNS, JNZ, JO, JP, JPE, JPO, JS, JZ)    0x70…0x7F, 0x0F80…0x0F8F (since 80386)
JCXZ    Jump if CX is zero      0xE3
JMP Jump        0xE9…0xEB, 0xFF/4, 0xFF/5
LAHF    Load FLAGS into AH register     0x9F
LDS Load pointer using DS       0xC5
LEA Load Effective Address      0x8D
LES Load ES with pointer        0xC4
LOCK    Assert BUS LOCK# signal (for multiprocessing)   0xF0
LODSB   Load string byte    if (DF==0) AL = *SI++; else AL = *SI--; 0xAC
LODSW   Load string word    if (DF==0) AX = *SI++; else AX = *SI--; 0xAD
LOOP/LOOPx  Loop control    (LOOPE, LOOPNE, LOOPNZ, LOOPZ) if (x && --CX) goto lbl; 0xE0…0xE2
MOV Move    copies data from one location to another, (1) r/m = r; (2) r = r/m; 0xA0...0xA3
MOVSB   Move byte from string to string 
if (DF==0) 
  *(byte*)DI++ = *(byte*)SI++; 
else 
  *(byte*)DI-- = *(byte*)SI--;
0xA4
MOVSW   Move word from string to string 
if (DF==0) 
  *(word*)DI++ = *(word*)SI++; 
else 
  *(word*)DI-- = *(word*)SI--;
0xA5
MUL Unsigned multiply   (1) DX:AX = AX * r/m; (2) AX = AL * r/m;    0xF7/4, 0xF6/4
NEG Two's complement negation   r/m *= -1;  0xF6/3…0xF7/3
NOP No operation    opcode equivalent to XCHG EAX, EAX  0x90
NOT Negate the operand, logical NOT r/m ^= -1;  0xF6/2…0xF7/2
OR  Logical OR  (1) r/m |= r/imm; (2) r |= m/imm;   0x08…0x0D, 0x80…0x81/1, 0x82…0x83/1 (since 80186)
OUT Output to port  (1) port[imm] = AL; (2) port[DX] = AL; (3) port[imm] = AX; (4) port[DX] = AX;   0xE6, 0xE7, 0xEE, 0xEF
POP Pop data from stack r/m = *SP++; POP CS (opcode 0x0F) works only on 8086/8088. Later CPUs use 0x0F as a prefix for newer instructions.  0x07, 0x0F(8086/8088 only), 0x17, 0x1F, 0x58…0x5F, 0x8F/0
POPF    Pop FLAGS register from stack   FLAGS = *SP++;  0x9D
PUSH    Push data onto stack    *--SP = r/m;    0x06, 0x0E, 0x16, 0x1E, 0x50…0x57, 0x68, 0x6A (both since 80186), 0xFF/6
PUSHF   Push FLAGS onto stack   *--SP = FLAGS;  0x9C
RCL Rotate left (with carry)        0xC0…0xC1/2 (since 80186), 0xD0…0xD3/2
RCR Rotate right (with carry)       0xC0…0xC1/3 (since 80186), 0xD0…0xD3/3
REPxx   Repeat MOVS/STOS/CMPS/LODS/SCAS (REP, REPE, REPNE, REPNZ, REPZ) 0xF2, 0xF3
RET Return from procedure   Not a real instruction. The assembler will translate these to a RETN or a RETF depending on the memory model of the target system.  
RETN    Return from near procedure      0xC2, 0xC3
RETF    Return from far procedure       0xCA, 0xCB
ROL Rotate left     0xC0…0xC1/0 (since 80186), 0xD0…0xD3/0
ROR Rotate right        0xC0…0xC1/1 (since 80186), 0xD0…0xD3/1
SAHF    Store AH into FLAGS     0x9E
SAL Shift Arithmetically left (signed shift left)   (1) r/m <<= 1; (2) r/m <<= CL;  0xC0…0xC1/4 (since 80186), 0xD0…0xD3/4
SAR Shift Arithmetically right (signed shift right) (1) (signed) r/m >>= 1; (2) (signed) r/m >>= CL;    0xC0…0xC1/7 (since 80186), 0xD0…0xD3/7
SBB Subtraction with borrow alternative 1-byte encoding of SBB AL, AL is available via undocumented SALC instruction    0x18…0x1D, 0x80…0x81/3, 0x82…0x83/3 (since 80186)
SCASB   Compare byte string     0xAE
SCASW   Compare word string     0xAF
SHL Shift left (unsigned shift left)        0xC0…0xC1/4 (since 80186), 0xD0…0xD3/4
SHR Shift right (unsigned shift right)      0xC0…0xC1/5 (since 80186), 0xD0…0xD3/5
STC Set carry flag  CF = 1; 0xF9
STD Set direction flag  DF = 1; 0xFD
STI Set interrupt flag  IF = 1; 0xFB
STOSB   Store byte in string    if (DF==0) *ES:DI++ = AL; else *ES:DI-- = AL;   0xAA
STOSW   Store word in string    if (DF==0) *ES:DI++ = AX; else *ES:DI-- = AX;   0xAB
SUB Subtraction (1) r/m -= r/imm; (2) r -= m/imm;   0x28…0x2D, 0x80…0x81/5, 0x82…0x83/5 (since 80186)
TEST    Logical compare (AND)   (1) r/m & r/imm; (2) r & m/imm; 0x84, 0x84, 0xA8, 0xA9, 0xF6/0, 0xF7/0
WAIT    Wait until not busy Waits until BUSY# pin is inactive (used with floating-point unit)   0x9B
XCHG    Exchange data   r :=: r/m; A spinlock typically uses xchg as an atomic operation. (coma bug).   0x86, 0x87, 0x91…0x97
XLAT    Table look-up translation   behaves like MOV AL, [BX+AL]    0xD7
XOR Exclusive OR    (1) r/m ^= r/imm; (2) r ^= m/imm;   0x30…0x35, 0x80…0x81/6, 0x82…0x83/6 (since 80186)
```
