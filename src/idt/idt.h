#ifndef IDT_H
#define IDT_H   

#include <stdint.h>

/* interrupt descriptor struct */
struct idt_descriptor
{
    uint16_t offset_1;        /* offset bits 0 - 15 */
    uint16_t selector;        /* a code segment selector in our GDT */
    uint8_t  zero;            /* unused, set to 0 */
    uint8_t  type_attributes; /* descriptor type and attributes */
    uint16_t offset_2;        /* offset bits 16 - 31 */
}__attribute__((packed));


/* the idt register descriptor, used to store both the linear adderss and the limit of the IDT */
struct idtr_descriptor
{
    uint16_t limit; /* sizeof(IDT) - 1 */
    uint16_t base; /* base address of the IDT */
}__attribute__((packed));

void init_idt();
void int21h_handler();


#endif