# https://gist.github.com/raulqf/f42c718a658cddc16f9df07ecc627be7

sudo apt update
sudo apt upgrade -y

sudo apt install -y build-essential cmake pkg-config unzip yasm git checkinstall

sudo apt install -y libjpeg-dev libpng-dev libtiff-dev

sudo apt install -y libavcodec-dev libavformat-dev libswscale-dev libavresample-dev
sudo apt install -y libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev
sudo apt install -y libxvidcore-dev x264 libx264-dev libfaac-dev libmp3lame-dev libtheora-dev
sudo apt install -y libfaac-dev libmp3lame-dev libvorbis-dev

sudo apt install -y libopencore-amrnb-dev libopencore-amrwb-dev

sudo apt-get install -y libdc1394-22 libdc1394-22-dev libxine2-dev libv4l-dev v4l-utils
cd /usr/include/linux
sudo ln -s -f ../libv4l1-videodev.h videodev.h
cd ~

sudo apt-get install -y libgtk-3-dev

# sudo apt-get install python3-dev python3-pip
# sudo -H pip3 install -U pip numpy
# sudo apt install python3-testresources

sudo apt-get install -y libtbb-dev

sudo apt-get install -y libatlas-base-dev gfortran

sudo apt-get install -y libprotobuf-dev protobuf-compiler
sudo apt-get install -y libgoogle-glog-dev libgflags-dev
sudo apt-get install -y libgphoto2-dev libeigen3-dev libhdf5-dev doxygen

cd ~/Downloads
wget -O opencv.zip https://github.com/opencv/opencv/archive/refs/tags/4.5.2.zip
wget -O opencv_contrib.zip https://github.com/opencv/opencv_contrib/archive/refs/tags/4.5.2.zip
unzip opencv.zip
unzip opencv_contrib.zip

# echo "Create a virtual environtment for the python binding module (OPTIONAL)"
# sudo pip install virtualenv virtualenvwrapper
# sudo rm -rf ~/.cache/pip
# echo "Edit ~/.bashrc"
# export WORKON_HOME=$HOME/.virtualenvs
# export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3
# mkvirtualenv cv -p python3
# pip install numpy

echo "Procced with the installation"
cd opencv-4.5.2
mkdir build
cd build

# Without cuda
cmake -DCMAKE_BUILD_TYPE=RELEASE \
-DCMAKE_INSTALL_PREFIX=/usr/local \
-DOPENCV_GENERATE_PKGCONFIG=ON \
-DOPENCV_PC_FILE_NAME=opencv.pc \
-DOPENCV_ENABLE_NONFREE=ON \
-DOPENCV_EXTRA_MODULES_PATH=../../opencv_contrib-4.5.2/modules \
-DINSTALL_PYTHON_EXAMPLES=OFF \
-DINSTALL_C_EXAMPLES=OFF \
-DBUILD_EXAMPLES=OFF ..


nproc
make -j8
sudo make install

sudo /bin/bash -c 'echo "/usr/local/lib" >> /etc/ld.so.conf.d/opencv.conf'
sudo ldconfig

