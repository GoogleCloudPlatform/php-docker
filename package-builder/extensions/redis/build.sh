#!/bin/bash

set -ex

source ${DEB_BUILDER_DIR}/functions.sh

echo "Building redis for gcp-php${SHORT_VERSION}"

PNAME="gcp-php${SHORT_VERSION}-redis"

# Download the source
download_from_pecl redis 3.1.6

build_package redis
