#!/bin/bash
set -ex
source ${DEB_BUILDER_DIR}/extensions/functions.sh

echo "Building ev for gcp-php${SHORT_VERSION}"

PNAME="gcp-php${SHORT_VERSION}-${EXT_NAME}"

# Download the source
download_from_pecl ${EXT_FULL_NAME}

build_package ${EXT_FULL_NAME}