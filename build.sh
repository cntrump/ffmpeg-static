#!/usr/bin/env zsh

set -e

FFMPEG_VERSION=4.4
MIN_TARGET=10.9

export MACOSX_DEPLOYMENT_TARGET=${MIN_TARGET}
export CC=clang CXX=clang++

brew update
brew upgrade
brew install pkg-config cmake automake libtool yasm 
brew install openssl aom libass libbluray dav1d libgsm libmodplug lame opencore-amr openh264 openjpeg opus rubberband snappy libsoxr speex theora twolame libvidstab libvmaf libvpx wavpack webp x264 x265 xvid zimg zmq fdk-aac

cd /tmp

if [ -d ./libmysofa ]; then
  rm -rf ./libmysofa
fi

git clone --depth=1 https://github.com/hoene/libmysofa.git
cd ./libmysofa/build
cmake -DCMAKE_INSTALL_PREFIX=/usr/local -DBUILD_SHARED_LIBS=OFF -DBUILD_TESTS=OFF ..
make install mysofa-static

cd ../..

if [ -d ./shine ]; then
  rm -rf ./shine
fi

git clone --depth=1 https://github.com/toots/shine.git
cd ./shine
./bootstrap
CC=clang \
CFLAGS="-mmacosx-version-min=${MIN_TARGET}" \
CPPFLAGS="-mmacosx-version-min=${MIN_TARGET}" \
LDFLAGS="-mmacosx-version-min=${MIN_TARGET}" \
./configure --prefix=/usr/local --disable-shared
make && make install

cd ..

if [ -d ./vo-amrwbenc-0.1.3 ]; then
  rm -rf ./vo-amrwbenc-0.1.3
fi

curl -O https://raw.githubusercontent.com/cntrump/build_ffmpeg_brew/master/vo-amrwbenc-0.1.3.tar.gz
tar -zxvf ./vo-amrwbenc-0.1.3.tar.gz
cd ./vo-amrwbenc-0.1.3
CC=clang \
CFLAGS="-mmacosx-version-min=${MIN_TARGET}" \
CPPFLAGS="-mmacosx-version-min=${MIN_TARGET}" \
LDFLAGS="-mmacosx-version-min=${MIN_TARGET}" \
./configure --prefix=/usr/local --disable-shared
make && make install

cd ..

if [ -d ./xavs ]; then
  rm -rf ./xavs
fi

curl -O https://raw.githubusercontent.com/cntrump/build_ffmpeg_brew/master/xavs.tar.bz2
tar -jxvf ./xavs.tar.bz2
cd ./xavs
./configure --prefix=/usr/local --host=x86_64-darwin --disable-asm \
            --extra-cflags="-mmacosx-version-min=${MIN_TARGET}" \
            --extra-ldflags="-mmacosx-version-min=${MIN_TARGET}"
make && make install

cd ..

if [ -d ./zvbi-0.2.35 ]; then
  rm -rf ./zvbi-0.2.35
fi

curl -O https://raw.githubusercontent.com/cntrump/build_ffmpeg_brew/master/zvbi-0.2.35.tar.bz2
tar -jxvf ./zvbi-0.2.35.tar.bz2
cd ./zvbi-0.2.35
CC=clang \
CFLAGS="-mmacosx-version-min=${MIN_TARGET}" \
CPPFLAGS="-mmacosx-version-min=${MIN_TARGET}" \
LDFLAGS="-mmacosx-version-min=${MIN_TARGET}" \
./configure --prefix=/usr/local --disable-shared
make && make install

cd ..

if [ -d ./AviSynthPlus ]; then
  rm -rf ./AviSynthPlus
fi

git clone --depth=1 -b v3.7.0 https://github.com/AviSynth/AviSynthPlus.git
cd ./AviSynthPlus
mkdir ./avisynth-build && cd ./avisynth-build
cmake ../ -DHEADERS_ONLY:bool=on
make install

cd ../..

if [ -d ./ffmpeg-${FFMPEG_VERSION} ]; then
  rm -rf ./ffmpeg-${FFMPEG_VERSION}
fi

curl -O https://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.bz2
tar -jxvf ./ffmpeg-${FFMPEG_VERSION}.tar.bz2
cd ./ffmpeg-${FFMPEG_VERSION}

echo Building ffmpeg-${FFMPEG_VERSION} ...

export PKG_CONFIG_PATH=/usr/local/opt/openssl@1.1/lib/pkgconfig:/usr/local/lib/pkgconfig
sysroot=`xcrun --sdk macosx --show-sdk-path` \
./configure --prefix=/usr/local --extra-version=lvv.me \
            --enable-avisynth --enable-fontconfig --enable-gpl --enable-libaom --enable-libass --enable-libbluray --enable-libdav1d --enable-libfreetype --enable-libgsm --enable-libmodplug --enable-libmp3lame --enable-libmysofa --enable-libopencore-amrnb --enable-libopencore-amrwb --enable-libopenh264 --enable-libopenjpeg --enable-libopus --enable-librubberband --enable-libshine --enable-libsnappy --enable-libsoxr --enable-libspeex --enable-libtheora --enable-libtwolame --enable-libvidstab --enable-libvmaf --enable-libvo-amrwbenc --enable-libvorbis --enable-libvpx --enable-libwebp --enable-libx264 --enable-libx265 --enable-libxavs --enable-libxvid --enable-libzimg --enable-libzmq --enable-libzvbi --enable-version3 --pkg-config-flags=--static --disable-ffplay \
            --enable-nonfree --enable-libfdk-aac --enable-openssl \
            --cc=${CC} --cxx=${CXX} \
            --pkg-config-flags="--static" \
            --extra-cflags="-Wl,-static,-search_paths_first -I${sysroot}/usr/include -I/usr/local/include -I/usr/local/opt/openssl@1.1/include -I/usr/local/opt/libgsm/include -I/usr/local/opt/lame/include -I/usr/local/opt/opencore-amr/include -I/usr/local/opt/snappy/include -I/usr/local/opt/libsoxr/include -I/usr/local/opt/libogg/include -I/usr/local/opt/theora/include -I/usr/local/opt/twolame/include -mmacosx-version-min=${MIN_TARGET}" \
            --extra-ldflags="-L${sysroot}/usr/lib -L/usr/local/lib -L/usr/local/opt/openssl@1.1/lib -L/usr/local/opt/libgsm/lib -L/usr/local/opt/lame/lib -L/usr/local/opt/opencore-amr/lib -L/usr/local/opt/snappy/lib -L/usr/local/opt/libsoxr/lib -L/usr/local/opt/libogg/lib -L/usr/local/opt/theora/lib -L/usr/local/opt/twolame/lib -mmacosx-version-min=${MIN_TARGET}"

make -j `sysctl -n hw.logicalcpu_max`
make install

/usr/local/bin/ffmpeg -version

lipo -info /usr/local/bin/ffmpeg
otool -L /usr/local/bin/ffmpeg | grep /usr/local/opt

echo Build ffmpeg-${FFMPEG_VERSION} finished.

exit 0
