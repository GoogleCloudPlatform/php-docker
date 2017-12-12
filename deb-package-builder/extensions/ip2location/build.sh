#!/bin/bash
set -ex
source ${DEB_BUILDER_DIR}/functions.sh

echo "Building ip2location for gcp-php${SHORT_VERSION}"

PNAME="gcp-php${SHORT_VERSION}-ip2location"

install_last_package "libip2location"
install_last_package "libip2location-dev"

# Download the source
download_from_pecl ip2location

build_package ip2location
