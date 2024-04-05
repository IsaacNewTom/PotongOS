#ifndef KERNEL_H
#define KERNEL_H
#include <stdint.h>

#define LINEAR_TEXT_BUFF_ADDR 0xB8000

/* returns the the value in little endian we need to write to the text buffer to print the given char with the given color */
#define TERMINAL_WRITE_CHAR(chr, color) ((color << 8) | chr)

#define VGA_WIDTH 80
#define VGA_HEIGHT 20

enum COLOR{
    BLACK,
    BLUE,
    GREEN,
    CYAN,
    RED,
    PURPLE,
    BROWN,
    GRAY,
    DARK_GRAY,
    LIGHT_BLUE,
    LIGHT_GREEN,
    LIGHT_CYAN,
    LIGHT_RED,
    LIGHT_PURPLE,
    YELLOW,
    WHITE
};


void kernel_main();

#endif