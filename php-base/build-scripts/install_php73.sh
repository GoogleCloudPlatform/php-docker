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


# A shell script for installing PHP 7.3.x.
set -xe

apt-get update -y
apt-get install -y --no-install-recommends \
        gcp-php73 \
        gcp-php73-apcu \
        gcp-php73-apcu-bc \
        gcp-php73-ev \
        gcp-php73-event \
        gcp-php73-grpc \
        gcp-php73-imagick \
        gcp-php73-mailparse \
        gcp-php73-memcached \
        gcp-php73-mongodb \
        gcp-php73-oauth \
        gcp-php73-opencensus \
        gcp-php73-pq \
        gcp-php73-protobuf \
        gcp-php73-rdkafka \
        gcp-php73-redis \
        gcp-php73-stackdriver-debugger

/bin/bash /build-scripts/apt-cleanup.sh

# Enable some extensions for backward compatibility
ln -sf ${PHP73_DIR}/bin/php73-enmod ${PHP73_DIR}/bin/php-enmod
ln -sf ${PHP73_DIR}/bin/php73-dismod  ${PHP73_DIR}/bin/php-dismod
${PHP73_DIR}/bin/php73-enmod apcu-bc
${PHP73_DIR}/bin/php73-enmod mailparse
${PHP73_DIR}/bin/php73-enmod memcached

# Copy the config files
mkdir -p "${PHP73_DIR}/etc"
cp "${PHP_CONFIG_TEMPLATE}/php-fpm.conf" "${PHP73_DIR}/etc/php-fpm.conf"
touch "${PHP73_DIR}/etc/php-fpm-user.conf"
cp "${PHP_CONFIG_TEMPLATE}/php.ini" "${PHP73_DIR}/lib"
cp "${PHP_CONFIG_TEMPLATE}/php-cli.ini" "${PHP73_DIR}/lib"

# Making php73 the default version
rm -f ${PHP_DIR}
ln -s ${PHP73_DIR} ${PHP_DIR}
