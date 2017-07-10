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
        gcp-php71 \
        gcp-php71-apcu \
        gcp-php71-apcu-bc \
        gcp-php71-cassandra \
        gcp-php71-ev \
        gcp-php71-event \
        gcp-php71-grpc \
        gcp-php71-imagick \
        gcp-php71-mailparse \
        gcp-php71-memcached \
        gcp-php71-mongodb \
        gcp-php71-oauth \
        gcp-php71-pq \
        gcp-php71-protobuf \
        gcp-php71-rdkafka \
        gcp-php71-redis \
        --no-install-recommends

# Enable some extensions for backward compatibility
ln -s ${PHP71_DIR}/bin/php71-enmod ${PHP71_DIR}/bin/php-enmod
ln -s ${PHP71_DIR}/bin/php71-dismod  ${PHP71_DIR}/bin/php-dismod
${PHP71_DIR}/bin/php71-enmod apcu-bc
${PHP71_DIR}/bin/php71-enmod mailparse
${PHP71_DIR}/bin/php71-enmod memcached

# Copy the config files
mkdir -p "${PHP71_DIR}/etc"
cp "${PHP_CONFIG_TEMPLATE}/php-fpm.conf" "${PHP71_DIR}/etc/php-fpm.conf"
touch "${PHP71_DIR}/etc/php-fpm-user.conf"
cp "${PHP_CONFIG_TEMPLATE}/php.ini" "${PHP71_DIR}/lib"
cp "${PHP_CONFIG_TEMPLATE}/php-cli.ini" "${PHP71_DIR}/lib"

# Making php71 the default version
rm -f ${PHP_DIR}
ln -s ${PHP71_DIR} ${PHP_DIR}
