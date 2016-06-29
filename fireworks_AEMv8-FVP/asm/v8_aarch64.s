// ------------------------------------------------------------
// ARMv8-A AArch64 - Common helper functions
//
// Copyright (c) 2012-2014 ARM Ltd.  All rights reserved.
// ------------------------------------------------------------


    .text


    .include "asm/v8_system.s"

    .global EnableCachesEL1
////      .global  DisableCachesEL1
    .global InvalidateUDCaches
    .global GetMIDR
    .global GetMPIDR
    .global GetCPUID

// ------------------------------------------------------------

//
// void EnableCachesEL1(void)
//
//    enable Instruction and Data caches
//
    .type EnableCachesEL1, "function"
EnableCachesEL1:

    mrs x0, SCTLR_EL1
    orr x0, x0, #SCTLR_ELx_I
    orr x0, x0, #SCTLR_ELx_C
    msr     SCTLR_EL1, x0

    isb
    ret


// ------------------------------------------------------------
  .ifdef TESTING
    .type DisableCachesEL1, "function"
DisableCachesEL1:

    mrs x0, SCTLR_EL1
    and x0, x0, #~SCTLR_ELx_I
    and x0, x0, #~SCTLR_ELx_C
    msr     SCTLR_EL1, x0

    isb
    ret
  .endif


// ------------------------------------------------------------

//
// void InvalidateUDCaches(void)
//
//    Invalidate data and unified caches
//
    .type InvalidateUDCaches, "function"
InvalidateUDCaches:
    // From the ARM ARMv8-A Architecture Reference Manual

    dmb  ish                   // ensure all prior inner-shareable accesses have been observed

    mrs  x0, CLIDR_EL1
    and  w3, w0, #0x07000000   // get 2 x level of coherence
    lsr  w3, w3, #23
    cbz  w3, finished
    mov  w10, #0               // w10 = 2 x cache level
    mov  w8, #1                // w8 = constant 0b1
loop_level:
    add  w2, w10, w10, lsr #1  // calculate 3 x cache level
    lsr  w1, w0, w2            // extract 3-bit cache type for this level
    and  w1, w1, #0x7
    cmp  w1, #2
    b.lt next_level            // no data or unified cache at this level
    msr  CSSELR_EL1, x10       // select this cache level
    isb                        // synchronize change of csselr
    mrs  x1, CCSIDR_EL1        // read ccsidr
    and  w2, w1, #7            // w2 = log2(linelen)-4
    add  w2, w2, #4            // w2 = log2(linelen)
    ubfx w4, w1, #3, #10       // w4 = max way number, right aligned
    clz  w5, w4                // w5 = 32-log2(ways), bit position of way in dc operand
    lsl  w9, w4, w5            // w9 = max way number, aligned to position in dc operand
    lsl  w16, w8, w5           // w16 = amount to decrement way number per iteration
loop_way:
    ubfx w7, w1, #13, #15      // w7 = max set number, right aligned
    lsl  w7, w7, w2            // w7 = max set number, aligned to position in dc operand
    lsl  w17, w8, w2           // w17 = amount to decrement set number per iteration
loop_set:
    orr  w11, w10, w9          // w11 = combine way number and cache number ...
    orr  w11, w11, w7          // ... and set number for dc operand
    dc   isw, x11              // do data cache invalidate by set and way
    subs w7, w7, w17           // decrement set number
    b.ge loop_set
    subs x9, x9, x16           // decrement way number
    b.ge loop_way
next_level:
    add  w10, w10, #2          // increment 2 x cache level
    cmp  w3, w10
    b.gt loop_level
    dsb  sy                    // ensure completion of previous cache maintenance operation
    isb
finished:
    ret


// ------------------------------------------------------------

//
// ID Register functions
//

    .type GetMIDR, "function"
GetMIDR:

    mrs x0, MIDR_EL1
    ret


    .type GetMPIDR, "function"
GetMPIDR:

    mrs x0, MPIDR_EL1
    ret


    .type GetCPUID, "function"
GetCPUID:

    mrs x0, MPIDR_EL1

    //
    // we're working with x0, even though this subroutine is
    // supposed to return a 32-bit value but that's OK, since
    // if MPIDR_EL1_AFF0_WIDTH was >32, the function would be
    // declared as returning a 64-bit value
    //
    ubfx    x0, x0, #MPIDR_EL1_AFF0_LSB, #MPIDR_EL1_AFF_WIDTH
    ret
