#!/bin/bash

echo "Update OpenSSL"
cd openssl
git pull
./Configure -static --static
make -j$(nproc)
make test
cd ..

echo "Update CycloneDDS"
cd cyclonedds
git pull

echo "Build dynamic CycloneDDS"
mkdir build-dynlib
cd build-dynlib
cmake -DCMAKE_INSTALL_PREFIX=install ..
cmake --build . --target install -- -j$(nproc)
cd ..

echo "Build static CycloneDDS"
mkdir build
cd build
cmake -DOPENSSL_ROOT_DIR=/opt/openssl -DCMAKE_PREFIX_PATH=$PWD/../build-dynlib/install -DCMAKE_BUILD_TYPE=Debug \
	-DCMAKE_CROSSCOMPILING=1 -DCMAKE_SYSTEM_NAME=Linux -DBUILD_SHARED_LIBS=0 -DBUILD_EXAMPLES=1 \
	-DCMAKE_INSTALL_PREFIX=../install ..
cmake --build . --target install -- -j$(nproc)
cd ../..

echo "Build dds-rtps"
cd dds-rtps
git fetch
git checkout CycloneDDS_Fixes
git pull
cd srcC/cyclone-dds-cmake
mkdir build
cd build
cmake -DOPENSSL_ROOT_DIR=/opt/openssl -DCycloneDDS_DIR="/opt/cyclonedds/install/lib/cmake/CycloneDDS/CycloneDDSConfig.cmake" -DCMAKE_PREFIX_PATH="/opt/cyclonedds/build-dynlib/install" -DCMAKE_BUILD_TYPE=Debug -DCMAKE_CROSSCOMPILING=1 -DCMAKE_SYSTEM_NAME=Linux -DBUILD_SHARED_LIBS=0 ..
cmake --build .

echo "Copy build output to mount"
cp eclipse* /opt/data
