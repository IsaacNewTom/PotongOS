#ifndef KERNEL_H
#define KERNEL_H

#define LINEAR_TEXT_BUFF_ADDR 0xB8000

/* returns the the value we need to write to the text buffer in little endian */
#define CHAR_AND_COLOR_ENDIANESS(chr, color) ((color << 8) | chr)

/* terminal width */
#define VGA_WIDTH 80
/* terminal height */
#define VGA_HEIGHT 20

/* text buffer colors enum */
typedef enum COLOR{
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
} COLOR;

void init_terminal();
void kernel_main();

#endif