#ifndef IO_H
#define IO_H
/* see io.asm for the source */
/* reads a byte from the given port*/
unsigned char insb(unsigned short port);
/* reads a word from the given port */
unsigned short insw(unsigned short port);

/* writes the value (byte) to the given port */
void outb(unsigned short port, unsigned char value);
/* writes the value (word) to the given port */
void outw(unsigned short port, unsigned short value);

#endif