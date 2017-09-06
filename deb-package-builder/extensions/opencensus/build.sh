#!/bin/bash
set -ex
source ${DEB_BUILDER_DIR}/functions.sh

echo "Building opencensus for gcp-php${SHORT_VERSION}"

PNAME="gcp-php${SHORT_VERSION}-opencensus"

# Download the source
download_from_pecl opencensus-devel

build_package opencensus
