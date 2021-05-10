#!/bin/bash

set -ex

source ${DEB_BUILDER_DIR}/functions.sh

echo "Building raphf for gcp-php${SHORT_VERSION}"

PNAME="gcp-php${SHORT_VERSION}-raphf"

# Download the source

if [ ${SHORT_VERSION} == "56" ]; then
    download_from_pecl raphf 1.1.2
else
    download_from_git https://github.com/m6w6/ext-raphf.git 2.0.2
fi

build_package raphf
