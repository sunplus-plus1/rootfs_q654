#! /bin/bash

HelpFunc() {
    echo "Usage:"
    echo "$0 ota_binary_path" 
    echo "Description:"
    echo "   You should first put ota binary into /data folder or subfolders"
    echo "   Then set ota_binary_path as ota binary file path"
    exit -1
}

if [ -z "$1" -o ! -f "$1" ]; then
    HelpFunc
fi

filepath="$(realpath "$1")"

if [[ "$filepath" != "/data/"* ]]; then
    HelpFunc
fi

fw_setenv ota_path "$filepath"
fw_setenv bootpart 2


reboot
