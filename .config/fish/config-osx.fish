if type -q exa
  alias ll "exa -l -g --icons"
  alias lla "ll -a"
end


# Android
set --export ANDROID $HOME/Library/Android;
set --export ANDROID_HOME $ANDROID/sdk;
set -gx PATH $ANDROID_HOME/tools $PATH;
set -gx PATH $ANDROID_HOME/tools/bin $PATH;
set -gx PATH $ANDROID_HOME/platform-tools $PATH;
set -gx PATH $ANDROID_HOME/emulator $PATH


# JAVA_HOME
set --export JAVA_HOME  /Library/Java/JavaVirtualMachines/jdk-15.0.1.jdk/Contents/Home;
set -gx PATH $JAVA_HOME/bin $PATH;