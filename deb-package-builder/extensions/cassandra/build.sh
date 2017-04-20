#!/bin/bash

set -ex

source ${DEB_BUILDER_DIR}/extensions/functions.sh

echo "Building cassandra for gcp-php${SHORT_VERSION}"

PNAME="gcp-php${SHORT_VERSION}-cassandra"

install_last_package "libuv1"
install_last_package "libuv1-dev"
install_last_package "cassandra-cpp-driver"
install_last_package "cassandra-cpp-driver-dev"

# Download the source
download_from_pecl cassandra

build_package cassandra
