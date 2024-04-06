#include "memory.h"

/* fills the first *size* bytes of the memory area pointed to by ptr with the constant byte c */
void* memset(void* ptr, int c, size_t size)
{
    char* helper_ptr = (char*) ptr;
    int i;

    for (i = 0; i < size; i++)
    {
        helper_ptr[i] = (char)c;
    }

    return ptr;
}