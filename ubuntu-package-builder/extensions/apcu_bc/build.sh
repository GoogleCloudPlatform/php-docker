#!/bin/bash

set -ex

source ${DEB_BUILDER_DIR}/functions.sh

echo "Building apcu_bc for gcp-php${SHORT_VERSION}"

PNAME="gcp-php${SHORT_VERSION}-apcu-bc"

# Download the source
if [ ${SHORT_VERSION} == '56' ]; then
    echo 'No need to build apcu_bc'
    exit 0
else
    # We need to install the build dep
    install_last_package "gcp-php${SHORT_VERSION}-apcu"
    download_from_pecl apcu_bc-beta
fi

cp -R ${DEB_BUILDER_DIR}/extensions/apcu_bc/debian ${PACKAGE_DIR}
envsubst '${SHORT_VERSION}' < ${PACKAGE_DIR}/debian/gcp-php-apcu-bc.install.in \
         > ${PACKAGE_DIR}/debian/gcp-php${SHORT_VERSION}-apcu-bc.install
build_package apcu_bc
