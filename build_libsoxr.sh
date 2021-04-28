#!/usr/bin/env zsh

set -e

source ./env.sh

if [ ! -f ./soxr-0.1.3-Source.tar.xz ];then
  curl -OL https://downloads.sourceforge.net/project/soxr/soxr-0.1.3-Source.tar.xz
fi

if [ ! -d ./soxr-0.1.3-Source ];then
  tar -xzvf ./soxr-0.1.3-Source.tar.xz
fi

cd ./soxr-0.1.3-Source
mkdir -p build && cd build
cmake -DCMAKE_INSTALL_PREFIX=/usr/local -DBUILD_SHARED_LIBS=OFF -DBUILD_TESTS=OFF ..
make -j ${CPU_NUM} && make install
cd ..