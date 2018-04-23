#!/bin/bash
set -ex
source ${DEB_BUILDER_DIR}/functions.sh

echo "Building vips for gcp-php${SHORT_VERSION}"

PNAME="gcp-php${SHORT_VERSION}-vips"

if [ ${SHORT_VERSION} == '56' ]; then
    echo "vips extension only for PHP 7.0+"
    exit 0
fi

apt-get install -y libtiff5-dev libjpeg62-turbo-dev libgsf-1-dev

install_last_package libvips
install_last_package libvips-dev

# Download the source
download_from_pecl vips

build_package vips
