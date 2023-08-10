;Directives
;16 bit mode for real mode and org memory address at 0x7c00 (BIOS loads the boot code from this address)
;also meaning the stack space would be between 0 and 0x7bfe
[BITS 16]
[ORG 0x7c00]

start:
    ;zero out the registers and set up the stack
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00 ;move SP to ORG
    STI; #set the interrupt flag

TestDiskExtension:
    ;make sure CPU supports logical block addressing 
    ;INT 13h AH=41h: Check Extensions Present
    mov [DriveID], dl ;dl holds the drive ID  when the BIOS transfers control to the boot code
    mov ah, 0x41
    mov bx, 0x55aa
    int 0x13
    jc LbaNotSupported
    cmp bx, 0xaa55 ;the carry flag will be set if Extensions are not supported
    jne LbaNotSupported

PrintMessage:
    mov ah, 0x13 ;int 0x10, type 13
    mov al, 1
    mov bx, 0x17
    xor dx, dx
    mov bp, Message
    mov cx, MessageLen
    int 0x10

End:
    hlt
    jmp End


;Errors
LbaNotSupported:
    ;INT 10h / AH = 13h - write string
    mov ah, 0x13
    mov al, 1 ;cursor placement
    mov bx, 0xc ;light red
    mov cx, LbaNotSupportedLen
    xor dx, dx ;row, col
    mov bp, LbaNotSupportedMsg ;address of the string
    int 0x10
    jmp End


;Variables
Message:    db "Hello, welcome to PotongOS! :)"
MessageLen: equ $-Message
DriveID: db 0
LbaNotSupportedMsg: db "Disk Extension error...    "
LbaNotSupportedLen: equ $-LbaNotSupportedMsg

;fill the memory between the end of the message up 0x1be with zeroes
times (0x1be - ($-$$)) db 0

    db 80h ;the boot indicator
    db 0, 2, 0 ;starting CHS
    db 0f0h ;the partition type
    db 0ffh, 0ffh, 0ffh ;ending CHS
    dd 1 ;logical block addr of the next sector
    dd (20*16*63-1) ;size (10mb, only for the BIOS)

    ;zero out the other entries
    times (16*3) db 0

    ;The magic number
    db 0x55
    db 0xaa