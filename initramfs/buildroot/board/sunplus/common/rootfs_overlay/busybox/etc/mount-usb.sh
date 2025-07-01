#!/bin/sh

mkdir /mnt/udisk
mount -t ntfs-3g -o rw,user /dev/sda1 /mnt/udisk
