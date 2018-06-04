#!/bin/bash
set -ex
source ${DEB_BUILDER_DIR}/functions.sh

echo "Building timezonedb for gcp-php${SHORT_VERSION}"

PNAME="gcp-php${SHORT_VERSION}-timezonedb"

# Download the source
download_from_pecl timezonedb 2017.2

build_package timezonedb
