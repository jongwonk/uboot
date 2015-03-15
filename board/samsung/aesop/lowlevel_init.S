/*
 * Memory Setup stuff - taken from blob memsetup.S
 *
 * Copyright (C) 2009 Samsung Electronics
 * Kyungmin Park <kyungmin.park@samsung.com>
 *
 * SPDX-License-Identifier:	GPL-2.0+
 */

#include <config.h>
#include <version.h>
#include <asm/arch/cpu.h>
#include <asm/arch/clock.h>
#include <asm/arch/power.h>

/*
 * Register usages:
 *
 * r5 has zero always
 * r7 has S5PC100 GPIO base, 0xE0300000
 * r8 has real GPIO base, 0xE0300000, 0xE0200000 at S5PC100, S5PC110 repectively
 * r9 has Mobile DDR size, 1 means 1GiB, 2 means 2GiB and so on
 */

	.globl lowlevel_init
lowlevel_init:
	mov	r11, lr

	/* r5 has always zero */
	mov	r5, #0

	ldr	r0, =S5PC110_RST_STAT
	ldr	r1, [r0]
	and	r1, r1, #0x000D0000
	cmp	r1, #(0x1 << 19)			@ DEEPIDLE_WAKEUP
	beq	didle_wakeup

skip_check_didle:
	add	r0, r8, #0x2C0				@ S5PC110_GPIO_J4
	ldr	r1, [r0, #0x0]				@ GPIO_CON_OFFSET
	bic	r1, r1, #(0xf << 4)			@ 1 * 4-bit
	orr	r1, r1, #(0x1 << 4)
	str	r1, [r0, #0x0]				@ GPIO_CON_OFFSET

	ldr	r1, [r0, #0x4]				@ GPIO_DAT_OFFSET
	bic	r1, r1, #(1 << 1)
	str	r1, [r0, #0x4]				@ GPIO_DAT_OFFSET

	/*
	 * Initialize Async Register Setting for EVT1
	 * Because we are setting EVT1 as the default value of EVT0,
	 * setting EVT0 as well does not make things worse.
	 * Thus, for the simplicity, we set for EVT0, too
	 *
	 * The "Async Registers" are:
	 *	0xE0F0_0000
	 *	0xE1F0_0000
	 *	0xF180_0000
	 *	0xF190_0000
	 *	0xF1A0_0000
	 *	0xF1B0_0000
	 *	0xF1C0_0000
	 *	0xF1D0_0000
	 *	0xF1E0_0000
	 *	0xF1F0_0000
	 *	0xFAF0_0000
	 */

	ldr     r0, =0xe0f00000
	ldr     r1, [r0]
	bic     r1, r1, #0x1
	str     r1, [r0]

	ldr     r0, =0xe1f00000
	ldr     r1, [r0]
	bic     r1, r1, #0x1
	str     r1, [r0]

	ldr     r0, =0xf1800000
	ldr     r1, [r0]
	bic     r1, r1, #0x1
	str     r1, [r0]

	ldr     r0, =0xf1900000
	ldr     r1, [r0]
	bic     r1, r1, #0x1
	str     r1, [r0]

	ldr     r0, =0xf1a00000
	ldr     r1, [r0]
	bic     r1, r1, #0x1
	str     r1, [r0]

	ldr     r0, =0xf1b00000
	ldr     r1, [r0]
	bic     r1, r1, #0x1
	str     r1, [r0]

	ldr     r0, =0xf1c00000
	ldr     r1, [r0]
	bic     r1, r1, #0x1
	str     r1, [r0]

	ldr     r0, =0xf1d00000
	ldr     r1, [r0]
	bic     r1, r1, #0x1
	str     r1, [r0]

	ldr     r0, =0xf1e00000
	ldr     r1, [r0]
	bic     r1, r1, #0x1
	str     r1, [r0]

	ldr     r0, =0xf1f00000
	ldr     r1, [r0]
	bic     r1, r1, #0x1
	str     r1, [r0]

	ldr     r0, =0xfaf00000
	ldr     r1, [r0]
	bic     r1, r1, #0x1
	str     r1, [r0]

	/*
	 * Diable ABB block to reduce sleep current at low temperature
	 * Note that it's hidden register setup don't modify it
	 */
	ldr	r0, =0xE010C300
	ldr	r1, =0x00800000
	str	r1, [r0]

	/* IO retension release */
	ldr	r0, =S5PC110_OTHERS			@ 0xE010E000
	ldr	r1, [r0]
	ldr	r2, =((1 << 31) | (1 << 30) | (1 << 29) | (1 << 28))
	orr	r1, r1, r2
	/* Do not release retention here for S5PC110 */

	/* Disable Watchdog */
	ldr	r0, =S5PC110_WATCHDOG_BASE		@ 0xE2700000
	str	r5, [r0]

	/* setting SRAM */
	ldr	r0, =S5PC110_SROMC_BASE
	ldr	r1, =0x9
	str	r1, [r0]

	/* S5PC100 has 3 groups of interrupt sources */
	ldr	r0, =S5PC110_VIC0_BASE			@ 0xF2000000
	add	r1, r0, #0x00100000
	add	r2, r0, #0x00200000

	/* Disable all interrupts (VIC0, VIC1 and VIC2) */
	mvn	r3, #0x0
	str	r3, [r0, #0x14]				@ INTENCLEAR
	str	r3, [r1, #0x14]				@ INTENCLEAR
	str	r3, [r2, #0x14]				@ INTENCLEAR

	/* Set all interrupts as IRQ */
	str	r5, [r0, #0xc]				@ INTSELECT
	str	r5, [r1, #0xc]				@ INTSELECT
	str	r5, [r2, #0xc]				@ INTSELECT

	/* Pending Interrupt Clear */
	str	r5, [r0, #0xf00]			@ INTADDRESS
	str	r5, [r1, #0xf00]			@ INTADDRESS
	str	r5, [r2, #0xf00]			@ INTADDRESS

	bl  system_clock_init

	bl mem_ctrl_asm_init

	/* for UART */
	bl	uart_asm_init

	bl	internal_ram_init

	ldr	r0, =S5PC110_WAKEUP_STAT
	ldr	r1, [r0]
	str	r1, [r0]

	/* IO retension release */
	ldr	r0, =S5PC110_OTHERS			@ 0xE010E000
	ldr	r1, [r0]
	ldr	r2, =((1 << 31) | (1 << 30) | (1 << 29) | (1 << 28))
	orr	r1, r1, r2
	str	r1, [r0]

	b	1f

didle_wakeup:
	/* Wait when APLL is locked */
	ldr	r0, =0xE0100100			@ S5PC110_APLL_CON
lockloop:
	ldr	r1, [r0]
	and	r1, r1, #(1 << 29)
	cmp	r1, #(1 << 29)
	bne	lockloop

	ldr	r0, =S5PC110_INFORM0
	ldr	r1, [r0]
	mov	pc, r1
	nop
	nop
	nop
	nop
	nop

1:
	mov	lr, r11
	mov	pc, lr

/*
 * system_clock_init: Initialize core clock and bus clock.
 * void system_clock_init(void)
 */
system_clock_init:

	ldr	r0, =0xE0100000 @APLL_LOCK

	/* Set Mux to FIN */
	ldr	r1, =0x0
	str	r1, [r0, #0x200] @CLK_SRC0

	ldr	r1,	=APLL_LOCKTIME_VAL
	str	r1,	[r0] @APLL_LOCK

	/* Disable PLL */
	ldr	r1, =0x0
	str	r1, [r0, #0x100] @APLL_CON0_OFFSET
	str	r1, [r0, #0x108] @MPLL_CON_OFFSET
	str	r1, [r0, #0x110] @EPLL_CON_OFFSET
	str	r1, [r0, #0x120] @VPLL_CON_OFFSET

	ldr r1, [r0, #0x300] @CLK_DIV0_OFFSET
	ldr	r2, =CLK_DIV0_MASK
	bic	r1, r1, r2

	ldr	r2, =CLK_DIV0_VAL
	orr	r1, r1, r2
	str	r1, [r0, #0x300] @CLK_DIV0_OFFSET

	ldr	r1, =APLL_VAL
	str	r1, [r0, #0x100] @APLL_CON0_OFFSET

	ldr	r1, =MPLL_VAL
	str	r1, [r0, #0x108] @MPLL_CON_OFFSET

	ldr	r1, =EPLL_VAL
	str	r1, [r0, #0x110] @EPLL_CON_OFFSET

	ldr	r1, =VPLL_VAL
	str	r1, [r0, #0x120] @VPLL_CON_OFFSET

#if defined(CONFIG_EVT1)
	ldr	r1, =AFC_ON
	str	r1, [r0, #0x104] @APLL_CON1_OFFSET
#endif

	mov	r1, #0x10000
1:	subs	r1, r1, #1
	bne	1b

	ldr	r1, [r0, #0x200] @CLK_SRC0_OFFSET
	ldr	r2, =0x10001111
	orr	r1, r1, r2
	str	r1, [r0, #0x200] @CLK_SRC0_OFFSET

	/* CLK_DIV6 */
	ldr	r1, [r0, #0x318]  @CLK_DIV6_OFFSET
	bic	r1, r1, #(0x7<<12)@ONENAND_RATIO: 0
	str	r1, [r0, #0x318]  @CLK_DIV6_OFFSET

	mov	pc, lr
internal_ram_init: @ TZPC initialization
	ldr	r0, =0xF1500000 @TZPC0
	ldr	r1, =0x0	@ no secure region
	str	r1, [r0]

	mov	pc, lr

/*
 * uart_asm_init: Initialize UART's pins
 */
uart_asm_init:
	/* set GPIO(GPA) to enable UART */

	ldr	r0, =0xE0200000 @GPA0CON
	ldr	r1, =0x22222222
	str r1, [r0] @#GPA0CON_OFFSET

	ldr r1, =0x00000022   @GPA1_[2,3]:input, GPA1_[0,1]:RXD,TXD
	str r1, [r0, #0x20] @GPA1CON_OFFSET

	ldr	r0, =0xE2900400 @ULCON1, UART1 console base
	mov	r1, #0x0
	str	r1, [r0, #0x8] @UFCON_OFFSET
	str	r1, [r0, #0xC] @UMCON_OFFSET

	mov	r1, #0x3
	str	r1, [r0] @ULCON_OFFSET

	ldr	r1, =0x3c5
	str	r1, [r0, #0x4] @UCON_OFFSET

	ldr	r1, =UART_UBRDIV_VAL
	str	r1, [r0, #0x28] @UBRDIV_OFFSET

	ldr	r1, =UART_UDIVSLOT_VAL
	str	r1, [r0, #0x2C] @UDIVSLOT_OFFSET

	ldr	r1, =0x4f4f4f4f
	str	r1, [r0, #0x20] @TXH_OFFSET, @'O'

	mov	pc, lr

.globl mem_ctrl_asm_init
mem_ctrl_asm_init:

	/* DMC0 initialization at single Type*/
	ldr	r0, =0xF0000000 @ DMC0

	ldr	r1, =0x00101000				@PhyControl0 DLL parameter setting, manual 0x00101000
	str	r1, [r0, #0x18]  @DMC_PHYCONTROL0

	ldr	r1, =0x00000086				@PhyControl1 DLL parameter setting, LPDDR/LPDDR2 Case
	str	r1, [r0, #0x1C] @DMC_PHYCONTROL1

	ldr	r1, =0x00101002				@PhyControl0 DLL on
	str	r1, [r0, #0x18]  @DMC_PHYCONTROL0

	ldr	r1, =0x00101003				@PhyControl0 DLL start
	str	r1, [r0, #0x18]  @DMC_PHYCONTROL0

find_lock_val:
	ldr	r1, [r0, #0x40]  @DMC_PHYSTATUS		@Load Phystatus register value
	and	r2, r1, #0x7
	cmp	r2, #0x7				@Loop until DLL is locked
	bne	find_lock_val

	and	r1, #0x3fc0
	mov	r2, r1, LSL #18
	orr	r2, r2, #0x100000
	orr	r2 ,r2, #0x1000

	orr	r1, r2, #0x3				@Force Value locking
	str	r1, [r0, #0x18]  @DMC_PHYCONTROL0

	/* setting DDR2 */
	ldr	r1, =0x0FFF2010				@ConControl auto refresh off
	str	r1, [r0]

	ldr	r1, =0x00202400  @ BL=4, 1 chip, DDR2 type, dynamic self refresh, force precharge, dynamic power down off
	str	r1, [r0, #0x04]  @DMC_MEMCONTROL

	ldr	r1, =0x20F00313  @MemConfig0 256MB config, 8 banks,Mapping Method[12:15]0:linear, 1:linterleaved, 2:Mixed
	str	r1, [r0, #0x08]  @DMC_MEMCONFIG0
	str	r1, [r0, #0x0C]  @DMC_MEMCONFIG1

	ldr	r1, =0xFF000000
	str	r1, [r0, #0x14]  @DMC_PRECHCONFIG

	ldr	r1, =0x00000618	 @ 7.8us*133MHz=1038(0x40E), 100MHz=780(0x30C), 20MHz=156(0x9C), 10MHz=78(0x4E)
	str	r1, [r0, #0x30]  @DMC_TIMINGAREF

	ldr	r1, =0x2B34438A  @ for @200MHz
	str	r1, [r0, #0x34]  @DMC_TIMINGROW

	ldr	r1, =0x24240000  @TimingData	CL=3
	str	r1, [r0, #0x38]  @DMC_TIMINGDATA

	ldr	r1, =0x0BDC0343
	str	r1, [r0, #0x3C]  @DMC_TIMINGPOWER

	ldr	r1, =0x07000000				@DirectCmd	chip0 Deselect
	str	r1, [r0, #0x10]  @DMC_DIRECTCMD

	ldr	r1, =0x01000000				@DirectCmd	chip0 PALL
	str	r1, [r0, #0x10]  @DMC_DIRECTCMD

	ldr	r1, =0x00020000				@DirectCmd	chip0 EMRS2
	str	r1, [r0, #0x10]  @DMC_DIRECTCMD

	ldr	r1, =0x00030000				@DirectCmd	chip0 EMRS3
	str	r1, [r0, #0x10]  @DMC_DIRECTCMD

	ldr	r1, =0x00010400				@DirectCmd	chip0 EMRS1 (MEM DLL on, DQS# disable)
	str	r1, [r0, #0x10]  @DMC_DIRECTCMD

	ldr	r1, =0x00000542				@DirectCmd	chip0 MRS (MEM DLL reset) CL=4, BL=4
	str	r1, [r0, #0x10]  @DMC_DIRECTCMD

	ldr	r1, =0x01000000				@DirectCmd	chip0 PALL
	str	r1, [r0, #0x10]  @DMC_DIRECTCMD

	ldr	r1, =0x05000000				@DirectCmd	chip0 REFA
	str	r1, [r0, #0x10]  @DMC_DIRECTCMD

	ldr	r1, =0x05000000				@DirectCmd	chip0 REFA
	str	r1, [r0, #0x10]  @DMC_DIRECTCMD

	ldr	r1, =0x00000442				@DirectCmd	chip0 MRS (MEM DLL unreset)
	str	r1, [r0, #0x10]  @DMC_DIRECTCMD

	ldr	r1, =0x00010780				@DirectCmd	chip0 EMRS1 (OCD default)
	str	r1, [r0, #0x10]  @DMC_DIRECTCMD

	ldr	r1, =0x00010400				@DirectCmd	chip0 EMRS1 (OCD exit)
	str	r1, [r0, #0x10]  @DMC_DIRECTCMD

	ldr	r1, =0x07100000				@DirectCmd	chip1 Deselect
	str	r1, [r0, #0x10]  @DMC_DIRECTCMD

	ldr	r1, =0x01100000				@DirectCmd	chip1 PALL
	str	r1, [r0, #0x10]  @DMC_DIRECTCMD

	ldr	r1, =0x00120000				@DirectCmd	chip1 EMRS2
	str	r1, [r0, #0x10]  @DMC_DIRECTCMD

	ldr	r1, =0x00130000				@DirectCmd	chip1 EMRS3
	str	r1, [r0, #0x10]  @DMC_DIRECTCMD

	ldr	r1, =0x00110400				@DirectCmd	chip1 EMRS1 (MEM DLL on, DQS# disable)
	str	r1, [r0, #0x10]  @DMC_DIRECTCMD

	ldr	r1, =0x00100542				@DirectCmd	chip1 MRS (MEM DLL reset) CL=4, BL=4
	str	r1, [r0, #0x10]  @DMC_DIRECTCMD

	ldr	r1, =0x01100000				@DirectCmd	chip1 PALL
	str	r1, [r0, #0x10]  @DMC_DIRECTCMD

	ldr	r1, =0x05100000				@DirectCmd	chip1 REFA
	str	r1, [r0, #0x10]  @DMC_DIRECTCMD

	ldr	r1, =0x05100000				@DirectCmd	chip1 REFA
	str	r1, [r0, #0x10]  @DMC_DIRECTCMD

	ldr	r1, =0x00100442				@DirectCmd	chip1 MRS (MEM DLL unreset)
	str	r1, [r0, #0x10]  @DMC_DIRECTCMD

	ldr	r1, =0x00110780				@DirectCmd	chip1 EMRS1 (OCD default)
	str	r1, [r0, #0x10]  @DMC_DIRECTCMD

	ldr	r1, =0x00110400				@DirectCmd	chip1 EMRS1 (OCD exit)
	str	r1, [r0, #0x10]  @DMC_DIRECTCMD

	ldr	r1, =0x0FF02030				@ConControl	auto refresh on
	str	r1, [r0]   @DMC_CONCONTROL

	ldr	r1, =0xFFFF00FF				@PwrdnConfig
	str	r1, [r0, #0x28]  @DMC_PWRDNCONFIG

	ldr	r1, =0x00202400				@MemControl	BL=4, 1 chip, DDR2 type, dynamic self refresh, force precharge, dynamic power down off
	str	r1, [r0, #0x04]  @DMC_MEMCONTROL

	/* DMC1 initialization */
	ldr	r0, =0xF1400000 @DMC1

	ldr	r1, =0x00101000				@Phycontrol0 DLL parameter setting
	str	r1, [r0, #0x18]  @DMC_PHYCONTROL0

	ldr	r1, =0x00000086				@Phycontrol1 DLL parameter setting
	str	r1, [r0, #0x1C]  @DMC_PHYCONTROL1

	ldr	r1, =0x00101002				@PhyControl0 DLL on
	str	r1, [r0, #0x18]  @DMC_PHYCONTROL0

	ldr	r1, =0x00101003				@PhyControl0 DLL start
	str	r1, [r0, #0x18]  @DMC_PHYCONTROL0
find_lock_val1:
	ldr	r1, [r0, #0x40]  @DMC_PHYSTATUS		@Load Phystatus register value
	and	r2, r1, #0x7
	cmp	r2, #0x7				@Loop until DLL is locked
	bne	find_lock_val1

	and	r1, #0x3fc0
	mov	r2, r1, LSL #18
	orr	r2, r2, #0x100000
	orr	r2, r2, #0x1000

	orr	r1, r2, #0x3				@Force Value locking
	str	r1, [r0, #0x18]  @DMC_PHYCONTROL0

	/* setting for DDR2 */
	ldr	r0, =0xF1400000 @ DMC1

	ldr	r1, =0x0FFF2010				@auto refresh off
	str	r1, [r0]

	ldr	r1, =DMC1_MEMCONTROL	@MemControl	BL=4, 2 chip, DDR2 type, dynamic self refresh, force precharge, dynamic power down off
	str	r1, [r0, #0x04]  @DMC_MEMCONTROL

	ldr	r1, =DMC1_MEMCONFIG_0	@MemConfig0	512MB config, 8 banks,Mapping Method[12:15]0:linear, 1:linterleaved, 2:Mixed
	str	r1, [r0, #0x08]  @DMC_MEMCONFIG0
	str	r1, [r0, #0x0C]  @DMC_MEMCONFIG1

	ldr	r1, =0xFF000000
	str	r1, [r0, #0x14] @DMC_PRECHCONFIG

	ldr	r1, =0x00000618	 @ 7.8us*133MHz=1038(0x40E), 100MHz=780(0x30C), 20MHz=156(0x9C), 10MHz=78(0x4
	str	r1, [r0, #0x30]  @DMC_TIMINGAREF

	ldr	r1, =0x2B34438A	 @ for @200MHz
	str	r1, [r0, #0x34]  @DMC_TIMINGROW

	ldr	r1, =0x24240000	 @ CL=3
	str	r1, [r0, #0x38]  @DMC_TIMINGDATA

	ldr	r1, =0x0BDC0343
	str	r1, [r0, #0x3C]  @DMC_TIMINGPOWER

	ldr	r1, =0x07000000	 @DirectCmd	chip0 Deselect
	str	r1, [r0, #0x10]  @DMC_DIRECTCMD

	ldr	r1, =0x01000000	 @DirectCmd	chip0 PALL
	str	r1, [r0, #0x10]  @DMC_DIRECTCMD

	ldr	r1, =0x00020000	 @DirectCmd	chip0 EMRS2
	str	r1, [r0, #0x10]  @DMC_DIRECTCMD

	ldr	r1, =0x00030000	 @DirectCmd	chip0 EMRS3
	str	r1, [r0, #0x10]  @DMC_DIRECTCMD

	ldr	r1, =0x00010400	 @DirectCmd	chip0 EMRS1 (MEM DLL on, DQS# disable)
	str	r1, [r0, #0x10]  @DMC_DIRECTCMD

	ldr	r1, =0x00000542	 @DirectCmd	chip0 MRS (MEM DLL reset) CL=4, BL=4
	str	r1, [r0, #0x10]  @DMC_DIRECTCMD

	ldr	r1, =0x01000000	 @DirectCmd	chip0 PALL
	str	r1, [r0, #0x10]  @DMC_DIRECTCMD

	ldr	r1, =0x05000000	 @DirectCmd	chip0 REFA
	str	r1, [r0, #0x10]  @DMC_DIRECTCMD

	ldr	r1, =0x05000000	 @DirectCmd	chip0 REFA
	str	r1, [r0, #0x10]  @DMC_DIRECTCMD

	ldr	r1, =0x00000442	 @DirectCmd	chip0 MRS (MEM DLL unreset)
	str	r1, [r0, #0x10]  @DMC_DIRECTCMD

	ldr	r1, =0x00010780	 @DirectCmd	chip0 EMRS1 (OCD default)
	str	r1, [r0, #0x10]  @DMC_DIRECTCMD

	ldr	r1, =0x00010400	 @DirectCmd	chip0 EMRS1 (OCD exit)
	str	r1, [r0, #0x10]  @DMC_DIRECTCMD

	ldr	r1, =0x07100000	 @DirectCmd	chip1 Deselect
	str	r1, [r0, #0x10]  @DMC_DIRECTCMD

	ldr	r1, =0x01100000	 @DirectCmd	chip1 PALL
	str	r1, [r0, #0x10]  @DMC_DIRECTCMD

	ldr	r1, =0x00120000	 @DirectCmd	chip1 EMRS2
	str	r1, [r0, #0x10]  @DMC_DIRECTCMD

	ldr	r1, =0x00130000	 @DirectCmd	chip1 EMRS3
	str	r1, [r0, #0x10]  @DMC_DIRECTCMD

	ldr	r1, =0x00110440	 @DirectCmd	chip1 EMRS1 (MEM DLL on, DQS# disable)
	str	r1, [r0, #0x10]  @DMC_DIRECTCMD

	ldr	r1, =0x00100542	 @DirectCmd	chip1 MRS (MEM DLL reset) CL=4, BL=4
	str	r1, [r0, #0x10]  @DMC_DIRECTCMD

	ldr	r1, =0x01100000	 @DirectCmd	chip1 PALL
	str	r1, [r0, #0x10]  @DMC_DIRECTCMD

	ldr	r1, =0x05100000	 @DirectCmd	chip1 REFA
	str	r1, [r0, #0x10]  @DMC_DIRECTCMD

	ldr	r1, =0x05100000	 @DirectCmd	chip1 REFA
	str	r1, [r0, #0x10]  @DMC_DIRECTCMD

	ldr	r1, =0x00100442	 @DirectCmd	chip1 MRS (MEM DLL unreset)
	str	r1, [r0, #0x10]  @DMC_DIRECTCMD

	ldr	r1, =0x00110780	 @DirectCmd	chip1 EMRS1 (OCD default)
	str	r1, [r0, #0x10]  @DMC_DIRECTCMD

	ldr	r1, =0x00110400	 @DirectCmd	chip1 EMRS1 (OCD exit)
	str	r1, [r0, #0x10]  @DMC_DIRECTCMD

	ldr	r1, =0x0FF02030	 @ConControl	auto refresh on
	str	r1, [r0]

	ldr	r1, =0xFFFF00FF	 @PwrdnConfig
	str	r1, [r0, #0x28]  @DMC_PWRDNCONFIG

	ldr	r1, =0x00202400	 @ BL=4, 2 chip, DDR2 type, dynamic self refresh, force precharge, dynamic power down off
	str	r1, [r0, #0x04]  @DMC_MEMCONTROL

	mov	pc, lr
