#!/bin/sh

pkill -15 uvc-gadget
sleep 1  # Allow time for graceful shutdown
# Check if any uvc-gadget processes are still running and force kill if necessary
if pgrep uvc-gadget > /dev/null; then
	pkill -9 uvc-gadget
	sleep 1
fi
sleep 1
/etc/init.d/S50usbdevice restart > /dev/null 2>&1
