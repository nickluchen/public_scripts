#!/bin/bash

PASSWD_FILE=/home/${USER}/.vnc/passwd

if [ ! -f ${PASSWD_FILE} ]; then
  echo "The passwd file ${PASSWD_FILE} cannot be found."
  echo "Please execute following command to create it."
  echo "x11vnc -storepasswd"
else
  x11vnc -auth guess -forever -loop -noxdamage -repeat -rfbauth ${PASSWD_FILE} -rfbport 5900 -shared
fi
