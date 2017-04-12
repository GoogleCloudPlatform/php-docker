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


# A shell script for installing PHP 7.0.x.
set -xe

apt-get install -y \
        gcp-php70 \
        gcp-php70-apcu \
        gcp-php70-apcu-bc \
        gcp-php70-cassandra \
        gcp-php70-ev \
        gcp-php70-event \
        gcp-php70-grpc \
        gcp-php70-imagick \
        gcp-php70-mailparse \
        gcp-php70-memcached \
        gcp-php70-mongodb \
        gcp-php70-oauth \
        gcp-php70-phalcon \
        gcp-php70-pq \
        gcp-php70-rdkafka \
        gcp-php70-redis \
        --no-install-recommends

# Enable some extensions for backward compatibility
ln -s ${PHP70_DIR}/bin/php70-enmod ${PHP70_DIR}/bin/php-enmod
ln -s ${PHP70_DIR}/bin/php70-dismod ${PHP70_DIR}/bin/php-dismod
${PHP70_DIR}/bin/php70-enmod apcu-bc
${PHP70_DIR}/bin/php70-enmod mailparse
${PHP70_DIR}/bin/php70-enmod memcached

# Copy the config files
mkdir -p "${PHP70_DIR}/etc"
cp "${PHP_CONFIG_TEMPLATE}/php-fpm.conf" "${PHP70_DIR}/etc/php-fpm.conf"
touch "${PHP70_DIR}/etc/php-fpm-user.conf"
cp "${PHP_CONFIG_TEMPLATE}/php.ini" "${PHP70_DIR}/lib"
cp "${PHP_CONFIG_TEMPLATE}/php-cli.ini" "${PHP70_DIR}/lib"

# Making php70 the default version
rm -f ${PHP_DIR}
ln -s ${PHP70_DIR} ${PHP_DIR}
