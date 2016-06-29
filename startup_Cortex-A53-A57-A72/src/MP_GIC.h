/*
 * MP GICv2 example code
 *
 * Copyright ARM Ltd 2011-2014.  All rights reserved.
 */

#ifndef _MP_GIC_
#define _MP_GIC_

/*
 * interrupt groups
 */
typedef enum
{
    ig0 = 0,
    ig1 = 1
} irq_group;

/*
 * software generated interrupt TargetListFilter
 */
typedef enum
{
    sgi_tlf_mask = 0,
    sgi_tlf_others = 1,
    sgi_tlf_self = 2
} sgi_tlf;

/*
 * Typical calls to enable interrupt ID X:
 * Enable_irq_id(X)                 <-- Enable that ID
 * Set_irq_priority(X, 0)           <-- Set the priority of X to 0 (the max priority)
 * Set_priority_mask(0x1F)          <-- Set Core's priority mask to 0x1F (the lowest priority)
 * Enable_GIC()                     <-- Enable the GIC (global)
 * Enable_gic_processor_interface() <-- Enable the CPU interface (local to the core)
 */

/*
 * SetIRQGroup - mark an interrupt as Group0 or Group1
 *
 * Inputs
 *  id - which interrupt to mark
 *  group - the group for IRQ<id>
 *
 * Returns
 *  <nothing>
 */
void SetIRQGroup(unsigned int id, irq_group group);

/*
 * SetBlockGroup - mark a block of interrupts as Group0 or Group1
 *
 * Inputs
 *  block - which interrupt to mark
 *  group - the group for IRQ<id>
 *
 * Returns
 *  <nothing>
 */
void SetBlockGroup(unsigned int id, irq_group group);

/*
 * SetSPIGroup - set all Shared Peripheral IRQs as Group0 or
 *    Group1 interrupts
 *
 * Inputs
 *  group - group (0 or 1)
 *
 * Returns
 *  <nothing>
 */
void SetSPIGroup(irq_group group);

/*
 * SetIRQPriority - configures the priority for an IRQ
 *
 * Inputs
 *  id - which interrupt to set the priority for
 *  priority - IRQ priority, in the range 0-31
 *
 * NOTE
 *  This subroutine assumes 5 bits of priority; if it is being called
 *  while in the Non-Secure world (which only uses 4 bits of priority),
 *  the calling routine is responsible for adjusting the passed
 *  priority. For example, if an NS IRQ is to be assigned a priority
 *  of 14, then this subroutine should be passed a priority value of 28.
 */
void SetIRQPriority(unsigned int ID, unsigned int priority);

/*
 * EnableIRQ - enable a specific IRQ
 *
 * Inputs
 *  id - which interrupt to enable
 *
 * Returns
 *  <nothing>
 */
void EnableIRQ(unsigned int id);

/*
 * DisableIRQ - disable a specific IRQ
 *
 * Inputs
 *  id - which interrupt to disable
 *
 * Returns
 *  <nothing>
 */
void DisableIRQ(unsigned int id);

/*
 * TestIRQ - test whether a specific interrupt is asserted
 *
 * Inputs
 *  id - which interrupt to test
 *
 * Returns
 *  0 - interrupt was not asserted
 *  1 - interrupt was asserted
 */
unsigned int TestIRQ(unsigned int id);

/*
 * EnableGICD - set global interrupt distributor enable
 *
 * Inputs
 *  <nothing>
 *
 * Returns
 *  <nothing>
 */
void EnableGICD(void);

/*
 * DisableGICD - clear global interrupt distributor enable
 *
 * Inputs
 *  <nothing>
 *
 * Returns
 *  <nothing>
 */
void DisableGICD(void);

/*
 * EnableGICC - set local group0 & group1 interrupt enables
 *
 * Inputs
 *  <nothing>
 *
 * Returns
 *  <nothing>
 *
 * Note
 * Group0 enables will be ignored by hardware when called in the
 * Non-Secure world
 */
void EnableGICC(void);

/*
 * DisableGICC - clear local group0 & group1 interrupt enables
 *
 * Inputs
 *  <nothing>
 *
 * Returns
 *  <nothing>
 *
 * Note
 * Group0 disables will be ignored by hardware when called in the
 * Non-Secure world
 */
void DisableGICC(void);

/*
 * SetPriorityMask - program local IRQ priority mask
 *
 * Inputs
 *  priority - priority mask, in the range 0-31
 *
 * NOTE
 *  This subroutine assumes 5 bits of priority are supported - it
 *  will shift the passed priority up by 3 places; unlike
 *  SetIRQPriority() this behaviour is consistent for both the
 *  Secure and Non-Secure worlds
 */
void SetPriorityMask(unsigned int priority);

/*
 * SetBinaryPoint - program local binary point register
 *
 * Inputs
 *  bp - binary point value to program
 */
void SetBinaryPoint(unsigned int bp);

/*
 * ReadIAR - return the contents of the Interrupt Acknowledge Register
 *
 * Inputs
 *  <none>
 *
 * Returns
 *  IAR value
 */
unsigned int ReadIAR(void);

/*
 * WriteEOI - send End Of Interrupt status
 *
 * Inputs
 *  id - interrupt ID, previously read from the IAR
 *
 * Returns
 *  <nothing>
 */
void WriteEOI(unsigned int id);

/*
 * SendSGI - raise a software-generated interrupt
 *
 * Inputs
 *  id - which interrupt to send
 *  filter - identify which processors to interrupt (self, all
 *      but self, or mask specified in target
 *  target - bitmap of procesors to interrupt when required by
 *      filter
 *  group - classify the interrupt as Group0 or Group1
 */
void SendSGI(unsigned int id, sgi_tlf filter,
    unsigned int target, irq_group group);

/*
 * ClearSGI - clear a software generated interrupt request
 *
 * Inputs
 *  id - which interrupt to clear
 *  cpu - which CPU originated the interrupt
 */
void ClearSGI(unsigned int id, unsigned int cpu);

#endif
