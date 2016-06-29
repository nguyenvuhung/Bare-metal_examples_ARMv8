//==================================================================
// MP GICv2 example code
//
// Copyright (c) 2014-2105 ARM Ltd.  All rights reserved.
//==================================================================


    .text


    .include "asm/PPM_AEM.s"

    .global Image$$GICD$$ZI$$Base
    .global Image$$GICC$$ZI$$Base

    .global SetIrqGroup
    .global SetBlockGroup
    .global SetSPIGroup
    .global SetIRQPriority
    .global EnableIRQ
    .global DisableIRQ
    .global TestIRQ

    .global EnableGICD
    .global DisableGICD
    .global EnableGICC
    .global DisableGICC
    .global SetPriorityMask
    .global SetBinaryPoint
    .global ReadIAR
    .global WriteEOI
    .global SendSGI
    .global ClearSGI

//==================================================================
// GIC. Generic Interrupt Controller Architecture Specification
//==================================================================
//
// This code assumes a maximum of 512 interrupt sources, which is
// 2^9. Many of the interrupt controls are split up with multiple
// interrupts programmed per GICD_ register, so a varying number
// of bits are extracted from IntId parameters according to the
// no. of interrupts per register
//
// The CPU Interface and Interrupt Distributor are accessed via addresses
// Image$$GICD$$ZI$$Base and Image$$GICC$$ZI$$Base in the private peripheral space

// Typical calls to enable interrupt ID X:
// enableIntID(X)                    <-- Enable that ID
// setIRQPriority(X, 0)              <-- Set the priority of X to 0 (the max priority)
// setPriorityMask(0x1F)             <-- Set CPU's priority mask to 0x1F (the lowest priority)
// enableGIC()                       <-- Enable the GIC (global)
// enableGICProcessorInterface()     <-- Enable the CPU interface (local to the CPU)

//
// void SetIrqGroup(unsigned int id, unsigned int group)
//
//    set IRQ id as a Group<group> interrupt
//
//  Inputs
//    id - IRQ number
//    group - group (0 or 1)
//
//  Returns
//    <nothing>
//
    .type SetIrqGroup, "function"
SetIrqGroup:

    ldr x2, =Image$$GICD$$ZI$$Base
    add x2, x2, #GICD_IGROUP

    //
    // 32 (2^5) group bits per register - calculate:
    //
    // w3 = <Rn> for GICD_IGROUP<Rn>
    // w0 = bit offset in GICD_ISENABLE<w3>
    //
    lsr  w3, w0, #5
    and  w0, w0, #((1 << 5) - 1)

    // Read GICD_IGROUP<Rn>
    ldr  w4, [x2, w3, uxtw #2]

    // Clear current group bit for IRQ <id>
    mov  w5, #1
    lslv w5, w5, w0
    bic  w4, w4, w5

    // Set group bit for IRQ <id>
    lslv w5, w1, w0
    orr  w4, w4, w5

    // Write result back to GICD_IGROUP<Rn>
    str  w4, [x2, w3, uxtw #2]

    ret

         

//
// void SetBlockGroup(unsigned int block, unsigned int group)
//
//    set block of IRQs as a Group<group> interrupt
//
//  Inputs
//    block - set of IRQs, modulo 32
//    group - group (0 or 1)
//
//  Returns
//    <nothing>
//
    .type SetBlockGroup, "function"
SetBlockGroup:

    ldr x2, =Image$$GICD$$ZI$$Base
    add x2, x2, #GICD_IGROUP

    //
    // 32 (2^5) group bits per register - calculate:
    //
    // w3 = <Rn> for GICD_IGROUP<Rn>
    // w1 = all 32 group bits
    //
    ubfx w3, w0, #5, #4        // total of 2^(4+5) irqs
    sbfx w1, w1, #0, #1

    //
    // OK, set group bits and we're done
    //
    str w1, [x2, w3, uxtw #2]

    ret

         

//
// void SetSPIGroup(unsigned int group)
//
//    set all SPI IRQs as Group<group> interrupts
//
//  Inputs
//    group - group (0 or 1)
//
//  Returns
//    <nothing>
//
    .type SetSPIGroup, "function"
SetSPIGroup:

    //
    // get the GICD base, as is standard for these routines, but we're
    // going to be accessing two registers, so keep
    //
    // x2 = GICD_BASE
    // x3 = GICD_BASE->GICD_IGROUP
    //
    ldr x2, =Image$$GICD$$ZI$$Base
    add x3, x2, #GICD_IGROUP

    //
    // GICD_TYPER.ITLinesNumber details the number of SPIs, directly
    // (total IRQ count is 32(N+1), but this includes the SGIs and
    // PPIs which are not covered by this routine)
    //
    ldr w1, [x2, #GICD_TYPER]

    //
    // 32 (2^5) group bits per register - calculate:
    //
    // w0 = all group bits for a block of 32 interrupts
    // w1 = no. of blocks to set permissions for
    //
    sbfx w0, w0, #0, #1
    ubfx w1, w1, #0, #5

    //
    // iterate over all blocks, remembering that the no. of blocks
    // may actually be zero (so test at the top)
    //
loop:
    cbz w1, finished

    //
    // OK, set group bits and we're done
    //
    str w0, [x3, w1, uxtw #2]
    sub w1, w1, #1
    b loop

finished: 
    ret

         

//
// void SetIRQPriority(unsigned int ID, unsigned int priority)
//
    .type SetIRQPriority, "function"
SetIRQPriority:

    ldr x2, =Image$$GICD$$ZI$$Base
    add x2, x2, #GICD_IPRIORITY

    //
    // 4 (2^2) priority fields per register - calculate:
    //
    // w3 = <Rn> for GICD_IPRIORITY<Rn>
    // w4 = field offset for GICD_IPRIORITY<w3>
    //
    ubfx  w3, w0, #2, #7         // total of 2^(2+7) irqs
    ubfiz w4, w0, #3, #2         // 2^3 bits per field

    //
    // we're ready to read the priority register, so do so
    //
    ldr w0, [x2, w3, uxtw #2]

    //
    // ARM v2GIC implementations have max. 32 bits of priority, so
    // massage x1 into the appropriate format for GICD_IPRIORITY<w3>
    //
    ubfiz w1, w1, #3, #5

    //
    // prepare priority and an 8-bit mask
    //
    lslv w1, w1, w4
    mov  w5, #0xff
    lslv w5, w5, w4

    //
    // mask and set the priority, write it back
    //
    bic w0, w0, w5
    orr w0, w0, w1
    str w0, [x2, w3, uxtw #2]

    ret

         

//
// void EnableIRQ(unsigned int id)
//
    .type EnableIRQ, "function"
EnableIRQ:

    ldr x1, =Image$$GICD$$ZI$$Base
    add x1, x1, #GICD_ISENABLE

    //
    // 32 (2^5) enable set bits per register - calculate:
    //
    // w2 = <n> for GICD_ISENABLE<n>
    // w0 = bit offset in GICD_ISENABLE<w2>
    // w3 = bit mask   in GICD_ISENABLE<w2>
    //
    ubfx w2, w0, #5, #4         // total of 2^(4+5) irqs
    and  w0, w0, #32 - 1

    //
    // OK, calculate and write the set mask
    //
    mov     w3, #1
    lslv w3, w3, w0

    str     w3, [x1, w2, uxtw #2]

    ldr w4, [x1], #4
    ldr w5, [x1]

    ret

         

//
// void DisableIRQ(unsigned int ID)
//
    .type DisableIRQ, "function"
DisableIRQ:

    ldr x1, =Image$$GICD$$ZI$$Base
    add x1, x1, #GICD_ICENABLE

    //
    // 32 (2^5) enable clear bits per register - calculate:
    //
    // w2 = <n> for GICD_ICENABLE<n>
    // w0 = bit offset in GICD_ICENABLE<w2>
    // w3 = bit mask   in GICD_ICENABLE<w2>
    //
    ubfx w2, w0, #5, #4         // total of 2^(4+5) irqs
    and  w0, w0, #32 - 1

    //
    // OK, calculate and write the clear mask
    //
    mov  w3, #1
    lslv w3, w3, w0

    str  w3, [x1, w2, uxtw #2]

    ret

         

//
// void TestIRQ(unsigned int ID)
//
    .type TestIRQ, "function"
TestIRQ:

    ldr x1, =Image$$GICD$$ZI$$Base
    add x1, x1, #GICD_ISPEND

    //
    // 32 (2^5) interrupt bits per register - calculate:
    //
    // w2 = <n> for GICD_ISENABLE<n>
    // w0 = bit offset in GICD_ISPEND<w2>
    // w3 = bit mask   in GICD_ISPEND<w2>
    //
    ubfx w2, w0, #5, #4         // total of 2^(4+5) irqs
    and  w3, w0, #32 - 1

    //
    // OK, read the register and extract the relevant bit
    //
    ldr  w0, [x1, w2, uxtw #2]
    lsrv w0, w0, w3
    and  w0, w0, #1

    ret

         

//
// void EnableGICD(void)
// Global enable of the Interrupt Distributor
// Enables forwarding of both Group1 and Group0 pending interrupts from the Distributor to the CPU interfaces
//
    .type EnableGICD, "function"
EnableGICD:

    ldr x0, =Image$$GICD$$ZI$$Base
    ldr w1, [x0, #GICD_CTLR]
    orr w1, w1, #3
    str w1, [x0, #GICD_CTLR]

    ret

         

//
// void DisableGICD(void)
// Global disable of the Interrupt Distributor
// Disables forwarding of both Group1 and Group0 pending interrupts from the Distributor to the CPU interfaces
//
    .type DisableGICD, "function"
DisableGICD:

    ldr x0, =Image$$GICD$$ZI$$Base
    ldr w1, [x0, #GICD_CTLR]
    bfi w1, wzr, #0, #2
    str w1, [x0, #GICD_CTLR]

    ret

         

//
// void EnableGICC(void)
//
    .type EnableGICC, "function"
EnableGICC:

    ldr x0, =Image$$GICC$$ZI$$Base
    //
    // We're trying to at least nominally support both Secure and
    // Non-Secure calls to these functions, so set both Group0
    // and Group1 enables
    //
    ldr w1, [x0, #GICC_CTLR]
    orr w1, w1, #3
    str w1, [x0, #GICC_CTLR]

    ret

         

//
// void DisableGICC(void)
//
    .type DisableGICC, "function"
DisableGICC:

    ldr x0, =Image$$GICC$$ZI$$Base
    //
    // We're trying to at least nominally support both Secure and
    // Non-Secure calls to these functions, so clear both Group0
    // and Group1 enables
    //
    ldr w1, [x0, #GICC_CTLR]
    bfi w1, wzr, #0, #2
    str w1, [x0, #GICC_CTLR]

    ret

         

//
// void SetPriorityMask(unsigned int priority)
//
    .type SetPriorityMask, "function"
SetPriorityMask:

    ldr x1, =Image$$GICC$$ZI$$Base
    ubfiz w0, w0, #3, #5
    str   w0, [x1, #GICC_PMR]

    ret

         

//
// void SetBinaryPoint(unsigned int bp)
//
    .type SetBinaryPoint, "function"
SetBinaryPoint:

    ldr x1, =Image$$GICC$$ZI$$Base
    str w0, [x1, #GICC_BPR]

    ret

         

//
// unsigned int ReadIAR(void)
//
    .type ReadIAR, "function"
ReadIAR:

    ldr x1, =Image$$GICC$$ZI$$Base
    ldr w0, [x1, #GICC_IAR]

    ret

         

//
// void WriteEOI(unsigned int ID)
//
    .type WriteEOI, "function"
WriteEOI:

    ldr x1, =Image$$GICC$$ZI$$Base

    str w0, [x1, #GICC_EOIR]

    ret

         

//
// void SendSGI(unsigned int id, sgi_tlf filter,
//              unsigned int target, irq_group group)
//
    .type SendSGI, "function"
SendSGI:

    ldr x4, =Image$$GICD$$ZI$$Base

    ubfx w0, w0, #0, #4
    bfi  w0, w1, #24, #2
    bfi  w0, w2, #16, #8
    bfi  w0, w3, #15, #1

    str  w0, [x4, #GICD_SGIR]

    ret

         

//
// void ClearSGI(unsigned int id, unsigned int cpu)
//
    .type ClearSGI, "function"
ClearSGI:

    ldr x4, =Image$$GICD$$ZI$$Base
    add x4, x4, #GICD_CPENDSGI

    //
    // total of 16 interrupts, 4 per register, 8 bits per interrupt
    //
    ubfx  w2, w0, #2, #2
    ubfiz w0, w0, #3, #2

    and   w1, w1, #7
    add   w0, w0, w1
    mov   w3, #1
    lslv  w3, w3, w0

    str   w3, [x4, w2, uxtw #2]

    ret

