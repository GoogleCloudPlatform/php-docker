#!/bin/bash
set -ex
source ${DEB_BUILDER_DIR}/functions.sh

echo "Building hprose for gcp-php${SHORT_VERSION}"

PNAME="gcp-php${SHORT_VERSION}-hprose"

# Download the source
if [ ${SHORT_VERSION} == '80' ]; then
    echo 'Hprose is not supported in php8'
    exit 0
else
    # Download the source
    download_from_pecl hprose

    build_package hprose
fi
