#!/bin/bash

set -ex

source ${DEB_BUILDER_DIR}/extensions/functions.sh

echo "Building cassandra cpp driver"

echo "deb http://ftp.debian.org/debian jessie-backports main" > /etc/apt/sources.list.d/jessie-backports.list
apt-get update
apt-get install -y libuv1-dev libgmp-dev cmake dh-exec lsb-release fakeroot

PNAME="cassandra-cpp-driver"

# Download the source
download_from_tarball https://github.com/datastax/cpp-driver/archive/2.6.0.tar.gz 2.6.0
PACKAGE_DIR=${PACKAGE_DIR}/packaging

pushd ${PACKAGE_DIR}
sed -i 's/libuv-dev/libuv1-dev/g' debian/control
sed -i 's/release=1/release=1~gcp8+1/g' build_deb.sh
./build_deb.sh
cp build/*.deb ${ARTIFACT_DIR}
popd
