// ------------------------------------------------------------
// ARMv8-A Vector tables
//
// Copyright (c) 2014-2016 ARM Ltd.  All rights reserved.
// ------------------------------------------------------------


    .global el1_vectors
    .global el2_vectors
    .global el3_vectors
    .global c0sync1

    .section  EL1VECTORS, "ax"
    .align 11

//
// Current EL with SP0
//
el1_vectors:
c0sync1: B c0sync1

    .balign 0x80
c0irq1: B c0irq1

    .balign 0x80
c0fiq1: B c0fiq1

    .balign 0x80
c0serr1: B c0serr1

//
// Current EL with SPx
//
    .balign 0x80
cxsync1: B cxsync1

    .balign 0x80
cxirq1: B cxirq1

    .balign 0x80
cxfiq1: B cxfiq1

    .balign 0x80
cxserr1: B cxserr1

//
// Lower EL using AArch64
//
    .balign 0x80
l64sync1:
    B   l64sync1

    .balign 0x80
l64irq1:
    B   l64irq1

    .balign 0x80
l64fiq1:
    B   l64fiq1

    .balign 0x80
l64serr1:
    B   l64serr1

//
// Lower EL using AArch32
//
    .balign 0x80
l32sync1:
    B   l32sync1

    .balign 0x80
l32irq1:
    B   l32irq1

    .balign 0x80
l32fiq1:
    B   l32fiq1

    .balign 0x80
l32serr1:
    B   l32serr1

//----------------------------------------------------------------

    .section  EL2VECTORS, "ax"
    .align 11

//
// Current EL with SP0
//
el2_vectors:
c0sync2: B c0sync2

    .balign 0x80
c0irq2: B c0irq2

    .balign 0x80
c0fiq2: B c0fiq2

    .balign 0x80
c0serr2: B c0serr2

//
// Current EL with SPx
//
    .balign 0x80
cxsync2: B cxsync2

    .balign 0x80
cxirq2: B cxirq2

    .balign 0x80
cxfiq2: B cxfiq2

    .balign 0x80
cxserr2: B cxserr2

//
// Lower EL using AArch64
//
    .balign 0x80
l64sync2:
    B   l64sync2

    .balign 0x80
l64irq2:
    B   l64irq2

    .balign 0x80
l64fiq2:
    B   l64fiq2

    .balign 0x80
l64serr2:
    B   l64serr2

//
// Lower EL using AArch32
//
    .balign 0x80
l32sync2:
    B   l32sync2

    .balign 0x80
l32irq2:
    B   l32irq2

    .balign 0x80
l32fiq2:
    B   l32fiq2

    .balign 0x80
l32serr2:
    B   l32serr2

//----------------------------------------------------------------

    .section  EL3VECTORS, "ax"
    .align 11

//
// Current EL with SP0
//
el3_vectors:
c0sync3: B c0sync3

    .balign 0x80
c0irq3: B c0irq3

    .balign 0x80
c0fiq3: B c0fiq3

    .balign 0x80
c0serr3: B c0serr3

//
// Current EL with SPx
//
    .balign 0x80
cxsync3: B cxsync3

    .balign 0x80
cxirq3: B cxirq3

    .balign 0x80
cxfiq3: B cxfiq3

    .balign 0x80
cxserr3: B cxserr3

//
// Lower EL using AArch64
//
    .balign 0x80
l64sync3:
    B   l64sync3

    .balign 0x80
l64irq3:
    B   l64irq3

    .balign 0x80
l64fiq3:
    B   l64fiq3

    .balign 0x80
l64serr3:
    B   l64serr3

//
// Lower EL using AArch32
//
    .balign 0x80
l32sync3:
    B   l32sync3

    .balign 0x80
l32irq3:
    B   l32irq3

    .balign 0x80
l32fiq3:
    B   l32fiq3

    .balign 0x80
l32serr3:
    B   l32serr3
