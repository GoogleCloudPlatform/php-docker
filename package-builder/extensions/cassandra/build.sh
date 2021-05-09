#!/bin/bash

set -ex

source ${DEB_BUILDER_DIR}/functions.sh

echo "Building cassandra for gcp-php${SHORT_VERSION}"

PNAME="gcp-php${SHORT_VERSION}-cassandra"

install_last_package "cassandra-cpp-driver"
install_last_package "cassandra-cpp-driver-dev"

LINK="/usr/lib/x86_64-linux-gnu/libcassandra.so"
# Temporary fix for broken symlink
if [ -L ${LINK} ]; then
    ls -al ${LINK}
    echo "Removing link.."
    rm ${LINK}
fi

ln -s /usr/lib/x86_64-linux-gnu/libcassandra.so.2.16.0 ${LINK}
ls -al /usr/lib/x86_64-linux-gnu/libcass*

# Download the source
#download_from_pecl cassandra
git clone https://github.com/nano-interactive/php-driver.git
pushd php-driver
PACKAGE_DIR=`pwd`/ext
EXT_VERSION=1.31.1

build_package cassandra
popd
rm -rf php-driver