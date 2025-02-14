#!/bin/bash
# Installation of dtb, cfg and extlinux.conf file for building L4T for Orin NX on the EchoPilot AI
# Usage: ./install_l4t_orin.sh [path to Linux_for_Tegra]

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
SUDO=$(test ${EUID} -ne 0 && which sudo)

apply_patch() {
  # try reverting patch incase it is already installed
  git -C "$1" apply --reverse --check "$2" &>/dev/null
  if [ $? == 0 ]; then
    git -C "$1" apply --reverse "$2" &>/dev/null
  fi
  # apply patch
  git -C "$1" apply --verbose "$2" &>/dev/null
}


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
  BSP_MAJOR=$(grep "^BSP_MAJOR=" "$BSP_PATH" | awk -F= '{print $2}')
  BSP_MINOR=$(grep "^BSP_MINOR=" "$BSP_PATH" | awk -F= '{print $2}')
  echo "Found L4T Version: $BSP_BRANCH.$BSP_MAJOR.$BSP_MINOR"
fi

if [ "$BSP_BRANCH" -eq 36 ]; then
  echo "Copying files for L4T $BSP_BRANCH.$BSP_MAJOR.$BSP_MINOR..."
  echo "Applying BSP patches..."
  # disable board eeprom requirement
  apply_patch $INSTALL_PATH/.. "$SCRIPT_DIR"/patches/0001-disable-board-eeprom-requirement.patch
  if [ "$BSP_MAJOR" -lt 4 ]; then
    # add fix for disabled hdmi (corrected in 36.4+)
    apply_patch $INSTALL_PATH/.. "$SCRIPT_DIR"/patches/0001-fix-boot-with-missing-hdmi-on-orin-with-3rd-party-ca.patch
  fi
  # allow --reuse-uuid to be passed through from l4t_initrd_flash.sh to flash.sh when flashing external (NVMe) and internal (qspi) in the same command
  apply_patch $INSTALL_PATH/.. "$SCRIPT_DIR"/patches/0001-allow-reuse-uuid-to-be-passed-through-from-l4t_initr.patch

  # add fancontrol config
  $SUDO cp Linux_for_Tegra/rootfs/etc/nvpower/nvfancontrol/nvfancontrol_p3767_0000.conf $INSTALL_PATH/rootfs/etc/nvpower/nvfancontrol/. 

  # set systemd default target to multi-user instead of graphical
  $SUDO ln -sf /lib/systemd/system/multi-user.target $INSTALL_PATH/rootfs/etc/systemd/system/default.target

  # disable "Predictable Network Interface Names" (jetson builtin ethernet will revert to eth0)
  $SUDO ln -sf /dev/null $INSTALL_PATH/rootfs/etc/systemd/network/99-default.link

  # Copy custom device tree overlay files to the BSP
  echo "Installing custom DTBO files..."
  $SUDO cp Linux_for_Tegra/kernel/dtb/tegra234-p3767-echopilot-branding.dtbo $INSTALL_PATH/kernel/dtb/.
  $SUDO cp Linux_for_Tegra/kernel/dtb/tegra234-p3767-disable-display.dtbo $INSTALL_PATH/kernel/dtb/.
  $SUDO cp Linux_for_Tegra/kernel/dtb/tegra234-p3767-enable-serial.dtbo $INSTALL_PATH/kernel/dtb/.

  # Copy custom conf to the BSP
  # Enable "Super" variants on Jetson Orin Nano when available
  if [ "$BSP_MAJOR" -lt 4 ] || ([ "$BSP_MAJOR" -eq 4 ] && [ "$BSP_MINOR" -lt 3 ]); then
    $SUDO cp Linux_for_Tegra/echopilot-ai-r3630-.conf $INSTALL_PATH/echopilot-ai.conf
  else
    $SUDO cp Linux_for_Tegra/echopilot-ai.conf $INSTALL_PATH/.
  fi

  echo "Success!!!"
  echo ""
  echo "You may now flash the Orin from the Linux_for_Tegra directory using the command:"    
  echo 'sudo ./tools/kernel_flash/l4t_initrd_flash.sh --external-device nvme0n1p1 -c tools/kernel_flash/flash_l4t_external.xml -p "-c bootloader/generic/cfg/flash_t234_qspi.xml --no-systemimg" --network usb0 echopilot-ai external'
  echo ""
elif [ "$BSP_BRANCH" -eq 35 ]; then     
  echo "Copying files for L4T 35..."
  # disable board eeprom requirement
  apply_patch $INSTALL_PATH/.. patches/0001-disable-board-eeprom-requirement-r35.patch
  # add fix for disabled hdmi (corrected in 36.4+)
  apply_patch $INSTALL_PATH/.. patches/0001-fix-boot-with-missing-hdmi-on-orin-with-3rd-party-ca-r35.patch
  # allow --reuse-uuid to be passed through from l4t_initrd_flash.sh to flash.sh when flashing external (NVMe) and internal (qspi) in the same command
  apply_patch $INSTALL_PATH/.. "$SCRIPT_DIR"/patches/0001-allow-reuse-uuid-to-be-passed-through-from-l4t_initr-r35.patch

  # add fancontrol config
  $SUDO cp Linux_for_Tegra/rootfs/etc/nvpower/nvfancontrol/nvfancontrol_p3767_0000.conf $INSTALL_PATH/rootfs/etc/nvpower/nvfancontrol/. 

  # set systemd default target to multi-user instead of graphical
  $SUDO ln -sf /lib/systemd/system/multi-user.target $INSTALL_PATH/rootfs/etc/systemd/system/default.target

  # disable "Predictable Network Interface Names" (jetson builtin ethernet will revert to eth0)
  $SUDO ln -sf /dev/null $INSTALL_PATH/rootfs/etc/systemd/network/99-default.link

  # Copy custom device tree overlay files to the BSP
  echo "Installing custom DTBO files..."
  $SUDO cp Linux_for_Tegra/kernel/dtb/tegra234-p3767-echopilot-branding.dtbo $INSTALL_PATH/kernel/dtb/.
  $SUDO cp Linux_for_Tegra/kernel/dtb/tegra234-p3767-disable-display.dtbo $INSTALL_PATH/kernel/dtb/.
  $SUDO cp Linux_for_Tegra/kernel/dtb/tegra234-p3767-enable-serial-r35.dtbo $INSTALL_PATH/kernel/dtb/.

  # Copy custom conf to the BSP
  $SUDO cp Linux_for_Tegra/echopilot-ai-r35.conf $INSTALL_PATH/echopilot-ai.conf

  echo "Success!!!"
  echo ""
  echo "You may now flash the Orin from the Linux_for_Tegra directory using the command:"
  echo 'sudo ./tools/kernel_flash/l4t_initrd_flash.sh --external-device nvme0n1p1 -c tools/kernel_flash/flash_l4t_external.xml -p "-c bootloader/t186ref/cfg/flash_t234_qspi.xml --no-systemimg" --network usb0 echopilot-ai external'
  echo ""
else
  echo "Version ${BSP_BRANCH} of L4T detected is not supported. Please use L4T 35.x or 36.x"
fi
