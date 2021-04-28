#!/usr/bin/env zsh

set -e

source ./env.sh

if [ ! -f ./gettext-0.21.tar.xz ];then
  curl -OL https://ftp.gnu.org/gnu/gettext/gettext-0.21.tar.xz
fi

if [ ! -d ./gettext-0.21 ];then
  tar -xzvf ./gettext-0.21.tar.xz
fi

cd ./gettext-0.21/gettext-runtime
./configure --prefix=/usr/local --disable-dependency-tracking --enable-static --disable-shared
make -j ${CPU_NUM} && make install
cd ../..

cat <<EOF > /usr/local/lib/pkgconfig/intl.pc
prefix=/usr/local
libdir=\${prefix}/lib
includedir=\${prefix}/include

Name: libintl
Description: gettext runtime
Version: 0.21
Libs: -L\${libdir} -lintl
Libs.private:
Cflags: -I\${includedir}
EOF