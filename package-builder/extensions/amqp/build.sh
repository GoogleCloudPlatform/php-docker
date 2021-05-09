#!/bin/bash
set -ex
source ${DEB_BUILDER_DIR}/functions.sh

export PHP_LIBRABBITMQ_DIR="no"
echo "Building amqp for gcp-php${SHORT_VERSION}"

# Now build the extension
PNAME="gcp-php${SHORT_VERSION}-amqp"

# Install the packages for librabbitmq
install_last_package "librabbitmq"
install_last_package "librabbitmq-dev"

# Download the source
download_from_pecl amqp 1.11.0beta

build_package amqp
