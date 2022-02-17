
# Android
set --export ANDROID $HOME/Library/Android;
set --export ANDROID_HOME $ANDROID/sdk;
set -gx PATH $ANDROID_HOME/tools $PATH;
set -gx PATH $ANDROID_HOME/tools/bin $PATH;
set -gx PATH $ANDROID_HOME/platform-tools $PATH;
set -gx PATH $ANDROID_HOME/emulator $PATH
set -gx PATH $ANDROID_HOME/cmdline-tools/latest/bin $PATH
set --export ADB $ANDROID_HOME/platform-tools/adb

# JAVA_HOME
set --export JAVA_HOME /usr/lib/jvm/java-11-openjdk-amd64
set -gx PATH $JAVA_HOME/bin $PATH;
