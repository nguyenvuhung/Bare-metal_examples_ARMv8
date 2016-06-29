// ------------------------------------------------------------
// ARMv8-A AArch32 - Common helper functions
//
// Copyright (c) 2012-2016 ARM Ltd.  All rights reserved.
// ------------------------------------------------------------


    .text


    .global A32EnableCachesEL1
    .global A32GetCPUID
    .global A32SetAppStack
    .global Image$$ARM_LIB_STACK$$ZI$$Limit

    // use separate stack and heap, as anticipated by scatter32.txt
    .global __use_two_region_memory

    .include "startup_64_src/PPM_AEM.s"

// ------------------------------------------------------------


    .type A32EnableCachesEL1, "function"
A32EnableCachesEL1:

    mrc  p15, 0, r0, c1, c0, 0   // Read System Control Register configuration data
    orr  r0, r0, #(1 << 2)       // Set C bit
    orr  r0, r0, #(1 << 12)      // Set I bit
    mcr  p15, 0, r0, c1, c0, 0   // Write System Control Register configuration data

    isb
    bx lr


    .type A32GetCPUID, "function"
A32GetCPUID:
    mrc  p15, 0, r0, c0, c0, 5   // Read CPU ID register
    and  r0, r0, #0x03           // Mask off, leaving the CPU ID field
    bx lr


    .type A32SetAppStack, "function"
A32SetAppStack:
    //
    // Setup the application stack for this CPU
    // the scatter file allocates 2^14 bytes per app stack
    //
    mrc  p15, 0, r0, c0, c0, 5   // Read CPU ID register
    and  r0, r0, #0x03           // Mask off, leaving the CPU ID field
    ldr  r1, =Image$$ARM_LIB_STACK$$ZI$$Limit
    sub  r1, r1, r0, lsl #14
    mov  sp, r1
    b MainApp


// ------------------------------------------------------------

// AArch32 ARM C library startup add-in:

// The ARM Architecture Reference Manual for ARMv8-A states:
// "The ARMv8 AArch64 architecture permits instruction accesses to Non-cacheable Normal memory to be held in
// instruction caches. Correspondingly, the sequence for ensuring that modifications to instructions are available
// for execution must include invalidation of the modified locations from the instruction cache, even if the
// instructions are held in Normal Non-cacheable memory. This includes cases where the instruction cache is disabled."

// In addition, where a processor starts-up in AArch64, then switches to AArch32, it is possible that addresses could
// have been speculatively prefetched (and hence cached) while in AArch64.  Assuming that the MMU had remained off
// while in AArch64, a processor is allowed to speculatively prefetch from any address within the same page as an
// architecturally executed instruction, or the following page, where "page" is the smallest supported granule size of the processor.

// To invalidate the instruction cache after scatter-loading and before initialization of the stack and heap,
// it is necessary for the user to:
//
// * Implement instruction cache invalidation code in _platform_pre_stackheap_init.
// * Ensure all code on the path from the program entry up to and including _platform_pre_stackheap_init is located
// in a root region. This includes __rt_entry from the ARM C library. So the ARM C library objects
// containing __rt_entry (__rtentry*.o) must be placed in a root region.
//
// In this example, this function is only called once, by the primary core

    .global _platform_pre_stackheap_init
    .type _platform_pre_stackheap_init, "function"
_platform_pre_stackheap_init:
    dsb ish     // ensure all previous stores have completed before invalidating
    mov r0, #0
    mcr p15, 0, r0, c7, c1, 0  // icialluis I cache invalidate all inner shareable to PoU (which includes secondary cores)
    dsb ish     // ensure completion on inner shareable domain (which includes secondary cores)
    isb

    // Scatter-loading is complete, so enable the caches here, so that the C-library's mutex initialization later will work
    b A32EnableCachesEL1  // Note: tail call branch


// ------------------------------------------------------------

  .global A32invalidateCaches
  // void A32invalidateCaches(void)
  .type A32invalidateCaches, "function"
A32invalidateCaches:
  //
  // Based on code example given in section B2.2.4/11.2.4 of ARM DDI 0406B
  //

  MOV     r0, #0
  MCR     p15, 0, r0, c7, c5, 0     // ICIALLU - Invalidate entire I Cache, and flushes branch target cache

  MRC     p15, 1, r0, c0, c0, 1     // Read CLIDR
  ANDS    r3, r0, #0x7000000
  MOV     r3, r3, LSR #23           // Cache level value (naturally aligned)
  BEQ     invalidate_caches_finished
  MOV     r10, #0

invalidate_caches_loop1:
  ADD     r2, r10, r10, LSR #1      // Work out 3xcachelevel
  MOV     r1, r0, LSR r2            // bottom 3 bits are the Cache type for this level
  AND     r1, r1, #7                // get those 3 bits alone
  CMP     r1, #2
  BLT     invalidate_caches_skip    // no cache or only instruction cache at this level
  MCR     p15, 2, r10, c0, c0, 0    // write the Cache Size selection register
  ISB                               // ISB to sync the change to the CacheSizeID reg
  MRC     p15, 1, r1, c0, c0, 0     // reads current Cache Size ID register
  AND     r2, r1, #7                // extract the line length field
  ADD     r2, r2, #4                // add 4 for the line length offset (log2 16 bytes)
  LDR     r4, =0x3FF
  ANDS    r4, r4, r1, LSR #3        // R4 is the max number on the way size (right aligned)
  CLZ     r5, r4                    // R5 is the bit position of the way size increment
  LDR     r7, =0x00007FFF
  ANDS    r7, r7, r1, LSR #13       // R7 is the max number of the index size (right aligned)

invalidate_caches_loop2:
  MOV     r9, R4                    // R9 working copy of the max way size (right aligned)

invalidate_caches_loop3:
  ORR     r11, r10, r9, LSL r5      // factor in the way number and cache number into R11
  ORR     r11, r11, r7, LSL r2      // factor in the index number
  MCR     p15, 0, r11, c7, c6, 2    // DCISW - invalidate by set/way
  SUBS    r9, r9, #1                // decrement the way number
  BGE     invalidate_caches_loop3
  SUBS    r7, r7, #1                // decrement the index
  BGE     invalidate_caches_loop2

invalidate_caches_skip:
  ADD     r10, r10, #2              // increment the cache number
  CMP     r3, r10
  BGT     invalidate_caches_loop1

invalidate_caches_finished:
  BX      lr
