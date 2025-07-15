#!/bin/bash

ROOTFS_DIR=$1
if [-d $ROOTFS_DIR ]; then
	rm -rfv $ROOTFS_DIR/dev/*
fi

mkdir -p $ROOTFS_DIR/nv
mkdir -p $ROOTFS_DIR/data
