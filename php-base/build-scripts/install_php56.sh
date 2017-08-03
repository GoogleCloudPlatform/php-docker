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


# A shell script for installing PHP 5.6.x.
set -xe

apt-get install -y \
        gcp-php56 \
        gcp-php56-apcu \
        gcp-php56-cassandra \
        gcp-php56-ev \
        gcp-php56-event \
        gcp-php56-grpc \
        gcp-php56-imagick \
        gcp-php56-json \
        gcp-php56-libsodium \
        gcp-php56-mailparse \
        gcp-php56-memcache \
        gcp-php56-memcached \
        gcp-php56-mongodb \
        gcp-php56-oauth \
        gcp-php56-phalcon \
        gcp-php56-pq \
        gcp-php56-protobuf \
        gcp-php56-rdkafka \
        gcp-php56-redis \
        gcp-php56-suhosin \
        --no-install-recommends

# Enable some extensions for backward compatibility
ln -s ${PHP56_DIR}/bin/php56-enmod ${PHP56_DIR}/bin/php-enmod
ln -s ${PHP56_DIR}/bin/php56-dismod ${PHP56_DIR}/bin/php-dismod
${PHP56_DIR}/bin/php56-enmod apcu
${PHP56_DIR}/bin/php56-enmod json
${PHP56_DIR}/bin/php56-enmod libsodium
${PHP56_DIR}/bin/php56-enmod mailparse
${PHP56_DIR}/bin/php56-enmod memcached

# Copy the config files
mkdir -p "${PHP56_DIR}/etc"
cp "${PHP_CONFIG_TEMPLATE}/php-fpm.conf" "${PHP56_DIR}/etc/php-fpm.conf"
touch "${PHP56_DIR}/etc/php-fpm-user.conf"
cp "${PHP_CONFIG_TEMPLATE}/php.ini" "${PHP56_DIR}/lib"
cp "${PHP_CONFIG_TEMPLATE}/php-cli.ini" "${PHP56_DIR}/lib"

# Making php56 the default version
rm -f ${PHP_DIR}
ln -s ${PHP56_DIR} ${PHP_DIR}
