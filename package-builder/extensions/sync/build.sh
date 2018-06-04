#!/bin/bash
set -ex
source ${DEB_BUILDER_DIR}/functions.sh

echo "Building sync for gcp-php${SHORT_VERSION}"

PNAME="gcp-php${SHORT_VERSION}-sync"

# Download the source
download_from_pecl sync

build_package sync
