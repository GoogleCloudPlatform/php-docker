#!/bin/bash
set -ex
source ${DEB_BUILDER_DIR}/extensions/functions.sh

echo "Building ps for gcp-php${SHORT_VERSION}"

PNAME="gcp-php${SHORT_VERSION}-ps"

apt-get install -y pslib-dev

# Download the source
if [ ${SHORT_VERSION} == '56' ]; then
    download_from_pecl ps 1.4.0
else
    download_from_pecl ps
fi

build_package ps
