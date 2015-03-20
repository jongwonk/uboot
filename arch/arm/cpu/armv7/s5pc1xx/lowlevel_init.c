/*
 * Lowlevel setup for EXYNOS5 based board
 *
 * Copyright (C) 2013 Samsung Electronics
 * Rajeshwari Shinde <rajeshwari.s@samsung.com>
 *
 * See file CREDITS for list of people who contributed to this
 * project.
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston,
 * MA 02111-1307 USA
 */

#include <common.h>
#include <config.h>
#include <asm/arch/cpu.h>
#include <asm/armv7.h>
#include <asm/arch/power.h>

/* These are the things we can do during low-level init */
enum {
	DO_WAKEUP	= 1 << 0,
	DO_CLOCKS	= 1 << 1,
	DO_MEM_RESET= 1 << 2,
	DO_UART		= 1 << 3,
	DO_POWER	= 1 << 4,
};

uint32_t get_reset_status(void);
void system_clock_init(void);
void mem_ctrl_init(int action);
void tzpc_init(void);
void set_ps_hold_ctrl(void);

#if 0
int do_lowlevel_init(void)
{
	uint32_t reset_status;
	int actions = 0;

	arch_cpu_init();

	reset_status = get_reset_status();

	if(reset_status & S5P_CHECK_DIDLE)
	{	
		actions = DO_WAKEUP;
	}
	else
	{
		/* This is a normal boot (not a wake from sleep) */
		actions = DO_CLOCKS | DO_MEM_RESET | DO_POWER;
	}

	if (actions & DO_POWER)
		set_ps_hold_ctrl();

	if (actions & DO_CLOCKS) {
		system_clock_init();
		mem_ctrl_init(actions & DO_MEM_RESET);
		tzpc_init();
	}

	return actions & DO_WAKEUP;
}
#endif

uint32_t get_reset_status(void)
{
	return read_register(S5PC110_RST_STAT);
}

void system_clock_init(void)
{
	
}
	
void mem_ctrl_init(int action)
{

}

void tzpc_init(void)
{
	
}

void set_ps_hold_ctrl(void)
{
	
}
		



