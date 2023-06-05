#!/bin/bash
# Installation of EchoPilot AI hwdef files for Ardupilot
# Usage: ./install_ardupilot.sh [path to ardupilot]

# remove trailing slash if present

if [[ $# != 1 ]] ; then
  echo 'USAGE: ./install_ardupilot.sh <Path to ardupilot e.g. ~/ardupilot>'
  exit 0
fi

if [ ! -d $1 ]
then
    echo "Error: Path to ardupilot does not appear to be valid, please fix and try again."
    exit 0
fi

INSTALL_PATH=$(realpath -s $1)
echo "Using Install Path: " $INSTALL_PATH
# make folders if they don't exist

echo "Copying hwdef files..."

# copy files
cp ardupilot/libraries/AP_HAL_ChibiOS/hwdef/EchoPilotAI -r $INSTALL_PATH/libraries/AP_HAL_ChibiOS/hwdef/.

echo "Complete."
echo "You may now build ardupilot (e.g. copter) using:"
echo "cd" $INSTALL_PATH
echo "./waf configure --board EchoPilotAI"
echo "./waf copter"
