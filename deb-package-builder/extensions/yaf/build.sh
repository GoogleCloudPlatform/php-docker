#!/bin/bash
set -ex
source ${DEB_BUILDER_DIR}/functions.sh

echo "Building yaf for gcp-php${SHORT_VERSION}"

PNAME="gcp-php${SHORT_VERSION}-yaf"

# Download the source
if [ ${SHORT_VERSION} == '56' ]; then
    download_from_pecl yaf 2.3.5
else
    download_from_pecl yaf
fi

build_package yaf
