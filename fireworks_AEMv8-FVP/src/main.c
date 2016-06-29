/*
 * ARMv8 - Main
 *
 * Copyright (c) 2011-2016 ARM Ltd.  All rights reserved.
 *
 */

#include <stdlib.h>
#include <stdio.h>

#include "v8_aarch64.h"
#include "MP_Mutexes.h"
#include "GICv3.h"
#include "GICv3_gicc.h"
#include "supportfuncs.h"

#ifdef USE_SERIAL_PORT
  #include "uart.h"
#endif

// compile-time control for the number of CPUs in the cluster
static const int nCPUs = 4;

/*
 * per-thread space for use by the ARM libraries
 *
 * 24 is a magic number from the ARM libc documentation (the
 * docs actually say 96 (AArch32) or 192 (AArch64) bytes, but
 * the requirement is 24 pointers-worth of aligned space)
 */
static void *user_perthread_libspace[nCPUs][24];

static unsigned int cpu_finished_count = 0;

/*
 * need a printf lock to stop CPUs fighting when they use the same
 * output device
 */
mutex print_lock __attribute__ ((aligned (64)));

#ifdef USE_SERIAL_PORT
extern void UartInit(void);
#endif


// declaration of 'extern' functions
extern void setup_screen(void);  // in fireworks.c
extern void init_timer(void);    // in timer_interrupts.c
extern void fireworks(int id);   // in fireworks.c


// Called by the C library to get the address of the per-thread libspace
// Return a separate space for each CPU
void *__user_perthread_libspace(void)
{
    return user_perthread_libspace[GetCPUID()];
}


/*
 * void MainApp(void)
 *
 *    called by all CPUs to run SMP applications, this is the
 *    application start point for all secondary CPUs, and is called 
 *    after other startup code has executed on the primary CPU
 *
 * Inputs
 *   <none>
 *
 * Returns
 *   <function does not return>
 */
__declspec(noreturn) void MainApp(void)
{
    unsigned int id;

    id = GetCPUID();

    if (id >= nCPUs)
    {
      _mutex_acquire(&print_lock);
      printf("Error: More CPU cores are running than the maximum this program expects\n");
      printf("Change the value of nCPUs.  Exiting...\n");
      _mutex_release(&print_lock);
      exit(1);
    }

#ifdef SMP
    if (id == 1)
    {
      _mutex_acquire(&print_lock);
      printf("Running Banner on CORE1\n");
      printf("Other secondary cores sleep\n");
      _mutex_release(&print_lock);
    }
    if (id > 1 )
    {
      while (1) { __asm("DSB SY"); __asm("WFI"); }
    }
#endif

    fireworks(id);

    _mutex_acquire(&print_lock);

    printf("CPU %d: finished\n", id);

    /*
     * while we have the mutex, adjust finished count
     */
    cpu_finished_count++;

    _mutex_release(&print_lock);

    /*
     * CPU 0 waits for all secondary CPUs to finish, then terminates the program
     */
    if (id == 0)
    {
      while (cpu_finished_count < nCPUs)
        wfe();

      exit(0);
    }
    else
    {
    /*
     * Secondary CPUs ensure the update to cpu_finished_count is visible,
     * let CPU 0 know they've finished, then wait for termination
     */
      dsb(ISHST);
      sev();

      while(1)
        wfi();
    }
}

/*
 * int main(void)
 *    the application start point for the primary CPU - bring up the
 *    secondary CPUs and then call MainApp
 *
 *  Inputs
 *    <none>
 *
 *  Returns
 *    subroutine does not return
 */
__declspec(noreturn) int main(void)
{
#ifdef USE_SERIAL_PORT
    UartInit();
#endif

    _mutex_initialize(&print_lock);
    _mutex_acquire(&print_lock);
    printf("\nDS-5 ARMv8 Fireworks Example, using ARM Compiler 6\n\n");
    printf("Click on USERSW1 to stop/restart the Banner\n\n");
    printf("Running Fireworks on CORE0\n");
#ifndef SMP
    printf("Running Banner on CORE0\n");
#endif
    _mutex_release(&print_lock);

    setup_screen();    // in fireworks.c

    /*
     * send SGI15 to the other (i.e. secondary) CPUs to
     * wake them up
     *
     * these should be group1 ("non-secure") interrupts
     */
    setICC_SGI1R(0, 0, 0, sgirIRMAll, 0, 15);

    init_timer();

    /*
     * start the main application with the other CPUs
     *
     * note: MainApp() does not return
     */
    MainApp();
}
