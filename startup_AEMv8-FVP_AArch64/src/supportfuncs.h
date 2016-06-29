/*
 * Useful support functions
 *
 * Copyright (c) 2014 ARM Limited.  All Rights Reserved
 */

#ifndef SUPPORTFUNCS_H
#define SUPPORTFUNCS_H

/*
 * armcc intrinsics not (yet) supported in armclang
 */
static __inline void dsb(unsigned int qualifier)
{
    asm volatile("dsb %[qual]" : : [qual] "I" (qualifier) : "memory");
}

static __inline void wfi(void)
{
    asm volatile("wfi");
}

static __inline void wfe(void)
{
    asm volatile("wfe");
}

static __inline void sev(void)
{
    asm volatile("sev");
}

static __inline void nop(void)
{
    asm volatile("nop");
}

#endif
