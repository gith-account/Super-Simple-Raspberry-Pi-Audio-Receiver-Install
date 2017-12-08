#!/bin/bash
currentDir=$(
  cd $(dirname "$0")
  pwd
) 

START_PATH=$currentDir 
cd $START_PATH
export START_PATH
#--------------------------------------------------------------------
function tst {
    echo "===> Executing: $*"
    if ! $*; then
        echo "Exiting script due to error from: $*"
        exit 1
    fi	
}
#--------------------------------------------------------------------

# Install Pulse Audio & Bluez
tst sudo apt-get install bluez pulseaudio pulseaudio-module-bluetooth -y

# Install dbus for python
tst sudo apt-get install python-dbus -y

# Install espeak
tst sudo apt-get install -qy espeak

# Create users and priviliges for Bluez-Pulse Audio interaction - most should already exist
tst sudo addgroup --system pulse
tst sudo adduser --system --ingroup pulse --home /var/run/pulse pulse
tst sudo addgroup --system pulse-access
tst sudo adduser pulse audio
tst sudo adduser root pulse-access
tst sudo adduser pulse lp

tst sudo cp init.d/pulseaudio /etc/init.d
tst sudo chmod +x /etc/init.d/pulseaudio
tst sudo update-rc.d pulseaudio defaults

tst sudo cp init.d/bluetooth /etc/init.d
tst sudo chmod +x /etc/init.d/bluetooth
tst sudo update-rc.d bluetooth defaults


cd ~
git clone --branch v6.0 https://github.com/pulseaudio/pulseaudio
sudo apt-get install libtool intltool libsndfile-dev libcap-dev libjson0-dev libasound2-dev libavahi-client-dev libbluetooth-dev libglib2.0-dev libsamplerate0-dev libsbc-dev libspeexdsp-dev libssl-dev libtdb-dev libbluetooth-dev intltool -y

cd ~
git clone https://github.com/json-c/json-c.git
cd json-c
sh autogen.sh
./configure 
make
sudo make install
cd ~
sudo apt install autoconf autogen automake build-essential libasound2-dev libflac-dev libogg-dev libtool libvorbis-dev pkg-config python -y
git clone git://github.com/erikd/libsndfile.git
cd libsndfile
./autogen.sh
./configure --enable-werror
make
sudo make install
cd ~
cd pulseaudio
sudo ./bootstrap.sh
sudo make
sudo make install
sudo ldconfig
sudo cp /etc/pulsebackup/* /etc/pulse




cd $START_PATH
tst sudo cp etc/pulse/daemon.conf /etc/pulse
sudo patch /etc/pulse/system.pa << EOT
***************
*** 23,25 ****
  .ifexists module-udev-detect.so
! load-module module-udev-detect
  .else
--- 23,26 ----
  .ifexists module-udev-detect.so
! #load-module module-udev-detect
! load-module module-udev-detect tsched=0
  .else
***************
*** 57 ****
--- 58,63 ----
  load-module module-position-event-sounds
+
+ ### Automatically load driver modules for Bluetooth hardware
+ .ifexists module-bluetooth-discover.so
+     load-module module-bluetooth-discover
+ .endif
EOT
