[BITS 16]
[ORG 0x7e00]
;still in real mode

Start:
    ;The same value we've received earlier by testing the disk extension
    mov [DriveID], dl

    ;CPUID - EAX=80000000h: Get Highest Extended Function Implemented
    mov eax, 0x80000000
    cpuid ;Highest extended CPUID Input
    cmp eax, 0x80000001
    jb NotSupported

    ;CHECK IF CPU IS LONG MODE CAPABLE
    ;CPUID - EAX=80000001h: Extended Processor Info and Feature Bits
    mov eax, 0x80000001
    cpuid
    test edx, (1<<29) ;check if long mode is supported
    jz NoLongMode
    test edx, (1<<26)
    jz NoLongMode ;check if 1GB pages are supported

LoadKernel:
    ;INT 13 AH=42: Read Sectors From Drive
    mov dl, [DriveID]
    mov si, ReadPacket ;offset
    mov word[si], 0x10 ;size (16 bytes)
    mov word[si+2], 100 ;number of sectors
    mov word[si+4], 0x0 ;offset of the kernel
    mov word[si+6], 0x1000 ;segment
    mov dword[si+8], 6 ;sector 6
    mov dword[si+0xc], 0
    mov ah, 0x42
    int 0x13
    jc ReadError

GetMemoryMap:
    ;INT 15h / AH = E820h - get system memory map
    ; returns a list of memory blocks free to use
    xor ebx, ebx
    mov eax, 0xE820
    mov edx, 0x534D4150 ;magic number ("SMAP") - used by the BIOS to verify the caller is requesting the system map info, to be returned in es:di
    mov ecx, 20 ;len of memory block
    mov edi, 0x9000 ;buffer
    int 0x15
    jc NoMemoryMap

GetMemoryInfo:
;the output from 15h/E820:
;CF indicates no errors
;ES:DI has the returned address range pointer
    add edi, 20 ;point to next memory address
    mov eax, 0xE820
    mov edx, 0x534D4150 ;magic number ("SMAP")
    mov ecx, 20 ;len of memory block
    int 0x15
    jc TestA20Line
    
    test ebx, ebx
    jnz GetMemoryInfo

; The A20 line is a physical wire or signal that controls whether address bit 20 (A20) is allowed to pass through, which affects memory wraps.
TestA20Line:
    ;Check if A20 line is turned on by default
    mov ax, 0xFFFF
    mov es, ax
    mov word[ds:0x7C00], 0xA200 ;0:0x7C00 = 0x7C00
    cmp word[es:0x7C10], 0xA200 ;0xFFFF:0x7C00 = 0xFFFF*16 + 0X7C10 = 0x107C00
    ;if the memory addresses are different, we know that A20 is turned off, since we can access
    ;memory addresses over 2^20 (the 20th bit wasn't truncated)
    jne A20LineOn
    mov word[0x7C00], 0xB200
    cmp word[es:0x7C10], 0xB200
    je End
A20LineOn:
    xor ax, ax
    mov es, ax

SetVideoMode:
    ;INT 10h / AH = 0 - set video mode
    mov ax, 3 ;text mode - 80x25
    int 0x10

    ;We are now starting to switch to long mode.
    ;We have to turn off context switches so we wouldn't get interrupted (clear interrup flag)
    cli

    ;load the GDT
    lgdt [GdtPtr]
    ;load the IDT
    lidt [IdtPtr]

    ;Enable protected mode
    mov eax, cr0
    or eax, 1
    mov cr0, eax

    ;Load the code segment
    jmp 8:ProtectedModeEntry

;long mode errors
NotSupported:
End:
    hlt
    jmp End
;Errors
NoLongMode:
    ;INT 10h / AH = 13h - write string
    mov ah, 0x13
    mov al, 1 ;cursor placement
    mov bx, 0xc ;light red
    mov cx, NoLongModeLen
    xor dx, dx ;row, col
    mov bp, NoLongModeMsg ;address of the string
    int 0x10
    jmp End
NoMemoryMap:
    ;INT 10h / AH = 13h - write string
    mov ah, 0x13
    mov al, 1 ;cursor placement
    mov bx, 0xc ;light red
    mov cx, NoMemoryMapLen
    xor dx, dx ;row, col
    mov bp, NoMemoryMapMsg ;address of the string
    int 0x10
    jmp End
ReadError:
    ;INT 10h / AH = 13h - write string
    mov ah, 0x13
    mov al, 1 ;cursor placement
    mov bx, 0xc ;light red
    mov cx, ReadErrorLen
    xor dx, dx ;row, col
    mov bp, ReadErrorMsg ;address of the string
    int 0x10
    jmp End



[BITS 32]
ProtectedModeEntry:
    ;load the data segment register
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov esp, 0x7c00

    mov byte[0xb8000], 'T'
    mov byte[0xb8001], 0xa

EndProtectedMode:
    hlt
    jmp EndProtectedMode

;Variables
;Strings
Message: db "Booted!"
MessageLen: equ $-Message
NoLongModeMsg: db "CPU doesn't support long mode..."
NoLongModeLen: equ $-NoLongModeMsg
NoMemoryMapMsg: db "Error getting memory map..."
NoMemoryMapLen: equ $-NoMemoryMapMsg
ReadErrorMsg: db "Error reading the loader..."
ReadErrorLen: equ $-ReadErrorMsg
ReadPacket: times 16 db 0
;The disk extension value
DriveID: db 0

;The GDT - the descriptors of the segments
GdtStruct:  dq 0
CodeSegment: ;for a proper explanation of this code, see GDT descriptors
        dw 0xffff ;the first 2 bytes indicate the size of the segment
        dw 0 ;those 24 bits indicate the base address
        dw 0
        db 0
        db 0x9a ;(10011010), present bit = 1, dpl (descriptor priv level) = 0, s (system descriptor) = 1, type = 1010, R non-comforming
        db 0xcf ;G = 1, DB = 1, NULL, A = 0, LIMIT = max (1111)

DataSegment:
        dw 0xffff
        dw 0 
        dw 0
        db 0
        db 0x92 ; type = 0010, RW
        db 0xcf 

GdtSize: equ $-GdtStruct

; The variable is split into 2: the size of the GDT - 1, and the address of the GDT
GdtPtr: dw GdtSize - 1
        dd  GdtStruct

;Both the address and the size is zero, since we dont want to use interrupts yet
IdtPtr: dw 0
        dd 0