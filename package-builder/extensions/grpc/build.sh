#!/bin/bash

set -ex

source ${DEB_BUILDER_DIR}/functions.sh

echo "Building grpc for gcp-php${SHORT_VERSION}"

PNAME="gcp-php${SHORT_VERSION}-grpc"

# Download the source
download_from_pecl grpc

build_package grpc
