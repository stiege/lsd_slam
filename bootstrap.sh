#! /bin/bash

sudo apt-get install -y git zip
cd /vagrant
mkdir /vagrant/lsd_slam_core/src/build
sudo ./install_deps_trusty.sh
cd /vagrant/lsd_slam_core/src/build
cmake -DCMAKE_BUILD_TYPE:string=Release -DBUILD_LOCAL_PANGOLIN=1 -DBUILD_LOCAL_G2O=1 ..
make deps && make all
export LD_LIBRARY_PATH=$(pwd)/Pangolin/lib:$(pwd)/g2o/lib
wget --progress=bar:force http://vmcremers8.informatik.tu-muenchen.de/lsd/LSD_room_images.zip
unzip LSD_room_images.zip
./LSD -c LSD_room/cameraCalibration.cfg -f LSD_room/images/
