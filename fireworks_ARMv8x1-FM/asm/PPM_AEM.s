//
// Private Peripheral Map for the v8 Architecture Envelope Model
//
// Copyright (c) 2012-2014 ARM Limited.  All Rights Reserved
//

//
// Distributor layout
//
.equ GICD_CTLR,      0x0000
.equ GICD_TYPER,     0x0004
.equ GICD_IIDR,      0x0008
.equ GICD_IGROUP,    0x0080
.equ GICD_ISENABLE,  0x0100
.equ GICD_ICENABLE,  0x0180
.equ GICD_ISPEND,    0x0200
.equ GICD_ICPEND,    0x0280
.equ GICD_ISACTIVE,  0x0300
.equ GICD_ICACTIVE,  0x0380
.equ GICD_IPRIORITY, 0x0400
.equ GICD_ITARGETS,  0x0800
.equ GICD_ICFG,      0x0c00
.equ GICD_PPISR,     0x0d00
.equ GICD_SPISR,     0x0d04
.equ GICD_SGIR,      0x0f00
.equ GICD_CPENDSGI,  0x0f10
.equ GICD_SPENDSGI,  0x0f20
.equ GICD_PIDR4,     0x0fd0
.equ GICD_PIDR5,     0x0fd4
.equ GICD_PIDR6,     0x0fd8
.equ GICD_PIDR7,     0x0fdc
.equ GICD_PIDR0,     0x0fe0
.equ GICD_PIDR1,     0x0fe4
.equ GICD_PIDR2,     0x0fe8
.equ GICD_PIDR3,     0x0fec
.equ GICD_CIDR0,     0x0ff0
.equ GICD_CIDR1,     0x0ff4
.equ GICD_CIDR2,     0x0ff8
.equ GICD_CIDR3,     0x0ffc

//
// CPU Interface layout
//
.equ GICC_CTLR,      0x0000
.equ GICC_PMR,       0x0004
.equ GICC_BPR,       0x0008
.equ GICC_IAR,       0x000c
.equ GICC_EOIR,      0x0010
.equ GICC_RPR,       0x0014
.equ GICC_HPPIR,     0x0018
.equ GICC_ABPR,      0x001c
.equ GICC_AIAR,      0x0020
.equ GICC_AEOIR,     0x0024
.equ GICC_AHPPIR,    0x0028
.equ GICC_APR0,      0x00d0
.equ GICC_NSAPR0,    0x00e0
.equ GICC_IIDR,      0x00fc
.equ GICC_DIR,       0x1000
