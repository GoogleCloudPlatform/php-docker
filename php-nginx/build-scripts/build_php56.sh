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

apt-get install gcp-php56

# Making php56 the default version
ln -s ${PHP56_DIR} ${PHP_DIR}

# Create a directory for additional config files.
mkdir -p ${PHP56_DIR}/lib/conf.d

mkdir -p /tmp/ext-src
pushd /tmp/ext-src

curl -SL "https://pecl.php.net/get/jsonc" -o jsonc.tar.gz
mkdir -p jsonc
tar -zxf jsonc.tar.gz -C jsonc --strip-components=1
rm jsonc.tar.gz
cd jsonc
${PHP56_DIR}/bin/phpize
./configure
make
make install
echo 'extension=json.so' > ${PHP56_DIR}/lib/conf.d/ext-json.ini

cd /tmp/ext-src
curl -SL "https://github.com/stefanesser/suhosin/archive/0.9.38.tar.gz" -o suhosin.tar.gz
mkdir -p suhosin
tar -zxf suhosin.tar.gz -C suhosin --strip-components=1
rm suhosin.tar.gz
cd suhosin
${PHP56_DIR}/bin/phpize
./configure
make
make install

popd
rm -rf /tmp/ext-src

# Install extensions from our cloud-apt repo
apt-get install -y gcp-php56-memcached
ln -s ${PHP56_DIR}/lib/ext.available/ext-memcached.ini \
    ${PHP56_DIR}/lib/conf.d

# Install shared extensions with pecl
${PHP56_DIR}/bin/pecl install mailparse-2.1.6
echo 'extension=mailparse.so' > ${PHP56_DIR}/lib/conf.d/ext-mailparse.ini

${PHP56_DIR}/bin/pecl install apcu-4.0.11
echo 'extension=apcu.so' > ${PHP56_DIR}/lib/conf.d/ext-apcu.ini

${PHP56_DIR}/bin/pecl install memcache
${PHP56_DIR}/bin/pecl install mongodb
${PHP56_DIR}/bin/pecl install redis-2.2.8
${PHP56_DIR}/bin/pecl install grpc

rm -rf /tmp/pear

# Install composer
curl -sS https://getcomposer.org/installer | \
    ${PHP56_DIR}/bin/php -- \
    --install-dir=/usr/local/bin \
    --filename=composer
