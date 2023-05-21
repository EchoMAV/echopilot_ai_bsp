#!/bin/bash
# Installation of hardware definition files for building PX4 for the EchoPilot AI
# Usage: ./install_px4.sh [path to PX4-Autopilot]

# remove trailing slash if present

if [[ $# != 1 ]] ; then
  echo 'USAGE: ./install_px4.sh <PX4-Autopilot full path, e.g. ~/PX4-Autopilot>'
  exit 0
fi

if [ ! -d $1 ]
then
    echo "Error: Path to PX4-autopilot does not appear to be valid, please fix and try again."
    exit 0
fi

INSTALL_PATH=$(realpath -s $1)
echo "Using Install Path: " $INSTALL_PATH

echo "Copying files..."
# copy files
cp Linux_for_Tegra/boot/extlinux/extlinux.conf $INSTALL_PATH/Linux_for_Tegra/boot/extlinux/.

# copy files
cp PX4-Autopilot/boards/echomav -r $INSTALL_PATH/boards/.

echo "Complete."
echo "You may now build PX4 using:"
echo "cd" $INSTALL_PATH
echo "make echomav_echopilot-ai"

