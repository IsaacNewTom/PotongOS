section .asm

;loads the idt 
global load_idt
load_idt:
    push ebp
    mov ebp, esp

    mov ebx, [ebp+8] ; the adress of the idtr
    lidt [ebx] ; load idt

    pop ebp
    ret