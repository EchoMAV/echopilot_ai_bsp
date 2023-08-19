#!/bin/bash
# Installation of dtb, cfg and extlinux.conf file for building L4T for Nano on the EchoPilot AI
# Usage: ./install_l4t_nano.sh [path to Linux_for_Tegra]

if [[ $# != 1 ]] ; then
  echo 'USAGE: ./install_l4t_nano.sh <Path to Linux_for_Tegra, e.g. ~/Nano/Linux_for_Tegra/>'
  exit 0
fi

if [ ! -d $1 ]
then
    echo "Error: Path to Linux_for_Tegra does not appear to be valid, please fix and try again."
    exit 0
fi

INSTALL_PATH=$(realpath -s $1)

# verify that the path contains "Linux_for_Tegra"
if [[ "$INSTALL_PATH" != *"Linux_for_Tegra"* ]]; then
  echo "Error: the directory Linux_for_Tegra is not found in the path specified."
  exit 0
fi

echo "Using Install Path: " $INSTALL_PATH
# make folders if they don't exist
echo "Making directories..."
mkdir -p $INSTALL_PATH/rootfs/boot/extlinux
mkdir -p $INSTALL_PATH/kernel/dtb
echo ""
echo "Copying files..."
# copy files
cp Linux_for_Tegra/rootfs/boot/extlinux/extlinux.conf $INSTALL_PATH/rootfs/boot/extlinux/.
cp Linux_for_Tegra/kernel/dtb/tegra210-p3448-0002-p3449-0000-b00.dtb $INSTALL_PATH/kernel/dtb/.
echo ""
echo "Success!!"
echo ""
echo "flash the Xavier NX from the Linux_for_Tegra directory using: sudo ./flash.sh jetson-nano-emmc mmcblk0p1"