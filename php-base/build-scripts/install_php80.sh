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


# A shell script for installing PHP 8.0.x.
set -xe

apt-get update -y
apt-get install -y --no-install-recommends \
        gcp-php80 \
        gcp-php80-apcu \
        gcp-php80-ev \
        gcp-php80-event \
        gcp-php80-grpc \
        gcp-php80-imagick \
        gcp-php80-mailparse \
        gcp-php80-memcached \
        gcp-php80-mongodb \
        gcp-php80-oauth \
        gcp-php80-pq \
        gcp-php80-protobuf \
        gcp-php80-rdkafka \
        gcp-php80-redis

/bin/bash /build-scripts/apt-cleanup.sh

# Enable some extensions for backward compatibility
ln -sf ${PHP80_DIR}/bin/php80-enmod ${PHP80_DIR}/bin/php-enmod
ln -sf ${PHP80_DIR}/bin/php80-dismod  ${PHP80_DIR}/bin/php-dismod
#${PHP80_DIR}/bin/php80-enmod apcu-bc
${PHP80_DIR}/bin/php80-enmod mailparse
${PHP80_DIR}/bin/php80-enmod memcached

# Copy the config files
mkdir -p "${PHP80_DIR}/etc"
cp "${PHP_CONFIG_TEMPLATE}/php-fpm.conf" "${PHP80_DIR}/etc/php-fpm.conf"
touch "${PHP80_DIR}/etc/php-fpm-user.conf"
cp "${PHP_CONFIG_TEMPLATE}/php.ini" "${PHP80_DIR}/lib"
cp "${PHP_CONFIG_TEMPLATE}/php-cli.ini" "${PHP80_DIR}/lib"

# Making php80 the default version
rm -f ${PHP_DIR}
ln -s ${PHP80_DIR} ${PHP_DIR}
