#!/bin/bash

# arguments: create different rootfs by boot mode
# $1 : NAND EMMC SDCARD SPINOR (default: EMMC)
OUT_IMG=rootfs.img
WORK_DIR=./initramfs/disk

if [ "$1" = "EMMC" ];then
############################################  ext2 fs ############################################
	echo -e  "\E[1;33m ========make ext2 fs========== \E[0m"
	EXT2=./tools/mke2fs

	if [ ! -d $WORK_DIR ];then
		echo "Error: $WORK_DIR doesn't exist!"
		exit 1
	fi

	diskdir_sz=`du -sb $WORK_DIR | cut -f1`
	echo "rootfs total size =$diskdir_sz B"
	# 5% block reserved for superusers ,used 10% to calculation(mke2fs -m optiton)
	diskdir_sz=$((diskdir_sz*100/90))
	EXT2_SIZE=$((diskdir_sz/1024/1024+1))
	echo "rootfs create size = $EXT2_SIZE M"
	rm -rf $OUT_IMG

	$EXT2 -d "$WORK_DIR" -m 5 -b 4096 $OUT_IMG $((EXT2_SIZE))M 

elif [ "$1" = "NAND" ];then
############################################  ubi fs ############################################

#mkfs.ubifs+ubi write :Can automatically set the size of the root file system by partition size in ISP,
#					   use the ubi cmd to write rootfs into nand in ISP,need add ubi config in uboot; used it!!!
#mkfs.ubifs+ubinize+nand write: the rootfs size is fixed in ubi.cfg that used in ubinize function. this 
#					   can use the nand write cmd to write dat into nand ,no need do something in uboot.
	echo -e  "\E[1;33m ========make ubi fs========== \E[0m"
	MKFS_UBIFS=./tools/mkfs.ubifs
	UBINIZE=./tools/ubinize
	UBI_CFG=./ubi.cfg
	
	####modify this for different nand size#### 
	MAX_ERASE_BLK_CNT=2030    #nand size 1G:1020 2G:2030 
	NAND_PAGESIZE=2048
	NAND_BLK_PAGESIZE=64
	NAND_LOGIC_REASE_SIZE=$(($NAND_BLK_PAGESIZE-2))*$NAND_PAGESIZE  # size = (blockcnt-2)*2048

	if [ ! -d $WORK_DIR ];then
		echo "Error: $WORK_DIR doesn't exist!"
		exit 1
	fi
	
	if [ ! -x $MKFS_UBIFS ];then
		echo "Error: $MKFS_UBIFS doesn't exist!"
		exit 1
	fi
	$MKFS_UBIFS -r $WORK_DIR -m $NAND_PAGESIZE -e $(($NAND_LOGIC_REASE_SIZE)) -c $MAX_ERASE_BLK_CNT -F -o $OUT_IMG 

	if false; then #mkfs.ubifs+ubinize  not used

		NAND_ROOTFS_SIZE=100MiB
		NAND_BLK_SIZE=$NAND_BLK_PAGESIZE*$NAND_PAGESIZE  # size = blockcnt*2048
		## rootfs size need to smaller than rootfs partition size set in isp
		if [ 1020 -eq $MAX_ERASE_BLK_CNT ];then
			NAND_ROOTFS_SIZE=100MiB
			echo -e  "\E[1;33m 1G nand  \E[0m"
		elif [ 2030 -eq $MAX_ERASE_BLK_CNT ];then
			NAND_ROOTFS_SIZE=210MiB  
			echo -e  "\E[1;33m 2G nand  \E[0m"
		fi
		
		echo "[ubifs]" >$UBI_CFG
		echo "mode=ubi" >>$UBI_CFG
		echo "image=nand.img" >>$UBI_CFG
		echo "vol_id=0" >>$UBI_CFG
		echo "vol_type=dynamic" >>$UBI_CFG
		echo "vol_name=rootfs" >>$UBI_CFG
		echo "vol_flag=autoresize" >>$UBI_CFG
		echo "vol_size=$NAND_ROOTFS_SIZE" >>$UBI_CFG

		echo -e  "\E[1;33m ========rootfs = $NAND_ROOTFS_SIZE  pagesize=$NAND_PAGESIZE========== \E[0m"
		$MKFS_UBIFS -r $WORK_DIR -m $NAND_PAGESIZE -e $(($NAND_LOGIC_REASE_SIZE)) -c $MAX_ERASE_BLK_CNT -F -o nand.img 
		$UBINIZE -v -o $OUT_IMG -m $NAND_PAGESIZE -p $(($NAND_BLK_SIZE/1024))KiB $UBI_CFG
		rm -rf nand.img
	fi
else
#####################################  squash fs ############################################
	echo -e  "\E[1;33m ========make squash fs========== \E[0m"
	MKSQFS_COMPOPT="-comp lzo -Xcompression-level 9"
	MKSQFS=./tools/mksquashfs

	if [ ! -d $WORK_DIR ];then
		echo "Error: $WORK_DIR doesn't exist!"
		exit 1
	fi

	$MKSQFS $WORK_DIR $OUT_IMG -all-root -noappend $MKSQFS_COMPOPT

fi

