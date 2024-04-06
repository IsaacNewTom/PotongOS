#include "idt.h"
#include "config.h"
#include "memory/memory.h"
#include "kernel.h"

struct idt_descriptor idt_descriptors[TOTAL_INTERRUPTS];
struct idtr_descriptor idtr_desc;

extern void load_idt(void* ptr);

/* interrupt 0 */
void idt_zero()
{
    print("Divide by zero error!\n");
}

/* sets up an idt descriptor's struct */
void set_idt_descriptor(int interrupt_num, void* address)
{
    struct idt_descriptor* idt_desc = &idt_descriptors[interrupt_num];
    idt_desc->offset_1 = (uint32_t)address & 0xffff;
    idt_desc->selector = KERNEL_CODE_SELECTOR;
    idt_desc->type_attributes = 0xEE; /* and not 0xE so we could set the present, DPL and storage segment bits */
    idt_desc->offset_2 = (uint32_t) address >> 16;
}

/* intializes the idt */
void init_idt()
{
    memset(idt_descriptors, 0, sizeof(idt_descriptors));
    
    idtr_desc.limit = sizeof(idt_descriptors) - 1;
    idtr_desc.base = (uint32_t)idt_descriptors;

    /* load up all of the interrupts */
    set_idt_descriptor(0, idt_zero);

    load_idt(&idtr_desc);
}