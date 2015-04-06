/*
 * Copyright (C) 2012 Samsung Electronics
 *
 * SPDX-License-Identifier:    GPL-2.0+
 */

#include <common.h>
#include <config.h>

unsigned int get_boot_mode(void);
void power_exit_wakeup(void);

DECLARE_GLOBAL_DATA_PTR;

/* Index into irom ptr table */
enum index {
    NF8_ReadPage_Adv,
    NF16_ReadPage_Adv,
    CopySDMMCtoMem,
    CopyMMC4_3toMem,
    CopyOND_ReadMultiPages,
    CopyOND_ReadMultiPages_Adv,
};

/* IROM Function Pointers Table */
static u32 irom_ptr_table[] = {
    [NF8_ReadPage_Adv] = 0xD0037F90,
    [NF16_ReadPage_Adv] = 0xD0037F94,
    [CopySDMMCtoMem] = 0xD0037F98,
    [CopyMMC4_3toMem] = 0xD0037F9C,
    [CopyOND_ReadMultiPages] = 0xD0037FA0,
    [CopyOND_ReadMultiPages_Adv ] = 0xD0037FA4,
    };

typedef u32(*copy_sd_mmc_to_mem)(u32 channel, u32 start_block, u16 block_size, u32 *trg, u32 init);
    	
static u32 get_irom_func(int index)
{
    return irom_ptr_table[index];
}

/*
* Copy U-boot from mmc to RAM:
* COPY_BL2_FNPTR_ADDR: Address in iRAM, which Contains
* Pointer to API (Data transfer from mmc to ram)
* 
*    BL1  -     4kb
*    BL2  - 512kb
*    ENV - 4kb
*    FDT  - 32kb
*/
void copy_uboot_to_ram(void)
{
	unsigned int ret;
	unsigned int bootmode = BOOT_MODE_OM;
	copy_sd_mmc_to_mem copy_bl2 = NULL;

	u32 ch = *(volatile u32 *)(0xD0037488);

    if (bootmode == BOOT_MODE_OM)
      bootmode = get_boot_mode();

    switch (bootmode) {
    case BOOT_MODE_MMCSD:
    	copy_bl2 = (copy_sd_mmc_to_mem) (*(u32 *) get_irom_func(CopySDMMCtoMem));
        break;
    default:
        break;
    }
	
	if(copy_bl2)
	{
		if (ch == 0xEB000000) {
			ret = copy_bl2(0, MOVI_BL2_POS, MOVI_BL2_BLKCNT+MOVI_ENV_BLKCNT+MOVI_FDT_BLKCNT,
				(u32*)CONFIG_SYS_TEXT_BASE, 0);
				
		}
		else if (ch == 0xEB200000) {
			ret = copy_bl2(2, MOVI_BL2_POS, MOVI_BL2_BLKCNT+MOVI_ENV_BLKCNT+MOVI_FDT_BLKCNT,
					(u32*)CONFIG_SYS_TEXT_BASE, 0);
			
		}
	}
}

void memzero(void *s, size_t n)
{
    char *ptr = s;
    size_t i;

    for (i = 0; i < n; i++)
        *ptr++ = '\0';
}

/**
 * Set up the U-Boot global_data pointer
 *
 * This sets the address of the global data, and sets up basic values.
 *
 * @param gdp   Value to give to gd
 */
static void setup_global_data(gd_t *gdp)
{
    gd = gdp;
    memzero((void *)gd, sizeof(gd_t));
    gd->flags |= GD_FLG_RELOC;
    gd->baudrate = CONFIG_BAUDRATE;
    gd->have_console = 1;
}

void board_init_f(unsigned long bootflag)
{
    __aligned(8) gd_t local_gd;
    void (*uboot)(void);
        
    setup_global_data(&local_gd);

#if 0
    if (do_lowlevel_init())
        power_exit_wakeup();
#endif

    copy_uboot_to_ram();

    /* Jump to U-Boot image */
    uboot = CONFIG_SYS_TEXT_BASE;
	
    (*uboot)();
    /* Never returns Here */
}

/* Place Holders */
void board_init_r(gd_t *id, ulong dest_addr)
{
    /* Function attribute is no-return */
    /* This Function never executes */
    while (1)
        ;
}

unsigned int get_boot_mode(void)
{
	unsigned int om_pin = read_register(0xE0000004/*PRO_ID_BASE + OMR_OFFSET*/);

	return om_pin & 0x3F;
}

void power_exit_wakeup(void)
{
	
}

void save_boot_params(u32 r0, u32 r1, u32 r2, u32 r3) {}
 
