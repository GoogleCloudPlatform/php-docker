#!/bin/bash
set -ex
source ${DEB_BUILDER_DIR}/functions.sh

echo "Building tcpwrap for gcp-php${SHORT_VERSION}"

PNAME="gcp-php${SHORT_VERSION}-tcpwrap"

apt-get install -y gawk libwrap0-dev

# Download the source
download_from_pecl tcpwrap

build_package tcpwrap
