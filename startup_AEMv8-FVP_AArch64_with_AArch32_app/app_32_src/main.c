/*
 * ARMv8 - Main for AArch32
 *
 * Copyright (c) 2011-2016 ARM Ltd.  All rights reserved.
 *
 */

#include <stdlib.h>
#include <stdio.h>

#include "primes.h"
#include "v8_aarch64.h"
#include "MP_Mutexes.h"
#include "GICv3.h"
#include "GICv3_gicc.h"
#include "supportfuncs.h"

extern unsigned int A32GetCPUID(void);
extern void A32EnableCachesEL1(void);

static inline void A32setICC_SGI1R(uint8_t aff3, uint8_t aff2,
                uint8_t aff1, ICC_SGIRBits_t irm,
                uint16_t targetlist, uint8_t intid)
{
    uint32_t packedbitsh = (((uint32_t)aff3 << 16) | irm | ((uint32_t)aff2 ));

    uint32_t packedbitsl = (((uint32_t)aff1 << 16) | targetlist |\
                            ((uint32_t)(intid & 0x0f) << 24));

        asm("MCRR p15, 0, %0, %1, c12\n; isb" :: "r" (packedbitsl), "r" (packedbitsh));
}


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




// Called by the C library to get the address of the per-thread libspace
// Return a separate space for each CPU
void *__user_perthread_libspace(void)
{
    return user_perthread_libspace[A32GetCPUID()];
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

    id = A32GetCPUID();

    if (id >= nCPUs)
    {
      _mutex_acquire(&print_lock);
      printf("Error: More CPU cores are running than the maximum this program expects\n");
      printf("Change the value of nCPUs.  Exiting...\n");
      _mutex_release(&print_lock);
      exit(1);
    }

    calculatePrimes(id);

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
    printf("\r\nDS-5 ARMv8 Prime Number Generator Example\r\n\r\n");
    _mutex_release(&print_lock);

    initPrimes();             // Initialize the primes just once

    /*
     * send SGI15 to the other (i.e. secondary) CPUs to
     * wake them up
     *
     * these should be group1 ("non-secure") interrupts
     */
    A32setICC_SGI1R(0, 0, 0, sgirIRMAll, 0, 15);

    /*
     * start the main application with the other CPUs
     *
     * note: MainApp() does not return
     */
    MainApp();
}
