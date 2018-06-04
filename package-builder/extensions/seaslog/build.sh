#!/bin/bash
set -ex
source ${DEB_BUILDER_DIR}/functions.sh

echo "Building seaslog for gcp-php${SHORT_VERSION}"

PNAME="gcp-php${SHORT_VERSION}-seaslog"

# Download the source
download_from_pecl SeasLog

build_package seaslog
