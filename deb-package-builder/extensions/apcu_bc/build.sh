#!/bin/bash

set -ex

source ${DEB_BUILDER_DIR}/extensions/functions.sh

echo "Building apcu_bc for gcp-php${SHORT_VERSION}"

PNAME="gcp-php${SHORT_VERSION}-apcu-bc"

# Download the source
if [ ${SHORT_VERSION} == '56' ]; then
    echo 'No need to build apcu_bc'
    exit 0
else
    # We need to install the build dep
    dpkg -i ${BUILD_DIR}/gcp-php${SHORT_VERSION}-apcu*.deb
    download_from_pecl apcu_bc-beta
fi

build_package apcu_bc
