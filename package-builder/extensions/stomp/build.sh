#!/bin/bash
set -ex
source ${DEB_BUILDER_DIR}/functions.sh

echo "Building stomp for gcp-php${SHORT_VERSION}"

PNAME="gcp-php${SHORT_VERSION}-stomp"

# Download the source
if [ ${SHORT_VERSION} == '56' ]; then
    download_from_pecl stomp 1.0.9
elif [ ${SHORT_VERSION} == '80' ]; then
    download_from_git https://github.com/php/pecl-tools-stomp.git 3.0
else
    download_from_pecl stomp
fi

build_package stomp
