#!/bin/sh

# Clear dir
rm -rf $HOME/flutter

# Install flutter
git clone https://github.com/flutter/flutter.git -b stable $HOME/flutter

flutter precache

flutter config --no-analytics

dart --disable-analytics

flutter doctor
