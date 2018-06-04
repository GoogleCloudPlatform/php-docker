#!/bin/bash
set -ex
source ${DEB_BUILDER_DIR}/functions.sh

echo "Building amqp for gcp-php${SHORT_VERSION}"

PNAME="gcp-php${SHORT_VERSION}-amqp"

apt-get install -y librabbitmq-dev

# Download the source
download_from_pecl amqp

build_package amqp
