#!/bin/bash

scaling=$(defaults read .GlobalPreferences com.apple.mouse.scaling)
echo "Current com.apple.mouse.scaling is: ${scaling}"

if [ "-1" -ne "${scaling}" ]; then
	echo "Set com.apple.mouse.scaling to -1"
	defaults write .GlobalPreferences com.apple.mouse.scaling -1
fi
