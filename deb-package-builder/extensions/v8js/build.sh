#!/bin/bash
set -ex
source ${DEB_BUILDER_DIR}/functions.sh

echo "Building v8js for gcp-php${SHORT_VERSION}"

PNAME="gcp-php${SHORT_VERSION}-v8js"

if [ ${SHORT_VERSION} == '56' ]; then
    echo "v8js extension only for PHP 7.0+"
    exit 0
fi

install_last_package "libv8"

# Download the source
download_from_pecl v8js

build_package v8js
