#ifndef MEMORY_H
#define MEMORY_H
#include <stddef.h>

/* fills the first *size* bytes of the memory area pointed to by ptr with the constant byte c */
void* memset(void* ptr, int c, size_t size);

#endif