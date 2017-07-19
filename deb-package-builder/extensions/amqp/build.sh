#!/bin/bash
set -ex
source ${DEB_BUILDER_DIR}/extensions/functions.sh

echo "Building ev for gcp-php${SHORT_VERSION}"

PNAME="gcp-php${SHORT_VERSION}-amqp"

apt-get install -y librabbitmq-dev

# Download the source
download_from_pecl amqp

build_package amqp