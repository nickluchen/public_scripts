#!/bin/bash

# Executing 32-bit binary on 64-bit OS
# Especially for using linaro arm-linux GCC on 64-bit Linux host (you might see the error like "error while loading shared libraries: libz.so.1")

if [ -n "`cat /etc/issue | grep Debian`" ]; then
  echo It is Debian
  sudo dpkg --add-architecture i386
  sudo apt-get update
  sudo apt-get install libncurses5:i386 libstdc++6:i386 zlib1g:i386 libc6:i386
elif [ -n "`cat /etc/issue | grep Ubuntu`" ]; then
  echo It is Ubuntu
  sudo apt-get install libc6-i386 lib32stdc++6 lib32z1
else
  echo It does not support non-Debian/Ubuntu distro. Quit.
  exit -1
fi

