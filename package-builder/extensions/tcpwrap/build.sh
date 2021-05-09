#!/bin/bash
set -ex
source ${DEB_BUILDER_DIR}/functions.sh

echo "Building tcpwrap for gcp-php${SHORT_VERSION}"

PNAME="gcp-php${SHORT_VERSION}-tcpwrap"

if [ ${SHORT_VERSION} == '80' ]; then
    echo "tcpwrap is not supported by PHP 8.0 yet"
    exit 0
fi

apt-get install -y gawk libwrap0-dev

# Download the source
download_from_pecl tcpwrap

build_package tcpwrap
