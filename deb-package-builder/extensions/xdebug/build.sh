#!/bin/bash
set -ex
source ${DEB_BUILDER_DIR}/extensions/functions.sh

echo "Building xdebug for gcp-php${SHORT_VERSION}"

PNAME="gcp-php${SHORT_VERSION}-xdebug"

if [ ${SHORT_VERSION} == '72' ]; then
    echo "xdebug extension only for PHP >=5.5 and < 7.2"
    exit 0
fi

# Download the source
download_from_pecl xdebug

build_package xdebug
