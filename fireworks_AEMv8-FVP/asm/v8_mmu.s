//
// Defines for v8 Memory Model
//
// Copyright(c) 2012-2014 ARM Ltd.  All Rights Reserved
//


//
// Translation Control Register fields
//
// RGN field encodings
//
.equ TCR_RGN_NC,   0b00
.equ TCR_RGN_WBWA, 0b01
.equ TCR_RGN_WT,   0b10
.equ TCR_RGN_WBRA, 0b11

//
// Shareability encodings
//
.equ TCR_SHARE_NONE,  0b00
.equ TCR_SHARE_OUTER, 0b10
.equ TCR_SHARE_INNER, 0b11

//
// Granule size encodings
//
.equ TCR_GRANULE_4K,  0b00
.equ TCR_GRANULE_64K, 0b01
.equ TCR_GRANULE_16K, 0b10

//
// Physical Address sizes
//
.equ TCR_SIZE_4G,   0b000
.equ TCR_SIZE_64G,  0b001
.equ TCR_SIZE_1T,   0b010
.equ TCR_SIZE_4T,   0b011
.equ TCR_SIZE_16T,  0b100
.equ TCR_SIZE_256T, 0b101

//
// Translation Control Register fields
//
.equ TCR_EL1_T0SZ_SHIFT,   0
.equ TCR_EL1_EPD0,  (1 << 7)
.equ TCR_EL1_IRGN0_SHIFT,  8
.equ TCR_EL1_ORGN0_SHIFT, 10
.equ TCR_EL1_SH0_SHIFT,   12
.equ TCR_EL1_TG0_SHIFT,   14

.equ TCR_EL1_T1SZ_SHIFT,  16
.equ TCR_EL1_A1,   (1 << 22)
.equ TCR_EL1_EPD1, (1 << 23)
.equ TCR_EL1_IRGN1_SHIFT, 24
.equ TCR_EL1_ORGN1_SHIFT, 26
.equ TCR_EL1_SH1_SHIFT,   28
.equ TCR_EL1_TG1_SHIFT,   30
.equ TCR_EL1_IPS_SHIFT,   32
.equ TCR_EL1_AS,   (1 << 36)
.equ TCR_EL1_TBI0, (1 << 37)
.equ TCR_EL1_TBI1, (1 << 38)

//
// Stage 1 Translation Table descriptor fields
//
.equ TT_S1_ATTR_FAULT, (0b00 << 0)
.equ TT_S1_ATTR_BLOCK, (0b01 << 0) // Level 1/2
.equ TT_S1_ATTR_TABLE, (0b11 << 0) // Level 0/1/2
.equ TT_S1_ATTR_PAGE,  (0b11 << 0) // Level 3

.equ TT_S1_ATTR_MATTR_LSB, 2

.equ TT_S1_ATTR_NS, (1 << 5)

.equ TT_S1_ATTR_AP_RW_PL1, (0b00 << 6)
.equ TT_S1_ATTR_AP_RW_ANY, (0b01 << 6)
.equ TT_S1_ATTR_AP_RO_PL1, (0b10 << 6)
.equ TT_S1_ATTR_AP_RO_ANY, (0b11 << 6)

.equ TT_S1_ATTR_SH_NONE,   (0b00 << 8)
.equ TT_S1_ATTR_SH_OUTER,  (0b10 << 8)
.equ TT_S1_ATTR_SH_INNER,  (0b11 << 8)

.equ TT_S1_ATTR_AF, (1 << 10)
.equ TT_S1_ATTR_nG, (1 << 11)

.equ TT_S1_ATTR_CONTIG, (1 << 52)
.equ TT_S1_ATTR_PXN,    (1 << 53)
.equ TT_S1_ATTR_UXN,    (1 << 54)

.equ TT_S1_MAIR_DEV_nGnRnE, 0b00000000
.equ TT_S1_MAIR_DEV_nGnRE,  0b00000100
.equ TT_S1_MAIR_DEV_nGRE,   0b00001000
.equ TT_S1_MAIR_DEV_GRE,    0b00001100

//
// Inner and Outer Normal memory attributes use the same bit patterns
// Outer attributes just need to be shifted up
//
.equ TT_S1_MAIR_OUTER_SHIFT, 4

.equ TT_S1_MAIR_WT_TRANS_RA,  0b0010

.equ TT_S1_MAIR_WB_TRANS_RA,  0b0110
.equ TT_S1_MAIR_WB_TRANS_RWA, 0b0111

.equ TT_S1_MAIR_WT_RA,  0b1010

.equ TT_S1_MAIR_WB_RA,  0b1110
.equ TT_S1_MAIR_WB_RWA, 0b1111
