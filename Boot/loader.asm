;still in real mode
[BITS 16]
[ORG 0x7e00]

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
    mov ah, 42h
    int 0x13
    jc ReadError

GetMemoryMap:
    ;INT 15h / AH = E820h - get system memory map
    ; returns a list of memory blocks free to use
    xor ebx, ebx
    mov edx, 0x534D4150 ;magic number ("SMAP") - used by the BIOS to verify the caller is reuqestign the system map info, to be returned in es:di
    mov eax, 0xE820
    mov ecx, 20 ;len of memory block
    mov edi, 0x9000 ;buffer
    int 0x15
    jc NoMemoryMap

GetMemoryInfo:
;the output from 15h/E820:
;CF indicates no errors
;ES:DI has the returned address range pointer
    add edi, 20 ;point to next memory address
    mov edx, 0x534D4150 ;magic number ("SMAP")
    mov eax, 0xE820
    mov ecx, 20 ;len of memory block
    int 0x15
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

    mov si, Message
    mov ax, 0xB800
    mov es, ax
    xor di, di
    mov cx, MessageLen

PrintMessage:
    mov al, [si]
    mov [es:di], al
    mov byte[es:di+1], 0xa

    add di, 2
    add si, 1
    loop PrintMessage


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
NotSupported:
End:
    hlt
    jmp End


;Variables
DriveID: db 0
Message: db "Ready for long mode :)"
MessageLen: equ $-Message
NoLongModeMsg: db "CPU does not support long mode..."
NoLongModeLen: equ $-NoLongModeMsg
NoMemoryMapMsg: db "Error getting memory map..."
NoMemoryMapLen: equ $-NoMemoryMapMsg