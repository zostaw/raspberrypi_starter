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

FILES_VERIFY_LIST="SD_DEV IMG_PATH SD_P1 SD_P2"
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

VERIFY_STRINGS_LIST="$WIFI_SSID $WIFI_PASS $PI_CREDENTIALS"
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

mkdir ${MNT_PATH}
mount ${SD_P1} ${MNT_PATH}
cat << EOF > ${MNT_PATH}/userconf.txt
$PI_CREDENTIALS
EOF

# enable ssh
touch ${MNT_PATH}/ssh

# boot setup
sed -i'' 's/$/ modules-load=dwc2,g_ether cgroup_enable=memory cgroup_memory=1 dwc_otg.lpm_enable=0 elevator=deadline/g' ${MNT_PATH}/cmdline.txt
sed -i'' 's/^dtoverlay=vc4-kms-v3d$/#dtoverlay=vc4-kms-v3/g' ${MNT_PATH}/config.txt
(echo "[all]"; echo "dtoverlay=dwc2") >> ${MNT_PATH}/config.txt

# wifi setup
cat << EOF > ${MNT_PATH}/wpa_supplicant.conf
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

umount ${MNT_PATH}
