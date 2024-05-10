// Main.c - makes LEDG0 on DE2-115 board blink if NIOS II is set up correctly
// for ECE 385 - University of Illinois - Electrical and Computer Engineering
// Author: Zuofu Cheng
#include "text_mode_vga_color.h"
#include "palette_test.h"

int main()
{
	textVGAColorScreenSaver();
//	textMEMTest();
//	paletteTest();
    return 1;
}
