[BITS 16]
[ORG 0x7c00]
; The boot code starts at 0x7c00 - the stack would be between 0 and 0x7bfe

start:
    ; Zero out the registers and set up the stack
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00 ; move SP to ORG
    STI; # set the interrupt flag

PrintMessage:
    mov ah, 0x13 ;int 0x10, 13
    mov al, 1
    mov bx, 0x17
    xor dx, dx
    mov bp, Message
    mov cx, MessageLen
    int 0x10

End:
    hlt
    jmp End

Message:    db "Hello, welcome to PotongOS!"
MessageLen: equ $-Message

;fill the memory between the end of the message up 0x1be with zeroes
times (0x1be - ($-$$)) db 0

    db 80h ;the boot indicator
    db 0, 2, 0 ;starting CHS
    db 0f0h ;the partition type
    db 0ffh, 0ffh, 0ffh ;ending CHS
    dd 1 ;LBA address of the next sector
    dd (20*16*63-1) ;size (10mb, only for the BIOS)

    ;zero out the other entries
    times (16*3) db 0

    ;The magic number
    db 0x55
    db 0xaa