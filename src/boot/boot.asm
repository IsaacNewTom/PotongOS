ORG 0x7c00
BITS 16

;for the BIOS parameter block, the null bytes would be automatically filled when booting
CODE_SEG equ gdt_cs - gdt_start
DATA_SEG equ gdt_data - gdt_start


_start:
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
        jmp CODE_SEG:bit_32 ; jump to the 32bit code


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
    


;---------------------------
; Protected mode as of here |
;---------------------------
[BITS 32]
; load the kernel
bit_32:
    mov eax, 1 ; starting sector
    mov ecx, 100 ; since we have 100 sectors of nullbytes in the kernel
    mov edi, 0x0100000 ; the addr we want to load into
    call ata_intr_lba_read
    jmp CODE_SEG:0x0100000

; read through the ATA interface
; dx - port
ata_intr_lba_read:
    mov ebx, eax ;Backup the LBA
    
    ; send the 8 highest bits of the lba to the hard disk driver
    shr eax, 24 ; eax would now hold those 8 bits
    or eax, 0xE0 ; master drive and not slave
    mov dx, 0x1F6
    out dx, al

    ; send the number of sectors we want to read
    mov eax, ecx
    mov dx, 0x1F2 
    out dx, al

    ; send the remaining LBA
    mov eax, ebx
    mov dx, 0x1F3
    out dx, al

    ; restore the original LBA and send the 24 highest bits
    mov dx, 0x1F4
    mov eax, ebx
    shr eax, 8
    out dx, al

    ; send the 24 highest bits
    mov dx, 0x1F5
    mov eax, ebx
    shr eax, 16
    out dx, al

    mov dx, 0x1F7
    mov al, 0x20
    out dx, al


    ; read all of the sectors into memory
    .next_sector:
        push ecx
    
    ; check if we need to read more
    .need_to_read:
        mov dx, 0x1F7
        in al, dx
        test al, 8
        jz .need_to_read
        
        ; reading 256 words at a time
        mov ecx, 256
        mov dx, 0x1F0
        rep insw ; input from dx and load into edi
        pop ecx
        loop .next_sector

        ret

times 510 - ($ - $$) db 0 ;the BL's size should be 512 bytes whole
dw 0xAA55 ;the BL's signature
