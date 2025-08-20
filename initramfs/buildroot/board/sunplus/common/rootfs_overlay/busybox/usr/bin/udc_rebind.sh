#/bin/sh

UMS_EN=off
MTP_EN=off
ADB_EN=off
UVC_EN=off
UMS_BLOCK=""
UMS_LUN_FILE=""
GADGET_DEVICE=usb3

. /etc/usb_gadget.conf

PATH_TO_UMS_FILE=$USB_GADGET_DIR/functions/mass_storage.0/lun.0/file
PATH_TO_USB_CONFIG=/tmp/.usb_config
PATH_TO_UDC=$USB_GADGET_DIR/UDC
USB_CONFIG_FILE=/etc/.usb_config

if [ -f $USB_CONFIG_FILE ]; then
    while read line
    do
        case "$line" in
            usb_adb_en)
                ADB_EN=on
                ;;
            usb_uvc_en)
                UVC_EN=on
                ;;
        esac
    done < $USB_CONFIG_FILE
fi

find_gadget_devcie_config()
{
        while read line
        do
                NAME=`echo $line | awk -F "=" '{print $1}'`
                VAR=`echo $line | awk -F "=" '{print $2}'`
                if [ "$NAME" == "gadget_device" ]; then
                        GADGET_DEVICE=${VAR}
                fi
		echo "$NAME=$VAR" >  /dev/kmsg
        done < /etc/.usb_config
}


find_ums_config()
{
	while read line
	do
		NAME=`echo $line | awk -F "=" '{print $1}'`
		VAR=`echo $line | awk -F "=" '{print $2}'`
		if [ "$NAME" == "ums_block" ]; then
			UMS_BLOCK=${VAR}
		fi
		if [ "$NAME" == "ums_lun_file" ]; then
			UMS_LUN_FILE=${VAR}
		fi
		if [ "$NAME" == "ums_block_auto_mount" ]; then
			UMS_AUTO_MOUNT=${VAR}
		fi
	done < ${PATH_TO_USB_CONFIG}
}

find_spec_function()
{
	functions=`cat $USB_GADGET_DIR/configs/b.1/strings/0x409/configuration`

	functions=${functions}_over_
	tmp=`echo $functions | awk -F "_" '{print $1}'`

	while [ "${tmp}" != "over" ]; do
		test "$tmp" == "mtp" && MTP_EN=on
		test "$tmp" == "ums" && UMS_EN=on
		test "$tmp" == "adb" && ADB_EN=on
		functions=${functions#*_}
		tmp=`echo $functions | awk -F "_" '{print $1}'`
	done
}


if [ -a /tmp/.udc_pause  ]; then
	exit
fi

find_gadget_devcie_config
UDC="f80a1000.dwc3"
if [ $GADGET_DEVICE = usb2 ]; then
    UDC="f8102800.usb"
fi

if [ -e $USB_GADGET_DIR/UDC  ]; then
	echo $UDC > "$USB_GADGET_DIR/UDC"
fi
if [ $GADGET_DEVICE = usb2 ]; then
	echo d > /sys/bus/platform/devices/f8102800.usb/udc_ctrl
fi
find_spec_function
if [ $UMS_EN = on ]; then
	find_ums_config
	if [ $UMS_AUTO_MOUNT = on ]; then
		umount -f /mnt/ums
	fi
	VAR=`cat ${PATH_TO_UMS_FILE}`
	test -z ${VAR} && echo ${UMS_LUN_FILE} > ${PATH_TO_UMS_FILE}
fi
