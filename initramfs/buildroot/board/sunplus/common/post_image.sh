#!/bin/bash

IMAGE_DIR=$1
TARGET_DIR=../disk

if [ ! -f $IMAGE_DIR/rootfs.tar ]; then
	exit 0;
fi

rm -rf $TARGET_DIR
mkdir -p $TARGET_DIR
tar -xf $IMAGE_DIR/rootfs.tar -C $TARGET_DIR
