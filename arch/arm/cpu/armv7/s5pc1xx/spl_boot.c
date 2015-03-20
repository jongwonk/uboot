/*
 * Copyright (C) 2012 Samsung Electronics
 *
 * SPDX-License-Identifier:    GPL-2.0+
 */

#include <common.h>
#include <config.h>

#define BOOT_MODE_OM		0x0
#define BOOT_MODE_ONENAND   0x1
#define BOOT_MODE_NAND      0x2
#define BOOT_MODE_MMCSD     0x3
#define BOOT_MODE_NOR       0x4
#define BOOT_MODE_SEC_DEV   0x5

#define eFUSE_SIZE	512
#define MOVI_BLKSIZE	512
#define SS_SIZE		8*1024

#define PART_SIZE_BL	(512*1024)
#define PART_SIZE_KERNEL	(4*1024*1024)
#define PART_SIZE_ROOTFS	(26*1024*1024)

#define MOVI_BL1_BLKCNT	(SS_SIZE/MOVI_BLKSIZE)
#define MOVI_ENV_BLKCNT	(CONFIG_ENV_SIZE/MOVI_BLKSIZE)
#define MOVI_BL2_BLKCNT	(PART_SIZE_BL/MOVI_BLKSIZE)
#define MOVI_ZIMAGE_BLKCNT	(PART_SIZE_KERNEL/MOVI_BLKSIZE)

#define MOVI_BL2_POS	((eFUSE_SIZE/MOVI_BLKSIZE) + MOVI_BL1_BLKCNT + MOVI_ENV_BLKCNT)

typedef u32(*copy_sd_mmc_to_mem)(u32 channel, u32 start_block, u16 block_size, u32 *trg, u32 init);

unsigned int get_boot_mode(void);
void power_exit_wakeup(void);

DECLARE_GLOBAL_DATA_PTR;

/* Index into irom ptr table */
enum index {
#if 0
    NF8_ReadPage_Adv,
    NF16_ReadPage_Adv,
#endif 
    CopySDMMCtoMem,
#if 0
    CopyMMC4_3toMem,
    CopyOND_ReadMultiPages,
    CopyOND_ReadMultiPages_Adv,
#endif
};

/* IROM Function Pointers Table */
u32 irom_ptr_table[] = {
#if 0
    [NF8_ReadPage_Adv] = 0xD0037F90,
    [NF16_ReadPage_Adv] = 0xD0037F94,
#endif 
    [CopySDMMCtoMem] = 0xD0037F98,
#if 0
    [CopyMMC4_3toMem] = 0xD0037F9C,
    [CopyOND_ReadMultiPages] = 0xD0037FA0,
    [CopyOND_ReadMultiPages_Adv ] = 0xD0037FA4,
#endif 
    };

void *get_irom_func(int index)
{
    return (void *)*(u32 *)irom_ptr_table[index];
}

/*
* Copy U-boot from mmc to RAM:
* COPY_BL2_FNPTR_ADDR: Address in iRAM, which Contains
* Pointer to API (Data transfer from mmc to ram)
*/
void copy_uboot_to_ram(void)
{
    unsigned int bootmode = BOOT_MODE_OM;

    copy_sd_mmc_to_mem copy_bl2 = NULL;
    
    u32 offset = 0, size = 0;
    u32 ch = read_register(0xD0037488);

    if (bootmode == BOOT_MODE_OM)
      bootmode = get_boot_mode();
	
    switch (bootmode) {
    case BOOT_MODE_MMCSD:
        offset = MOVI_BL2_POS;
        size = MOVI_BL2_BLKCNT;
        copy_bl2 = get_irom_func(CopySDMMCtoMem);
        break;
    default:
        break;
    }

    if (copy_bl2)
    {
		if(ch == 0xEB000000)
		{
			copy_bl2(0,offset, size, (u32*)CONFIG_SYS_TEXT_BASE, 0);	
		}
		else if(ch == 0xEB200000)
		{
			copy_bl2(2, offset, size, (u32*)CONFIG_SYS_TEXT_BASE,0);
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
    __attribute__((noreturn)) void (*uboot)(void);

    setup_global_data(&local_gd);

#if 0
    if (do_lowlevel_init())
        power_exit_wakeup();
#endif

    copy_uboot_to_ram();

    /* Jump to U-Boot image */
    uboot = (void *)CONFIG_SYS_TEXT_BASE;
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
 
