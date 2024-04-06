#include <stdint.h>
#include <stddef.h>
#include "kernel.h"
#include "idt/idt.h"

uint16_t* video_memory = 0;
uint16_t current_terminal_row = 0;
uint16_t current_terminal_col = 0;

/* given the coords, character and color, it prints it out to the terminal */
void write_char_to_terminal_in_coords(int x, int y, char chr, COLOR color)
{
    video_memory[(y * VGA_WIDTH) + x] = CHAR_AND_COLOR_ENDIANESS(chr, color);
}

/* prints out a character to the correct position of the terminal */
void write_char_to_terminal(char chr, COLOR color)
{
    /* if we encounter a newline char */
    if (chr == '\n')
    {
        current_terminal_row++;
        current_terminal_col = 0;
        return;
    }
    write_char_to_terminal_in_coords(current_terminal_col, current_terminal_row, chr, color);
    current_terminal_col++;

    /* whenever we reach the end of the line, continue to the next one */
    if (current_terminal_col >= VGA_WIDTH){
        current_terminal_col = 0;
        current_terminal_row++;
    }
}

/* the function clears the terminal */
void init_terminal()
{
    int x, y;
    video_memory = (uint16_t*)(LINEAR_TEXT_BUFF_ADDR);
    
    /* iterate over the memory of the linear text buffer and clear it */
    for (y = 0; y < VGA_HEIGHT; y++)
    {
        for (x = 0; x < VGA_WIDTH; x++)
        {
            write_char_to_terminal_in_coords(x, y, ' ', BLACK);
        }
    }
}

/* returns the length of a string */
size_t strlen(const char* str)
{
    size_t len = 0;

    while (str[len]){
        len++;
    }

    return len;
}

void print(const char* str)
{
    size_t i, len = strlen((str));

    for (i = 0; i < len; i++)
        write_char_to_terminal(str[i], WHITE);
}

/* the kernel's main function */
void kernel_main()
{
    init_terminal();
    print("Hello, world!\n");

    /* intialize the interrupt descriptor table */
    init_idt();
    print("Initialized the IDT!\n");    
}