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

apt-get install gcp-php70

export PATH=${PHP70_DIR}/bin:${PATH}

# Create a directory for additional config files.
mkdir -p ${PHP70_DIR}/lib/conf.d

mkdir -p /tmp/ext-src
pushd /tmp/ext-src

# TODO: Use stable version of memcache from pecl once available
git clone https://github.com/websupport-sk/pecl-memcache.git memcache
pushd memcache
${PHP70_DIR}/bin/phpize
./configure
make
make install
popd

popd
rm -rf /tmp/ext-src

# Install extensions from our cloud-apt repo
apt-get install -y gcp-php70-memcached
ln -s ${PHP70_DIR}/lib/ext.available/ext-memcached.ini \
    ${PHP70_DIR}/lib/conf.d

# Install shared extensions with pecl
${PHP70_DIR}/bin/pecl install mailparse
echo 'extension=mailparse.so' > ${PHP70_DIR}/lib/conf.d/ext-mailparse.ini

${PHP70_DIR}/bin/pecl install apcu
echo 'extension=apcu.so' > ${PHP70_DIR}/lib/conf.d/ext-apcu.ini

# APC compatibility layer for APCu
${PHP70_DIR}/bin/pecl install apcu_bc-beta
echo 'extension=apc.so' > ${PHP70_DIR}/lib/conf.d/ext-apcu_bc.ini

${PHP70_DIR}/bin/pecl install mongodb

${PHP70_DIR}/bin/pecl install redis

rm -rf /tmp/pear
