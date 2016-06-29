//
// ARMv8-A AArch64 - Basic Mutex Example
//
// Copyright (c) 2012-2015 ARM Ltd.  All rights reserved.
//


    .text


    .global _mutex_initialize
    .global _mutex_acquire
    .global _mutex_release

//
// These routines implement the mutex management functions required for running
// the ARM C library in a multi-threaded environment.
//
// They use a value of 0 to represent an unlocked mutex, and 1 for a locked mutex
//
// **********************************************************************
//

    .type _mutex_initialize, "function"
_mutex_initialize:

    //
    // mark the mutex as unlocked
    //
    mov     w1, #0
    str     w1, [x0]

    //
    // we are running multi-threaded, so set a non-zero return
    // value (function prototype says use 1)
    //
    mov     w0, #1
    ret


    .type _mutex_acquire, "function"
_mutex_acquire:

    //
    // send ourselves an event, so we don't stick on the wfe at the
    // top of the loop
    //
    sevl

    //
    // wait until the mutex is available
    //
loop:
    wfe
    ldaxr   w1, [x0]
    cbnz    w1, loop

    //
    // mutex is (at least, it was) available - try to claim it
    //
    mov     w1, #1
    stxr    w2, w1, [x0]
    cbnz    w2, loop

    //
    // OK, we have the mutex, our work is done here
    //
    ret


    .type _mutex_release, "function"
_mutex_release:

    mov     w1, #0
    stlr    w1, [x0]
    ret
