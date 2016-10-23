#!/usr/bin/env bash

cd
mkdir -p temp_ws/src
cd temp_ws/src
apt-get update
apt-get install -y software-properties-common
add-apt-repository -y ppa:git-core/ppa
apt-get update
apt-get install -y git
git clone https://github.com/geoffviola/ros2_boost
cd ..
ament build
tar -zcp -f install.tar install
