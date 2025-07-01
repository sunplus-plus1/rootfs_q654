#!/bin/bash

PROP_FILE=/etc/vicore/property/default.prop

function Usage()
{
    echo "Usage: $1 [cameraid,switch] [...]"
    echo "Available options are"
    echo "  cameraid    [0, 9]"
    echo "  switch      0: close hdr, 1: open hdr"
    echo ""
    echo "Example camera 0 open hdr: $1 0,1"
    echo "Example camera 1 close hdr: $1 1,0"
    echo "Example camera 0 close and camera 1 open hdr: $1 0,0 1,1"
}

function PrintSwitch()
{
    echo -e "\n********** current hdr switch info **********"
    for i in {0..9}; do
        hdr_info=`cat ${PROP_FILE} | grep cammgr${i}.hdr_enable`
        if [ -z "${hdr_info}" ]; then
            break
        fi

        echo ${hdr_info}
    done
    echo -e "********** current hdr switch info **********\n"
}

if [ $# -eq 0 ]; then
    Usage $0
    PrintSwitch
    exit 0
fi

# fisrt check
for deal_camera in "$@"; do
    deal_info=(${deal_camera//,/ })
    if [ ${#deal_info[@]} -ne 2 ]; then
        echo -e "camera ${deal_camera} invalid\n"
        Usage $0
        exit 1
    fi

    camera_id="${deal_info[0]}"
    if [ "${camera_id}" -eq "${camera_id}" ] 2>/dev/null; then
        # must in [0, 9]
        if [ ${camera_id} -lt 0 ] || [ ${camera_id} -gt 9 ]; then
            echo -e "camera id ${camera_id} is invalid\n"
            Usage $0
            exit 1
        fi
    else
        echo -e "camera id ${camera_id} is not number\n"
        Usage $0
        exit 1
    fi

    hdr_switch="${deal_info[1]}"
    if [ ${hdr_switch} -ne 0 ] && [ ${hdr_switch} -ne 1 ]; then
        echo -e "camera id ${camera_id} hdr switch ${hdr_switch} invalid\n"
        Usage $0
        exit 1
    fi
done

# all check success, then set
IS_RESTART=0
for deal_camera in "$@"; do
    deal_info=(${deal_camera//,/ })
    camera_id="${deal_info[0]}"
    hdr_switch="${deal_info[1]}"

    hdr_switch_info="close"
    if [ ${hdr_switch} -eq 1 ]; then
        hdr_switch_info="open"
    fi

    cam_info=`cat ${PROP_FILE} | grep cammgr${camera_id}`
    if [ -z "${cam_info}" ]; then
        continue
    fi

    hdr_info=`cat ${PROP_FILE} | grep cammgr${camera_id}.hdr_enable`
    if [ -z "${hdr_info}" ]; then
        echo "cammgr${camera_id}.hdr_enable ${HDR_SWITCH}" >> ${PROP_FILE}
        IS_RESTART=1
        continue
    fi

    old_hdr_switch=`echo ${hdr_info} | awk '{print $2}'`
    if [ -z "${old_hdr_switch}" ] || [ "${old_hdr_switch}" != "${hdr_switch}" ]; then
        sed -i "s/cammgr${camera_id}.hdr_enable.*/cammgr${camera_id}.hdr_enable ${hdr_switch}/g" ${PROP_FILE}
        echo "camera id ${camera_id} hdr switch set ${hdr_switch_info}"
        IS_RESTART=1
    else
        echo "camera id ${camera_id} hdr switch had ${hdr_switch_info}"
    fi
done

if [ ${IS_RESTART} -eq 0 ]; then
    exit 0
fi

# restart propertyd
old_propertyd_pid=`ps aux | grep propertyd | grep -v grep | awk '{print $2}'`
if [ -n "${old_propertyd_pid}" ]; then
    kill -15 ${old_propertyd_pid}
    sleep 1
fi

tmp_propertyd_pid=`ps aux | grep propertyd | grep -v grep | awk '{print $2}'`
if [ -n "${tmp_propertyd_pid}" ]; then
    echo "stop propertyd failure"
    exit 1
fi

PROPERTY_CONFIG_FILE=/etc/vicore/property/default.prop
nohup propertyd ${PROPERTY_CONFIG_FILE} > /var/log/propertyd.log 2>&1 &
sleep 1
new_propertyd_pid=`ps aux | grep propertyd | grep -v grep | awk '{print $2}'`
if [ -z "${new_propertyd_pid}" ]; then
    echo "start propertyd failure"
    exit 1
fi

echo "restart propertyd success, pid from ${old_propertyd_pid} to ${new_propertyd_pid}"

# restart cammanager_daemon
old_cammanager_pid=`ps aux | grep cammanager_daemon | grep -v grep | awk '{print $2}'`
if [ -n "${old_cammanager_pid}" ]; then
    kill -15 ${old_cammanager_pid}
    sleep 1
fi

tmp_cammanager_pid=`ps aux | grep cammanager_daemon | grep -v grep | awk '{print $2}'`
if [ -n "${tmp_cammanager_pid}" ]; then
    echo "stop cammanager_daemon failure"
    exit 1
fi

nohup cammanager_daemon 2>&1 | logger -t cammanager -p user.info &
sleep 1
new_cammanager_pid=`ps aux | grep cammanager_daemon | grep -v grep | awk '{print $2}'`
if [ -z "${new_cammanager_pid}" ]; then
    echo "start cammanager_daemon failure"
    exit 1
fi

echo "restart cammanager_daemon success, pid from ${old_cammanager_pid} to ${new_cammanager_pid}"
PrintSwitch
exit 0
