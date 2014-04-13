#!/bin/bash

#
# my_create_bootable_usb.sh
#
# Usage: my_create_bootable_usb.sh "iso_path" "usb_mounted_point"
#
# Creates a bootable USB flash drive with a Linux distribution inside it.
# The USB drive used must be already mounted, and will be formated, so it's
# important to backup the USB data before executing the script.
#
# If iso_path or usb_mounted_point contanis names with whitespaces, they must
# be specified using "" (i.e. "iso_path" and/or "usb_mounted_point").
#
# Exit status:
#  · 0 -> Success
#  · 1 -> Fail (bad function usage, wrong number of defined argument. etc.)
#  · 2 -> Linux image specified as argument does not exists
#  · 3 -> There isn't any USB drive mounted on mount point specified as argument
#  · 4 -> The process terminates with errors during the iso image copy
#

function usage () {
    echo "Usage: bootable_usb [-d] iso_path usb_mounted_point"
    echo -e "More information can be found by reading the script file."
    exit 1
}

if ! [[ ($# -eq 3 && $1 = "-d") || ($# -eq 2 && $1 != "-d") ]] ; then
    usage
fi

# Variable that defines debug mode status
DBG=0

# Check if first argument sets up '-d' flag (debug mode on)
if [ "$1" = "-d" ] ; then
    DBG=1
    shift 1
fi

ISO_PATH="$1"
OLD_MNT_USB="$2"
USB_LABEL="USB_DEVICE"
NEW_MNT_USB="$(dirname "${OLD_MNT_USB}")/${USB_LABEL}"
USB_DEV_PART_PATH="$(df | grep "${OLD_MNT_USB}" | cut -d ' ' -f1)"
USB_DEV_PATH="$(echo "${USB_DEV_PART_PATH}" | sed 's/[0-9]*//g')"

# Checks if the defined iso image exists
if [ ! -f "${ISO_PATH}" ] ; then
    echo "Linux image ${ISO_PATH} does not exists."
    exit 2
fi

# Checks if the defined mount point has a USB device associated and mounted
if [ "x${USB_DEV_PART_PATH}" = "x" ] ; then
    echo "There isn't any USB drive mounted on ${OLD_MNT_USB}"
    exit 3
fi

# Firstly formats the USB drive
echo -e "Formatting USB device...\n"
if [ $DBG -eq 0 ] ; then
    sudo umount ${USB_DEV_PART_PATH} &> /dev/null
    sudo mkfs.vfat -n ${USB_LABEL} ${USB_DEV_PART_PATH} &> /dev/null
else
    sudo umount ${USB_DEV_PART_PATH}
    sudo mkfs.vfat -n ${USB_LABEL} ${USB_DEV_PART_PATH}
fi

# Secondly creates the bootable USB flash drive
echo -e "\nCreating the bootable USB flash drive using $(basename ${ISO_PATH}) Linux image..."
if [ $DBG -eq 0 ] ; then
    sudo mkdir -p ${NEW_MNT_USB} &> /dev/null
    sudo mount -t vfat ${USB_DEV_PART_PATH} ${NEW_MNT_USB} &> /dev/null

    isohybrid ${ISO_PATH} &> /dev/null
    sudo dd if=${ISO_PATH} of=${USB_DEV_PATH} &> /dev/null
    DD_ERROR="$?"

    sync &> /dev/null

    sudo umount ${USB_DEV_PART_PATH} &> /dev/null
    sudo rm -r ${NEW_MNT_USB} &> /dev/null
else
    sudo mkdir -p ${NEW_MNT_USB}
    sudo mount -t vfat ${USB_DEV_PART_PATH} ${NEW_MNT_USB}

    isohybrid ${ISO_PATH}
    sudo dd if=${ISO_PATH} of=${USB_DEV_PATH}
    DD_ERROR="$?"

    sync

    sudo umount ${USB_DEV_PART_PATH}
    sudo rm -r ${NEW_MNT_USB}
fi

if [ ${DD_ERROR} -ne 0 ] ; then
    echo -e "\nThe process terminates with errors during the iso image copy."
    exit 4
fi

echo -e "\nThe bootable USB flash device has been created successfully!\nYou can eject the USB device."
exit 0

