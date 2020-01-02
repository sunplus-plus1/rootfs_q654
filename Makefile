.PHONY: rootfs initramfs initramfs_update clean

# v5 or v7
rootfs_cfg ?= v7
# EMMC NAND SPINOR SDCARD
boot_from ?= EMMC

rootfs: initramfs_update
	@./gen_root.sh ${boot_from}

initramfs:
	@cd initramfs; export ARCH=$(ARCH); export CROSS=$(CROSS); ./build_disk.sh ${rootfs_cfg}; cd -

initramfs_update:
	@cd initramfs ; \
	 if [ ! -d disk ];then \
		export ARCH=$(ARCH); export CROSS=$(CROSS); ./build_disk.sh ${rootfs_cfg} ; \
	 else \
		export ARCH=$(ARCH); export CROSS=$(CROSS); ./build_disk.sh ${rootfs_cfg} update ; \
	 fi ; \
	 cd -

clean:
	@rm -rf rootfs.img initramfs/disk/ initramfs/busybox-1.31.1/
