#!/bin/bash
set -ex
source ${DEB_BUILDER_DIR}/functions.sh

echo "Building ${EXT_NAME} for gcp-php${SHORT_VERSION}"

PNAME="gcp-php${SHORT_VERSION}-${EXT_NAME}"

# Download the source
download_from_pecl ${EXT_FULL_NAME}

build_package ${EXT_FULL_NAME}
