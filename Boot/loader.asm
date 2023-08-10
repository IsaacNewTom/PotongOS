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


PrintMessage:
    mov ah, 0x13 ;int 0x10, type 13
    mov al, 1
    mov bx, 0x17
    xor dx, dx
    mov bp, Message
    mov cx, MessageLen
    int 0x10

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
NotSupported:
End:
    hlt
    jmp End


;Variables
DriveID: db 0
Message: db "Hello, welcome to PotongOS! :)"
MessageLen: equ $-Message