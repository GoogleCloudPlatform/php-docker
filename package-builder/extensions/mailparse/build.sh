#!/bin/bash

set -ex

source ${DEB_BUILDER_DIR}/functions.sh

echo "Building mailparse for gcp-php${SHORT_VERSION}"

PNAME="gcp-php${SHORT_VERSION}-mailparse"

# Download the source
if [ ${SHORT_VERSION} == '56' ]; then
    download_from_pecl mailparse 2.1.6
else
    download_from_pecl mailparse
fi

build_package mailparse
