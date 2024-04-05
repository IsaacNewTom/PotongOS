#include "kernel.h"

uint16_t* video_memory = 0;

void init_terminal()
{
    int x, y;
    video_memory = (uint16_t*)(LINEAR_TEXT_BUFF_ADDR);
    
    for (y = 0; y < VGA_HEIGHT; y++)
    {
        for (x = 0; x < VGA_WIDTH; x++)
        {
            video_memory[(y * VGA_WIDTH) + x] = TERMINAL_WRITE_CHAR(' ', 0);
        }
    }
}

void kernel_main()
{
    init_terminal();
    video_memory[0] = TERMINAL_WRITE_CHAR('B', YELLOW);
    
}