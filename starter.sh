#!/bin/bash

# Usage: ./starter.sh params.sh

PARAMS=$1

if [ ! $PARAMS ]; then
    echo "No argument provided."
    echo "Usage: ./starter.sh params.sh"
    exit
fi
if [ ! -f $PARAMS ]; then
    echo "params file not found."
    echo "Usage: ./starter.sh params.sh"
    exit
fi

. ${PARAMS}

FILES_VERIFY_LIST="SD_DEV IMG_PATH"
VERIFIED="TRUE"
for bar in $FILES_VERIFY_LIST; do
    declare -n foo=${bar}
    if [ "$foo" == "" ]; then
        echo "$bar='$foo' is empty."
        echo "Check $PARAMS_FILE if it's properly defined?"
        VERIFIED="FALSE"
    fi
    if ! [[ -f $foo || -d $foo || -b $foo ]]; then
        echo "$bar='$foo' not found."
        echo "Check $PARAMS_FILE if it's properly defined?"
        VERIFIED="FALSE"
    fi
done

bar="MNT_PATH"
declare -n foo=${bar}
if [ -d $foo ]; then
    echo "$bar='$foo' already exists, pick dir that doesn't exist"
    VERIFIED="FALSE"
fi

export SD_P1="${SD_DEV}p1"
export SD_P2="${SD_DEV}p2"
export MNT_PATH_P1="${MNT_PATH}/p1"
export MNT_PATH_P2="${MNT_PATH}/p2"

VERIFY_STRINGS_LIST="$WIFI_SSID $WIFI_PASS $PI_CREDENTIALS $RASPBERRYPI_HOSTNAME"
for str in $VERIFY_STRINGS_LIST; do
    if [ "$str" == "" ]; then
        echo "$str is empty, is it properly defined? Check params.sh"
        VERIFIED="FALSE"
    fi
done

if [ ! "$VERIFIED" == "TRUE" ]; then
    echo "Errors were found during $PARAMS initiation"
    echo "See README.md"
    exit
fi

# burn SD Card
sudo mkfs.vfat -I ${SD_DEV}
sudo dd if=${IMG_PATH} of=${SD_DEV}

mkdir -p ${MNT_PATH_P1}
mount ${SD_P1} ${MNT_PATH_P1}
cat << EOF > ${MNT_PATH_P1}/userconf.txt
$PI_CREDENTIALS
EOF

# enable ssh
touch ${MNT_PATH_P1}/ssh

# boot setup
sed -i'' 's/$/ modules-load=dwc2,g_ether cgroup_enable=memory cgroup_memory=1 dwc_otg.lpm_enable=0 elevator=deadline/g' ${MNT_PATH_P1}/cmdline.txt
sed -i'' 's/^dtoverlay=vc4-kms-v3d$/#dtoverlay=vc4-kms-v3/g' ${MNT_PATH_P1}/config.txt
(echo "[all]"; echo "dtoverlay=dwc2") >> ${MNT_PATH_P1}/config.txt

# wifi setup
cat << EOF > ${MNT_PATH_P1}/wpa_supplicant.conf
country=US
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1

network={
 ssid="${WIFI_SSID}"
 scan_ssid=1
 psk="${WIFI_PASS}"
 key_mgmt=WPA-PSK
}
EOF

umount ${MNT_PATH_P1}
rmdir ${MNT_PATH_P1}

# OS partition
mkdir -p ${MNT_PATH_P2}
mount ${SD_P2} ${MNT_PATH_P2}

## change hostname
echo $RASPBERRYPI_HOSTNAME > ${MNT_PATH_P2}/etc/hostname
sed -i'' "s/raspberrypi/$RASPBERRYPI_HOSTNAME/g" ${MNT_PATH_P2}/etc/hosts

umount ${MNT_PATH_P2}
rmdir ${MNT_PATH_P2}

rmdir $MNT_PATH
