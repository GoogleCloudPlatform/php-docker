#!/bin/bash

set -ex

source ${DEB_BUILDER_DIR}/extensions/functions.sh

echo "Building protobuf for gcp-php${SHORT_VERSION}"

PNAME="gcp-php${SHORT_VERSION}-protobuf"

# Download the source
# download_from_pecl protobuf
# build_package protobuf

download_from_tarball https://github.com/google/protobuf/archive/v3.3.2.tar.gz 3.3.2

PACKAGE_DIR=${PACKAGE_DIR}/php/ext/google/protobuf
build_package protobuf
