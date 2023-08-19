#!/bin/bash
# Installation of dtb, cfg and extlinux.conf file for building L4T for Xavier NX on the EchoPilot AI
# Usage: ./install_l4t_xavier_nx.sh [path to Linux_for_Tegra]

if [[ $# != 1 ]] ; then
  echo 'USAGE: ./install_l4t_xavier_nx.sh <Path to Linux_for_Tegra, e.g. ~/XavierNX/Linux_for_Tegra/>'
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
mkdir -p $INSTALL_PATH/bootloader/t186ref/BCT
mkdir -p $INSTALL_PATH/kernel/dtb
echo ""
echo "Copying files..."
echo ""
# copy files
cp Linux_for_Tegra/rootfs/boot/extlinux/extlinux.conf $INSTALL_PATH/rootfs/boot/extlinux/.
cp Linux_for_Tegra/bootloader/t186ref/BCT/* $INSTALL_PATH/bootloader/t186ref/BCT/.
cp Linux_for_Tegra/kernel/dtb/tegra194-p3668-0001-p3509-0000.dtb $INSTALL_PATH/kernel/dtb/.
echo ""
echo "Success!!"
echo ""
echo "flash the Xavier NX from the Linux_for_Tegra directory using: sudo ./flash.sh jetson-xavier-nx-devkit-emmc mmcblk0p1"
