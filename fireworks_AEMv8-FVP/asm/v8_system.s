//
// Defines for v8 System Registers
//
// Copyright(c) 2012-2014 ARM Limited.  All Rights Reserved
//

//
// AArch64 SPSR
//
.equ AARCH64_SPSR_EL3h, 0b1101
.equ AARCH64_SPSR_EL3t, 0b1100
.equ AARCH64_SPSR_EL2h, 0b1001
.equ AARCH64_SPSR_EL2t, 0b1000
.equ AARCH64_SPSR_EL1h, 0b0101
.equ AARCH64_SPSR_EL1t, 0b0100
.equ AARCH64_SPSR_EL0t, 0b0000
.equ AARCH64_SPSR_RW, (1 << 4)
.equ AARCH64_SPSR_F,  (1 << 6)
.equ AARCH64_SPSR_I,  (1 << 7)
.equ AARCH64_SPSR_A,  (1 << 8)
.equ AARCH64_SPSR_D,  (1 << 9)
.equ AARCH64_SPSR_IL, (1 << 20)
.equ AARCH64_SPSR_SS, (1 << 21)
.equ AARCH64_SPSR_V,  (1 << 28)
.equ AARCH64_SPSR_C,  (1 << 29)
.equ AARCH64_SPSR_Z,  (1 << 30)
.equ AARCH64_SPSR_N,  (1 << 31)

//
// Multiprocessor Affinity Register
//
.equ MPIDR_EL1_AFF3_LSB, 32
.equ MPIDR_EL1_U,  (1 << 30)
.equ MPIDR_EL1_MT, (1 << 24)
.equ MPIDR_EL1_AFF2_LSB, 16
.equ MPIDR_EL1_AFF1_LSB,  8
.equ MPIDR_EL1_AFF0_LSB,  0
.equ MPIDR_EL1_AFF_WIDTH, 8

//
// Data Cache Zero ID Register
//
.equ DCZID_EL0_BS_LSB,   0
.equ DCZID_EL0_BS_WIDTH, 4
.equ DCZID_EL0_DZP_LSB,  5
.equ DCZID_EL0_DZP, (1 << 5)

//
// System Control Register
//
.equ SCTLR_EL1_UCI,     (1 << 26)
.equ SCTLR_ELx_EE,      (1 << 25)
.equ SCTLR_EL1_E0E,     (1 << 24)
.equ SCTLR_ELx_WXN,     (1 << 19)
.equ SCTLR_EL1_nTWE,    (1 << 18)
.equ SCTLR_EL1_nTWI,    (1 << 16)
.equ SCTLR_EL1_UCT,     (1 << 15)
.equ SCTLR_EL1_DZE,     (1 << 14)
.equ SCTLR_ELx_I,       (1 << 12)
.equ SCTLR_EL1_UMA,     (1 << 9)
.equ SCTLR_EL1_SED,     (1 << 8)
.equ SCTLR_EL1_ITD,     (1 << 7)
.equ SCTLR_EL1_THEE,    (1 << 6)
.equ SCTLR_EL1_CP15BEN, (1 << 5)
.equ SCTLR_EL1_SA0,     (1 << 4)
.equ SCTLR_ELx_SA,      (1 << 3)
.equ SCTLR_ELx_C,       (1 << 2)
.equ SCTLR_ELx_A,       (1 << 1)
.equ SCTLR_ELx_M,       (1 << 0)

//
// Architectural Feature Access Control Register
//
.equ CPACR_EL1_TTA,     (1 << 28)
.equ CPACR_EL1_FPEN,    (3 << 20)

//
// Architectural Feature Trap Register
//
.equ CPTR_ELx_TCPAC, (1 << 31)
.equ CPTR_ELx_TTA,   (1 << 20)
.equ CPTR_ELx_TFP,   (1 << 10)

//
// Secure Configuration Register
//
.equ SCR_EL3_TWE,  (1 << 13)
.equ SCR_EL3_TWI,  (1 << 12)
.equ SCR_EL3_ST,   (1 << 11)
.equ SCR_EL3_RW,   (1 << 10)
.equ SCR_EL3_SIF,  (1 << 9)
.equ SCR_EL3_HCE,  (1 << 8)
.equ SCR_EL3_SMD,  (1 << 7)
.equ SCR_EL3_EA,   (1 << 3)
.equ SCR_EL3_FIQ,  (1 << 2)
.equ SCR_EL3_IRQ,  (1 << 1)
.equ SCR_EL3_NS,   (1 << 0)

//
// Hypervisor Configuration Register
//
.equ HCR_EL2_ID,   (1 << 33)
.equ HCR_EL2_CD,   (1 << 32)
.equ HCR_EL2_RW,   (1 << 31)
.equ HCR_EL2_TRVM, (1 << 30)
.equ HCR_EL2_HVC,  (1 << 29)
.equ HCR_EL2_TDZ,  (1 << 28)
