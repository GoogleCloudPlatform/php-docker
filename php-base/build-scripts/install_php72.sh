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


# A shell script for installing PHP 7.1.x.
set -xe

apt-get install -y \
        gcp-php72 \
        gcp-php72-apcu \
        gcp-php72-apcu-bc \
        gcp-php72-cassandra \
        gcp-php72-ev \
        gcp-php72-event \
        gcp-php72-grpc \
        gcp-php72-imagick \
        gcp-php72-mailparse \
        gcp-php72-memcached \
        gcp-php72-mongodb \
        gcp-php72-oauth \
        gcp-php72-opencensus \
        gcp-php72-pq \
        gcp-php72-protobuf \
        gcp-php72-rdkafka \
        gcp-php72-redis \
        --no-install-recommends

# Enable some extensions for backward compatibility
ln -s ${PHP72_DIR}/bin/php72-enmod ${PHP72_DIR}/bin/php-enmod
ln -s ${PHP72_DIR}/bin/php72-dismod  ${PHP72_DIR}/bin/php-dismod
${PHP72_DIR}/bin/php72-enmod apcu-bc
${PHP72_DIR}/bin/php72-enmod mailparse
${PHP72_DIR}/bin/php72-enmod memcached

# Copy the config files
mkdir -p "${PHP72_DIR}/etc"
cp "${PHP_CONFIG_TEMPLATE}/php-fpm.conf" "${PHP72_DIR}/etc/php-fpm.conf"
touch "${PHP72_DIR}/etc/php-fpm-user.conf"
cp "${PHP_CONFIG_TEMPLATE}/php.ini" "${PHP72_DIR}/lib"
cp "${PHP_CONFIG_TEMPLATE}/php-cli.ini" "${PHP72_DIR}/lib"

# Making php72 the default version
rm -f ${PHP_DIR}
ln -s ${PHP72_DIR} ${PHP_DIR}
