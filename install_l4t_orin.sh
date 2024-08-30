#!/bin/bash
# Installation of dtb, cfg and extlinux.conf file for building L4T for Orin NX on the EchoPilot AI
# Usage: ./install_l4t_orin.sh [path to Linux_for_Tegra]

SUDO=$(test ${EUID} -ne 0 && which sudo)

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

echo "Using Install Path:" $INSTALL_PATH

# check the BSP_BRANCH as different action is required for L4T 36+
BSP_PATH="${INSTALL_PATH}/nv_tegra/bsp_version"

echo "Looking for L4T Version at:" $BSP_PATH

# Check if the file exists
if [ ! -f "$BSP_PATH" ]; then
  #not found, lets assume 35
  BSP_BRANCH=35
  echo "Warning, L4T Version not found, defaulting to Vesion:" $BSP_BRANCH
else
  BSP_BRANCH=$(grep "^BSP_BRANCH=" "$BSP_PATH" | awk -F= '{print $2}')
  echo "Found L4T Version:" $BSP_BRANCH
fi

if [ "$BSP_BRANCH" -eq 36 ]; then    
    echo "Copying files for L4T 36..."
    # copy files
    cp Linux_for_Tegra/bootloader/t186ref/BCT/tegra234-mb2-bct-misc-p3767-0000.dts $INSTALL_PATH/bootloader/generic/BCT/.
    cp Linux_for_Tegra/bootloader/t186ref/BCT/tegra234-mb2-bct-scr-p3767-0000.dts $INSTALL_PATH/bootloader/generic/BCT/.
    cp Linux_for_Tegra/kernel/dtb/tegra234-p3767-0000-p3509-a02.dtb $INSTALL_PATH/kernel/dtb/.
    $SUDO cp Linux_for_Tegra/rootfs/etc/nvpower/nvfancontrol/nvfancontrol_p3767_0000.conf $INSTALL_PATH/rootfs/etc/nvpower/nvfancontrol/.    
    echo "Success!!!"
    echo ""
    echo "You may now flash the Orin from the Linux_for_Tegra directory using the command:"    
    echo 'sudo ./tools/kernel_flash/l4t_initrd_flash.sh -c ./tools/kernel_flash/flash_l4t_external.xml --external-device nvme0n1p1 -p "-c bootloader/generic/cfg/flash_t234_qspi.xml" p3509-a02-p3767-0000 internal'
    echo ""
elif [ "$BSP_BRANCH" -eq 35 ]; then     
    echo "Copying files for L4T 35..."
    # copy files
    cp Linux_for_Tegra/bootloader/t186ref/BCT/tegra234-mb2-bct-misc-p3767-0000.dts $INSTALL_PATH/bootloader/t186ref/BCT/.
    cp Linux_for_Tegra/bootloader/t186ref/BCT/tegra234-mb2-bct-scr-p3767-0000.dts $INSTALL_PATH/bootloader/t186ref/BCT/.
    cp Linux_for_Tegra/kernel/dtb/tegra234-p3767-0000-p3509-a02.dtb $INSTALL_PATH/kernel/dtb/.
    $SUDO cp Linux_for_Tegra/rootfs/etc/nvpower/nvfancontrol/nvfancontrol_p3767_0000.conf $INSTALL_PATH/rootfs/etc/nvpower/nvfancontrol/.    
    echo "Success!!!"
    echo ""
    echo "You may now flash the Orin from the Linux_for_Tegra directory using the command:"
    echo 'sudo ./tools/kernel_flash/l4t_initrd_flash.sh --external-device nvme0n1p1 -c tools/kernel_flash/flash_l4t_external.xml -p "-c bootloader/t186ref/cfg/flash_t234_qspi.xml" --showlogs --network usb0 p3509-a02+p3767-0000 internal'
    echo ""
else
    echo "Version ${BSP_BRANCH} of L4T detected is not supported. Please use L4T 35.x or 36.x"
fi





