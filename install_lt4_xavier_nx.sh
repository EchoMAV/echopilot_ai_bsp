#!/bin/bash
# Installation of dtb, cfg and extlinux.conf file for building L4T for Xavier NX on the EchoPilot AI
# Usage: ./install_l4t_xavier_nx.sh [path to Linux_for_Tegra]

# remove trailing slash if present

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
echo "Using Install Path: " $INSTALL_PATH
# make folders if they don't exist
echo "Making directories..."
mkdir -p $INSTALL_PATH/boot/extlinux
mkdir -p $INSTALL_PATH/bootloader/t186ref/BCT
mkdir -p $INSTALL_PATH/kernel/dtb

echo "Copying files..."
# copy files
cp Linux_for_Tegra/boot/extlinux/extlinux.conf $INSTALL_PATH/boot/extlinux/.
cp Linux_for_Tegra/bootloader/t186ref/BCT/* $INSTALL_PATH/bootloader/t186ref/BCT/.
cp Linux_for_Tegra/kernel/dtb/* $INSTALL_PATH/kernel/dtb/.

echo "Complete."
