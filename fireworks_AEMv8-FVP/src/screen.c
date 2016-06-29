/* Bare-metal fireworks example for VE FVP model */

/* Screen driver, derived from brot.c */

/* Copyright (C) ARM Limited, 2011-2013. All rights reserved. */


// Configure LCD for VE platforms
void init_lcd_ve( void )
{
    // VE System Register 32-bit word offsets
    const int VE_SYS_CFG_DATA = (0xA0/4);
    const int VE_SYS_CFG_CTRL = (0xA4/4);

    volatile unsigned int*  ve_sysreg = (unsigned int*) 0x1C010000;  // CS3 + 0x010000

    // Set CLCD clock
    //   SYS_CFG_DATA sets oscillator rate value as 5.4MHz
    //   SYS_CFG_CTRL( start=1 | write=1 | function=1 | site=0 | position=0 | device=1 )
    ve_sysreg[ VE_SYS_CFG_DATA ] = 5400000;
    ve_sysreg[ VE_SYS_CFG_CTRL ] = 0x80000000 | (1<<30) | (1<<20) | (0<<16) | (0<<12) | (1<<0);

    // Set DVI mux for correct MMB
    //   SYS_CFG_CTRL( start=1 | write=1 | function=7 | site=0 | position=0 | device=0 )
    ve_sysreg[ VE_SYS_CFG_DATA ] = 0;  // VE_DVI_MUX
    ve_sysreg[ VE_SYS_CFG_CTRL ] = 0x80000000 | (1<<30) | (7<<20) | (0<<16) | (0<<12) | (0<<0);
}


// Configure PL111 CLCD
void init_pl111( unsigned int  width,
                 unsigned int  height,
                 unsigned int  frame_base )
{
    volatile unsigned int*  clcd  = (unsigned int*) 0x1C1F0000;  // CS3 + 0x1F0000

    // PL111 register offsets (32-bit words)
    const int PL111_TIM0 = (0x00/4);
    const int PL111_TIM1 = (0x04/4);
    const int PL111_TIM2 = (0x08/4);
    const int PL111_TIM3 = (0x0C/4);
    const int PL111_UBAS = (0x10/4);
    const int PL111_LBAS = (0x14/4);
    const int PL111_CNTL = (0x18/4);
    const int PL111_IENB = (0x1C/4);

    // Timing number for an 8.4" LCD screen for use on a VGA screen
    unsigned int TIM0_VAL = ( (((width/16)-1)<<2) | (63<<8) | (31<<16) | (63<<8) );
    unsigned int TIM1_VAL = ( (height - 1) | (24<<10) | (11<<16) | (9<<24) );
    unsigned int TIM2_VAL = ( (0x7<<11) | ((width - 1)<<16) | (1<<26) );

    // Program the CLCD controller registers and start the CLCD
    clcd[ PL111_TIM0 ] = TIM0_VAL;
    clcd[ PL111_TIM1 ] = TIM1_VAL;
    clcd[ PL111_TIM2 ] = TIM2_VAL;
    clcd[ PL111_TIM3 ] = 0;
    clcd[ PL111_UBAS ] = frame_base;
    clcd[ PL111_LBAS ] = 0;
    clcd[ PL111_IENB ] = 0;

    // Set the control register: 16BPP 5:6:5, Power OFF
    clcd[ PL111_CNTL ] = (1<<0) | (6<<1) | (1<<5);

    // Power ON
    clcd[ PL111_CNTL ] |= (1<<11);
}


void init_screen(unsigned int screen_buffer, unsigned int width, unsigned int height)
{
    init_lcd_ve();
    init_pl111( width, height, screen_buffer);
}
