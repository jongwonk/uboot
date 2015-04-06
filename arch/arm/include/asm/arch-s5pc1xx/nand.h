
#ifndef	_S5PC110_NAND_H_
#define	_S5PC110_NAND_H_

/* NAND FLASH */
struct s5pc110_nand {
	u32	nfconf;
	u32	nfcont;
	u32	nfcmmd;
	u32	nfaddr;
	u32	nfdata;
	u32	nfmeccd0;
	u32	nfmeccd1;
	u32	nfseccd;
	u32	nfsblk;
	u32	nfeblk;
	u32	nfstat;
	u32	nfeccerr0;
	u32	nfeccerr1;	
	u32	nfmecc0;
	u32	nfmecc1;	
	u32	nfsecc;	
	u32	nfmlcbitpt;
	u32	nfeccconf;
	u32	nfecccont;
	u32	nfeccstat;
	u32	mfeccsecstat;
};

#endif
