#!/bin/bash

set -ex

source ${DEB_BUILDER_DIR}/extensions/functions.sh

echo "Building stackdriver trace for gcp-php${SHORT_VERSION}"

PNAME="gcp-php${SHORT_VERSION}-stackdriver-trace"
EXT_VERSION="0.1.0"

download_from_tarball https://github.com/GoogleCloudPlatform/stackdriver-trace-php-extension/archive/master.tar.gz ${EXT_VERSION}

pwd
ls -al
build_package stackdriver_trace
