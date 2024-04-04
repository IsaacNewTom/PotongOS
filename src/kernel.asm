[BITS 32]
CODE_SEG equ 0x08
DATA_SEG equ 0x10

bit_32:
    ; set the segments while in protected mode
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov ebp, 0x00200000
    mov esp, ebp

    ; enable the A20 line, as long as the cipset has a FAST A20 option 
    in al, 0x92
    or al, 2
    out 0x92, al

    jmp $