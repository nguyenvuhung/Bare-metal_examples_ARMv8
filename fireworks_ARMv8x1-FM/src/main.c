/*
 * ARMv8 - Main
 *
 * Copyright (c) 2011-2016 ARM Ltd.  All rights reserved.
 *
 */

#include <stdlib.h>
#include <stdio.h>

#ifdef USE_SERIAL_PORT
  #include "uart.h"
#endif

#ifdef USE_SERIAL_PORT
extern void UartInit(void);
#endif


// declaration of 'extern' functions
extern void setup_screen(void);  // in fireworks.c
extern void init_timer(void);    // in timer_interrupts.c
extern void fireworks(void);     // in fireworks.c


__declspec(noreturn) int main(void)
{
#ifdef USE_SERIAL_PORT
    UartInit();
#endif

    printf("\nDS-5 ARMv8 Fireworks Example, using ARM Compiler 6\n\n");
    printf("Click on USERSW1 to stop/restart the Banner\n\n");
    setup_screen();    // in fireworks.c
    init_timer();

    //run the fireworks!!
    fireworks();

    for(;;) {} //loop forever
}
