section .asm

extern int21h_handler

;loads the idt 
global load_idt
global int21h

load_idt:
    push ebp
    mov ebp, esp

    mov ebx, [ebp+8] ; the adress of the idtr
    lidt [ebx] ; load idt

    pop ebp
    
    
int21h:
    cli
    pushad
    call int21h_handler
    popad
    sti
    iret