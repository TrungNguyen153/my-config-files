#!/bin/sh


sudo apt install -y openjdk-11-jdk-headless # For android dev

# set default build arguments
SDK_VERSION=commandlinetools-linux-7302050_latest.zip
ANDROID_BUILD_VERSION=31
ANDROID_TOOLS_VERSION=31.0.0
NDK_VERSION=21.4.7075529
ANDROID_NDK=$ANDROID_HOME/ndk/$NDK_VERSION

rm -rf $ANDROID_HOME
echo "Begin install android sdk"


curl -sS https://dl.google.com/android/repository/$SDK_VERSION -o /tmp/sdk.zip \
    && mkdir -p $ANDROID_HOME/cmdline-tools \
    && unzip -q -d $ANDROID_HOME/cmdline-tools /tmp/sdk.zip \
    && mv $ANDROID_HOME/cmdline-tools/cmdline-tools $ANDROID_HOME/cmdline-tools/latest \
    && rm /tmp/sdk.zip \
    && yes | sdkmanager --licenses \
    && yes | sdkmanager "platform-tools" \
        "emulator" \
        "platforms;android-$ANDROID_BUILD_VERSION" \
        "build-tools;$ANDROID_TOOLS_VERSION" \
        "cmake;3.18.1" \
        "system-images;android-21;google_apis;armeabi-v7a" \
        "ndk;$NDK_VERSION" \
    && rm -rf $ANDROID_HOME/.android \
    && ln -s $ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64/lib64/clang/9.0.9 $ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64/lib64/clang/9.0.8

echo "Done install android sdk"
