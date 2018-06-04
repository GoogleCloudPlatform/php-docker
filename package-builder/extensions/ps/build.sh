#!/bin/bash
set -ex
source ${DEB_BUILDER_DIR}/functions.sh

echo "Building ps for gcp-php${SHORT_VERSION}"

PNAME="gcp-php${SHORT_VERSION}-ps"

if [ ${SHORT_VERSION} == '56' ]; then
    echo "ps extension only for PHP 7.0+"
    exit 0
fi

apt-get install -y pslib-dev

# Download the source
if [ ${SHORT_VERSION} == '56' ]; then
    download_from_pecl ps 1.4.0
else
    download_from_pecl ps
fi

build_package ps
