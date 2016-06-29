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
extern void init_timer(void);    // in timer_interrupts.c


__declspec(noreturn) int main(void)
{
#ifdef USE_SERIAL_PORT
    UartInit();
#endif

    printf("\nDS-5 ARMv8 Startup Example, using ARM Compiler 6\n\n");
    init_timer();

    for(;;) {} //loop forever
}
