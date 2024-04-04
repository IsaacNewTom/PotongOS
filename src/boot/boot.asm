ORG 0x7c00
BITS 16

;for the BIOS parameter block, the null bytes would be automatically filled when booting
CODE_SEG equ gdt_cs - gdt_start
DATA_SEG equ gdt_data - gdt_start


startup:
    jmp short set_cs
    nop
    times 33 db 0

; set up the segments, so the BIOS won't set them up for us
set_cs:
    jmp 0:set_segments
    
set_segments:
    cli ; clear interrupt flag
    ; ds, es, ss and sp
    mov ax, 0x0
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00
    sti ; enable interrupts

    .protected_mode:
        cli
        lgdt[gdt_descriptor]
        mov eax, cr0
        or eax, 0x1
        mov cr0, eax
        ; jmp CODE_SEG:bit_32
        jmp $


; THE GDT
gdt_start:
gdt_null:
    dd 0x0
    dd 0x0

;offset 0x8
gdt_cs:          ; <--- CS should point to this
    dw 0xffff    ; first 16 bits of the segment limits
    dw 0         ; first 16 bits of the base
    db 0         ; bits 16-23
    db 0x9a      ; access byte
    db 11001111b ; high and low bit flags
    db 0         ; base 24-31 bits

;offset 0x10
gdt_data:        ; DS, SS, FS, GS and ES
    dw 0xffff    ; first 16 bits of the segment limits
    dw 0         ; first 16 bits of the base
    db 0         ; bits 16-23
    db 0x92      ; access byte
    db 11001111b ; high and low bit flags
    db 0         ; base 24-31 bits

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start
    

times 510 - ($ - $$) db 0 ;the BL's size should be 512 bytes whole
dw 0xAA55 ;the BL's signature
