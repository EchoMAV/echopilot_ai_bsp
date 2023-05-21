# EchoPilot AI Board Support Package

This repo provides the board support files for the EchoPilot AI hardware.  

Clone this repo:  
```
git clone https://github.com/EchoMAV/echopilot_ai_bsp
```
Checkout the appropriate branch for your EchoPilot AI board revision (Revision is noted near the FAN connector). E.g., for revision 0:  
```
git checkout board_revision_0
```
Now proceed using the install scripts below based on what firmware you are building.

## Ardupilot

Assuming that ardupilot is installed at `~/ardupilot`.    

To install the hwdef files for Ardupilot (assuming Ardupilot code base is already set up and you can succesfully compile), then:
```
./install_ardupilot.sh ~/ardupilot
```

## PX4

Assuming that PX4 is installed at `~/PX4-Autopilot`. If not, please adjust the path argument to the script below.  

To install the board files for PX$ (assuming PX4 code base is already set up and you can succesfully build PX4):
```
./install_px4.sh ~/PX4-Autopilot
```

## Linux for Tegra

Assuming that L4T (Linux_for_Tegra) folder is installed at `~/XavierNX/Linux_for_Tegra`. If not, please adjust the path argument for the script below.  

Select the appropriate install script for the Jetson hardware used. e.g. XavierNX = `install_l4t_xavier_nx.sh`.  

To install the BSP files to build L4T:
```
./install_l4t_xavier_nx.sh ~/XavierNX/Linux_for_Tegra
```