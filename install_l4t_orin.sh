#!/bin/bash
# Installation of dtb, cfg and extlinux.conf file for building L4T for Orin NX on the EchoPilot AI
# Usage: ./install_l4t_orin.sh [path to Linux_for_Tegra]

if [[ $# != 1 ]] ; then
  echo 'USAGE: ./install_l4t_orin.sh <Path to Linux_for_Tegra, e.g. ~/Orin/Linux_for_Tegra/>'
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

echo "Copying files..."
# copy files
cp Linux_for_Tegra/bootloader/t186ref/BCT/tegra234-mb2-bct-misc-p3767-0000.dts $INSTALL_PATH/bootloader/t186ref/BCT/.                                          
cp Linux_for_Tegra/bootloader/t186ref/BCT/tegra234-mb2-bct-scr-p3767-0000.dts $INSTALL_PATH/bootloader/t186ref/BCT/.
cp Linux_for_Tegra/kernel/dtb/tegra234-p3767-0000-p3509-a02.dtb $INSTALL_PATH/kernel/dtb/.


echo ""
echo "Success!!!"
echo ""
echo ""
echo "Flash the Orin from the Linux_for_Tegra directory using the command: sudo ./tools/kernel_flash/l4t_initrd_flash.sh --external-device nvme0n1p1 -c tools/kernel_flash/flash_l4t_external.xml -p "-c bootloader/t186ref/cfg/flash_t234_qspi.xml" --showlogs --network usb0 p3509-a02+p3767-0000 internal"
