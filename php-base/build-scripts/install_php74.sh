#!/bin/bash

# Copyright 2015 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


# A shell script for installing PHP 7.4.x.
set -xe

apt-get update -y
apt-get install -y --no-install-recommends \
        gcp-php74 \
        gcp-php74-apcu \
        gcp-php74-apcu-bc \
        gcp-php74-ev \
        gcp-php74-event \
        gcp-php74-grpc \
        gcp-php74-imagick \
        gcp-php74-mailparse \
        gcp-php74-memcached \
        gcp-php74-mongodb \
        gcp-php74-oauth \
        gcp-php74-opencensus \
        gcp-php74-pq \
        gcp-php74-protobuf \
        gcp-php74-rdkafka \
        gcp-php74-redis \
        gcp-php74-stackdriver-debugger

/bin/bash /build-scripts/apt-cleanup.sh

# Enable some extensions for backward compatibility
ln -sf ${PHP74_DIR}/bin/php74-enmod ${PHP74_DIR}/bin/php-enmod
ln -sf ${PHP74_DIR}/bin/php74-dismod  ${PHP74_DIR}/bin/php-dismod
${PHP74_DIR}/bin/php74-enmod apcu-bc
${PHP74_DIR}/bin/php74-enmod mailparse
${PHP74_DIR}/bin/php74-enmod memcached

# Copy the config files
mkdir -p "${PHP74_DIR}/etc"
cp "${PHP_CONFIG_TEMPLATE}/php-fpm.conf" "${PHP74_DIR}/etc/php-fpm.conf"
touch "${PHP74_DIR}/etc/php-fpm-user.conf"
cp "${PHP_CONFIG_TEMPLATE}/php.ini" "${PHP74_DIR}/lib"
cp "${PHP_CONFIG_TEMPLATE}/php-cli.ini" "${PHP74_DIR}/lib"

# Making php74 the default version
rm -f ${PHP_DIR}
ln -s ${PHP74_DIR} ${PHP_DIR}
