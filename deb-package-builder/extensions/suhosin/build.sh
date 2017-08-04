#!/bin/bash

set -ex

source ${DEB_BUILDER_DIR}/functions.sh

echo "Building suhosin for gcp-php${SHORT_VERSION}"

PNAME="gcp-php${SHORT_VERSION}-suhosin"

# Download the source
if [ ${SHORT_VERSION} == '56' ]; then
    download_from_tarball https://github.com/stefanesser/suhosin/archive/0.9.38.tar.gz 0.9.38
else
    echo "Not yet implemented"
    exit 0
fi

build_package suhosin
