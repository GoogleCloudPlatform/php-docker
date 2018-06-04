#!/bin/bash
set -ex
source ${DEB_BUILDER_DIR}/functions.sh

echo "Building jsond for gcp-php${SHORT_VERSION}"

PNAME="gcp-php${SHORT_VERSION}-jsond"

# Download the source
download_from_pecl jsond

build_package jsond
